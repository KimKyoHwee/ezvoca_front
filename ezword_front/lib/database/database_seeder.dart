import 'database_helper.dart';
import 'words_dao.dart';
import 'cards_dao.dart';
import 'sample_data.dart';

class DatabaseSeeder {
  final WordsDao _wordsDao = WordsDao();
  final CardsDao _cardsDao = CardsDao();

  Future<void> seedDatabase({bool clearExisting = false}) async {
    if (clearExisting) {
      await clearAllData();
    }

    // Check if data already exists
    final wordsCount = await _wordsDao.getWordsCount();
    if (wordsCount > 0) {
      print('Database already seeded with $wordsCount words');
      return;
    }

    print('Seeding database with sample data...');

    // Insert sample words
    int wordsInserted = 0;
    for (final word in SampleData.sampleWords) {
      try {
        await _wordsDao.insertWord(word);
        wordsInserted++;
      } catch (e) {
        print('Error inserting word ${word.word}: $e');
      }
    }

    // Insert sample cards
    int cardsInserted = 0;
    for (final card in SampleData.generateSampleCards()) {
      try {
        await _cardsDao.insertCard(card);
        cardsInserted++;
      } catch (e) {
        print('Error inserting card for word ${card.wordId}: $e');
      }
    }

    print('Database seeded successfully:');
    print('- Words inserted: $wordsInserted');
    print('- Cards inserted: $cardsInserted');

    await printDatabaseStats();
  }

  Future<void> clearAllData() async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

    print('Clearing existing data...');
    
    await db.delete('cards');
    await db.delete('confusable_pairs');
    await db.delete('words');
    await db.delete('sessions');

    print('All data cleared.');
  }

  Future<void> printDatabaseStats() async {
    final wordsCount = await _wordsDao.getWordsCount();
    final allCards = await _cardsDao.getAllCards();
    final learnedCount = await _cardsDao.getLearnedCardsCount();

    final newCards = allCards.where((c) => c.state.name == 'new').length;
    final learningCards = allCards.where((c) => c.state.name == 'learning').length;
    final reviewCards = allCards.where((c) => c.state.name == 'review').length;
    final leechCards = allCards.where((c) => c.state.name == 'leech').length;

    print('\n=== Database Statistics ===');
    print('Total words: $wordsCount');
    print('Total cards: ${allCards.length}');
    print('Learned cards: $learnedCount');
    print('New cards: $newCards');
    print('Learning cards: $learningCards');
    print('Review cards: $reviewCards');
    print('Leech cards: $leechCards');
    print('===========================\n');
  }

  Future<bool> isDatabaseEmpty() async {
    final wordsCount = await _wordsDao.getWordsCount();
    return wordsCount == 0;
  }

  Future<Map<String, dynamic>> getDatabaseInfo() async {
    final dbHelper = DatabaseHelper();
    return await dbHelper.getDatabaseInfo();
  }

  /// Get sample study session for testing
  Future<void> createTestStudySession() async {
    final sessionCards = await _cardsDao.getDailyStudyCards(limit: 10);
    
    print('Test study session created with ${sessionCards.length} cards:');
    for (int i = 0; i < sessionCards.length; i++) {
      final sessionCard = sessionCards[i];
      final word = sessionCard.word;
      final card = sessionCard.card;
      
      print('${i + 1}. ${word.word} (${word.partOfSpeech}) - ${card.state.name}');
      print('   Meaning: ${word.meaning}');
      print('   Mastery: ${(card.masteryScore * 100).round()}%');
      if (card.nextReview != null) {
        final timeUntilReview = card.nextReview!.difference(DateTime.now());
        print('   Next review: ${timeUntilReview.inMinutes}m');
      }
      print('');
    }
  }
}