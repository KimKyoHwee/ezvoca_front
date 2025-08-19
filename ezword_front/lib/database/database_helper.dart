import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/word.dart';
import '../models/card.dart';

class DatabaseHelper {
  static const String _databaseName = 'ezvoca.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String _wordsTable = 'words';
  static const String _cardsTable = 'cards';
  static const String _confusablePairsTable = 'confusable_pairs';
  static const String _sessionsTable = 'sessions';

  // Singleton pattern
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Words table
    await db.execute('''
      CREATE TABLE $_wordsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT NOT NULL UNIQUE,
        meaning TEXT NOT NULL,
        pronunciation TEXT,
        part_of_speech TEXT NOT NULL,
        examples TEXT, -- JSON array as text
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Cards table (for SRS learning)
    await db.execute('''
      CREATE TABLE $_cardsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word_id INTEGER NOT NULL,
        user_id INTEGER DEFAULT 1, -- Single user for now
        state TEXT NOT NULL DEFAULT 'new',
        mastery_score REAL NOT NULL DEFAULT 0.0,
        lapses INTEGER NOT NULL DEFAULT 0,
        next_review TEXT, -- ISO 8601 datetime
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (word_id) REFERENCES $_wordsTable(id) ON DELETE CASCADE
      )
    ''');

    // Confusable pairs table
    await db.execute('''
      CREATE TABLE $_confusablePairsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word_id INTEGER NOT NULL,
        pair_word_id INTEGER NOT NULL,
        FOREIGN KEY (word_id) REFERENCES $_wordsTable(id) ON DELETE CASCADE,
        FOREIGN KEY (pair_word_id) REFERENCES $_wordsTable(id) ON DELETE CASCADE,
        UNIQUE(word_id, pair_word_id)
      )
    ''');

    // Session snapshots table
    await db.execute('''
      CREATE TABLE $_sessionsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL DEFAULT 1,
        session_data TEXT NOT NULL, -- JSON snapshot
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Indexes for better performance
    await db.execute('CREATE INDEX idx_cards_word_id ON $_cardsTable(word_id)');
    await db.execute('CREATE INDEX idx_cards_state ON $_cardsTable(state)');
    await db.execute('CREATE INDEX idx_cards_next_review ON $_cardsTable(next_review)');
    await db.execute('CREATE INDEX idx_words_word ON $_wordsTable(word)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades if needed
    if (oldVersion < 2) {
      // Future migrations will go here
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  Future<void> deleteDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  // Database info for debugging
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    final db = await database;
    final version = await db.getVersion();
    final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
    
    return {
      'version': version,
      'path': db.path,
      'tables': tables.map((t) => t['name']).toList(),
    };
  }
}