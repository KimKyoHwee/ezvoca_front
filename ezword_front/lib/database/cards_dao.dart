import 'package:sqflite/sqflite.dart';
import '../models/card.dart';
import '../models/word.dart';
import '../models/study_session.dart';
import 'database_helper.dart';
import 'words_dao.dart';

class CardsDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final WordsDao _wordsDao = WordsDao();

  Future<int> insertCard(Card card) async {
    final db = await _dbHelper.database;
    
    final cardMap = {
      'word_id': card.wordId,
      'user_id': card.userId,
      'state': card.state.name,
      'mastery_score': card.masteryScore,
      'lapses': card.lapses,
      'next_review': card.nextReview?.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    return await db.insert('cards', cardMap);
  }

  Future<List<Card>> getAllCards() async {
    final db = await _dbHelper.database;
    
    final result = await db.query('cards', orderBy: 'created_at DESC');
    
    return result.map(_mapToCard).toList();
  }

  Future<Card?> getCardById(int id) async {
    final db = await _dbHelper.database;
    
    final result = await db.query(
      'cards',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (result.isEmpty) return null;
    
    return _mapToCard(result.first);
  }

  Future<Card?> getCardByWordId(int wordId, {int userId = 1}) async {
    final db = await _dbHelper.database;
    
    final result = await db.query(
      'cards',
      where: 'word_id = ? AND user_id = ?',
      whereArgs: [wordId, userId],
      limit: 1,
    );
    
    if (result.isEmpty) return null;
    
    return _mapToCard(result.first);
  }

  Future<List<StudySessionCard>> getDailyStudyCards({
    int userId = 1,
    int limit = 20,
  }) async {
    final db = await _dbHelper.database;
    
    // Get cards that need review (new cards + due reviews)
    final result = await db.rawQuery('''
      SELECT c.*, w.word, w.meaning, w.pronunciation, w.part_of_speech, w.examples
      FROM cards c
      JOIN words w ON c.word_id = w.id
      WHERE c.user_id = ?
      AND (
        c.state = 'new' OR
        c.state = 'learning' OR
        (c.state = 'review' AND (c.next_review IS NULL OR c.next_review <= datetime('now')))
      )
      ORDER BY 
        CASE c.state 
          WHEN 'new' THEN 1
          WHEN 'learning' THEN 2
          WHEN 'review' THEN 3
          ELSE 4
        END,
        c.next_review ASC,
        RANDOM()
      LIMIT ?
    ''', [userId, limit]);
    
    final sessionCards = <StudySessionCard>[];
    for (final row in result) {
      final card = _mapToCard(row);
      final word = _mapToWordFromJoin(row);
      sessionCards.add(StudySessionCard(word: word, card: card));
    }
    
    return sessionCards;
  }

  Future<List<Card>> getCardsByState(CardState state, {int userId = 1}) async {
    final db = await _dbHelper.database;
    
    final result = await db.query(
      'cards',
      where: 'state = ? AND user_id = ?',
      whereArgs: [state.name, userId],
      orderBy: 'updated_at DESC',
    );
    
    return result.map(_mapToCard).toList();
  }

  Future<List<Card>> getLearnedCards({int userId = 1}) async {
    final db = await _dbHelper.database;
    
    final result = await db.query(
      'cards',
      where: 'user_id = ? AND mastery_score >= 0.8 AND state NOT IN (?, ?)',
      whereArgs: [userId, 'leech', 'ambiguous'],
      orderBy: 'mastery_score DESC',
    );
    
    return result.map(_mapToCard).toList();
  }

  Future<int> getLearnedCardsCount({int userId = 1}) async {
    final db = await _dbHelper.database;
    
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM cards
      WHERE user_id = ?
      AND mastery_score >= 0.8
      AND state NOT IN ('leech', 'ambiguous')
    ''', [userId]);
    
    return result.first['count'] as int;
  }

  Future<int> updateCard(Card card) async {
    final db = await _dbHelper.database;
    
    final cardMap = {
      'word_id': card.wordId,
      'user_id': card.userId,
      'state': card.state.name,
      'mastery_score': card.masteryScore,
      'lapses': card.lapses,
      'next_review': card.nextReview?.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    return await db.update(
      'cards',
      cardMap,
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  Future<int> updateCardAfterReview(int cardId, ReviewResult result) async {
    final card = await getCardById(cardId);
    if (card == null) return 0;

    CardState newState;
    double newMasteryScore = card.masteryScore;
    int newLapses = card.lapses;
    DateTime? nextReview;

    // Simple SRS algorithm
    switch (result) {
      case ReviewResult.known:
        newMasteryScore = (newMasteryScore + 0.3).clamp(0.0, 1.0);
        if (newMasteryScore >= 0.8) {
          newState = CardState.review;
          nextReview = DateTime.now().add(Duration(days: (newMasteryScore * 7).round() + 1));
        } else {
          newState = CardState.learning;
          nextReview = DateTime.now().add(const Duration(minutes: 10));
        }
        break;
      
      case ReviewResult.unknown:
        newMasteryScore = (newMasteryScore - 0.3).clamp(0.0, 1.0);
        newLapses++;
        if (newLapses >= 5) {
          newState = CardState.leech;
        } else {
          newState = CardState.learning;
        }
        nextReview = DateTime.now().add(const Duration(minutes: 1));
        break;
      
      case ReviewResult.hard:
        newMasteryScore = (newMasteryScore - 0.1).clamp(0.0, 1.0);
        newState = CardState.ambiguous;
        nextReview = DateTime.now().add(const Duration(hours: 1));
        break;
    }

    final updatedCard = card.copyWith(
      state: newState,
      masteryScore: newMasteryScore,
      lapses: newLapses,
      nextReview: nextReview,
      updatedAt: DateTime.now(),
    );

    return await updateCard(updatedCard);
  }

  Future<int> markAsLeech(int cardId) async {
    final card = await getCardById(cardId);
    if (card == null) return 0;

    final leechCard = card.copyWith(
      state: CardState.leech,
      lapses: card.lapses + 1,
      updatedAt: DateTime.now(),
    );

    return await updateCard(leechCard);
  }

  Future<int> deleteCard(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('cards', where: 'id = ?', whereArgs: [id]);
  }

  // Helper methods
  Card _mapToCard(Map<String, dynamic> map) {
    return Card(
      id: map['id'] as int,
      wordId: map['word_id'] as int,
      userId: map['user_id'] as int,
      state: CardState.values.firstWhere((s) => s.name == map['state']),
      masteryScore: map['mastery_score'] as double,
      lapses: map['lapses'] as int,
      nextReview: map['next_review'] != null 
          ? DateTime.parse(map['next_review'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Word _mapToWordFromJoin(Map<String, dynamic> map) {
    return Word(
      id: map['word_id'] as int,
      word: map['word'] as String,
      meaning: map['meaning'] as String,
      pronunciation: map['pronunciation'] as String?,
      partOfSpeech: map['part_of_speech'] as String,
      examples: (map['examples'] as String?)?.split(',') ?? [],
      confusablePairs: [], // Will be loaded separately if needed
    );
  }
}