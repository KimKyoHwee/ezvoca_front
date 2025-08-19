import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../models/word.dart';
import 'database_helper.dart';

class WordsDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertWord(Word word) async {
    final db = await _dbHelper.database;
    
    final wordMap = {
      'word': word.word,
      'meaning': word.meaning,
      'pronunciation': word.pronunciation,
      'part_of_speech': word.partOfSpeech,
      'examples': jsonEncode(word.examples),
      'updated_at': DateTime.now().toIso8601String(),
    };

    final wordId = await db.insert('words', wordMap);

    // Insert confusable pairs if any
    for (final pair in word.confusablePairs) {
      await db.insert('confusable_pairs', {
        'word_id': wordId,
        'pair_word_id': pair.wordId,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    return wordId;
  }

  Future<List<Word>> getAllWords() async {
    final db = await _dbHelper.database;
    
    final wordsResult = await db.query('words', orderBy: 'word ASC');
    
    final words = <Word>[];
    for (final wordMap in wordsResult) {
      final confusablePairs = await _getConfusablePairs(db, wordMap['id'] as int);
      words.add(_mapToWord(wordMap, confusablePairs));
    }
    
    return words;
  }

  Future<Word?> getWordById(int id) async {
    final db = await _dbHelper.database;
    
    final result = await db.query(
      'words',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (result.isEmpty) return null;
    
    final confusablePairs = await _getConfusablePairs(db, id);
    return _mapToWord(result.first, confusablePairs);
  }

  Future<List<Word>> searchWords(String query) async {
    final db = await _dbHelper.database;
    
    final result = await db.query(
      'words',
      where: 'word LIKE ? OR meaning LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'word ASC',
      limit: 50,
    );
    
    final words = <Word>[];
    for (final wordMap in result) {
      final confusablePairs = await _getConfusablePairs(db, wordMap['id'] as int);
      words.add(_mapToWord(wordMap, confusablePairs));
    }
    
    return words;
  }

  Future<int> updateWord(Word word) async {
    final db = await _dbHelper.database;
    
    final wordMap = {
      'word': word.word,
      'meaning': word.meaning,
      'pronunciation': word.pronunciation,
      'part_of_speech': word.partOfSpeech,
      'examples': jsonEncode(word.examples),
      'updated_at': DateTime.now().toIso8601String(),
    };

    // Update word
    final result = await db.update(
      'words',
      wordMap,
      where: 'id = ?',
      whereArgs: [word.id],
    );

    // Update confusable pairs (delete old, insert new)
    await db.delete('confusable_pairs', where: 'word_id = ?', whereArgs: [word.id]);
    for (final pair in word.confusablePairs) {
      await db.insert('confusable_pairs', {
        'word_id': word.id,
        'pair_word_id': pair.wordId,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    return result;
  }

  Future<int> deleteWord(int id) async {
    final db = await _dbHelper.database;
    
    // Delete confusable pairs first (foreign key constraints)
    await db.delete('confusable_pairs', where: 'word_id = ? OR pair_word_id = ?', whereArgs: [id, id]);
    
    // Delete the word
    return await db.delete('words', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Word>> getRandomWords(int count) async {
    final db = await _dbHelper.database;
    
    final result = await db.rawQuery(
      'SELECT * FROM words ORDER BY RANDOM() LIMIT ?',
      [count],
    );
    
    final words = <Word>[];
    for (final wordMap in result) {
      final confusablePairs = await _getConfusablePairs(db, wordMap['id'] as int);
      words.add(_mapToWord(wordMap, confusablePairs));
    }
    
    return words;
  }

  Future<int> getWordsCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM words');
    return result.first['count'] as int;
  }

  // Helper methods
  Future<List<ConfusablePair>> _getConfusablePairs(Database db, int wordId) async {
    final result = await db.rawQuery('''
      SELECT w.id, w.word as lemma
      FROM confusable_pairs cp
      JOIN words w ON cp.pair_word_id = w.id
      WHERE cp.word_id = ?
    ''', [wordId]);
    
    return result.map((row) => ConfusablePair(
      wordId: row['id'] as int,
      lemma: row['lemma'] as String,
    )).toList();
  }

  Word _mapToWord(Map<String, dynamic> map, List<ConfusablePair> confusablePairs) {
    return Word(
      id: map['id'] as int,
      word: map['word'] as String,
      meaning: map['meaning'] as String,
      pronunciation: map['pronunciation'] as String?,
      partOfSpeech: map['part_of_speech'] as String,
      examples: List<String>.from(jsonDecode(map['examples'] as String? ?? '[]')),
      confusablePairs: confusablePairs,
    );
  }
}