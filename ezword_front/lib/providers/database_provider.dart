import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_helper.dart';
import '../database/words_dao.dart';
import '../database/cards_dao.dart';
import '../database/database_seeder.dart';
import '../models/study_session.dart';

// Database initialization provider
final databaseProvider = Provider<DatabaseHelper>((ref) => DatabaseHelper());

// DAO providers
final wordsDAOProvider = Provider<WordsDao>((ref) => WordsDao());
final cardsDAOProvider = Provider<CardsDao>((ref) => CardsDao());

// Database seeder provider
final databaseSeederProvider = Provider<DatabaseSeeder>((ref) => DatabaseSeeder());

// Database initialization state provider
final databaseInitProvider = FutureProvider<bool>((ref) async {
  final seeder = ref.read(databaseSeederProvider);
  
  // Check if database is empty and seed if needed
  final isEmpty = await seeder.isDatabaseEmpty();
  if (isEmpty) {
    await seeder.seedDatabase();
  }
  
  return true;
});

// Daily study cards provider
final dailyStudyCardsProvider = FutureProvider<List<StudySessionCard>>((ref) async {
  // Ensure database is initialized
  await ref.watch(databaseInitProvider.future);
  
  final cardsDao = ref.read(cardsDAOProvider);
  return await cardsDao.getDailyStudyCards(limit: 20);
});

// Learned cards count provider
final learnedCardsCountProvider = FutureProvider<int>((ref) async {
  // Ensure database is initialized
  await ref.watch(databaseInitProvider.future);
  
  final cardsDao = ref.read(cardsDAOProvider);
  return await cardsDao.getLearnedCardsCount();
});

// Total words count provider
final totalWordsCountProvider = FutureProvider<int>((ref) async {
  // Ensure database is initialized
  await ref.watch(databaseInitProvider.future);
  
  final wordsDao = ref.read(wordsDAOProvider);
  return await wordsDao.getWordsCount();
});

// Database statistics provider for debugging
final databaseStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  // Ensure database is initialized
  await ref.watch(databaseInitProvider.future);
  
  final seeder = ref.read(databaseSeederProvider);
  final dbInfo = await seeder.getDatabaseInfo();
  
  final wordsDao = ref.read(wordsDAOProvider);
  final cardsDao = ref.read(cardsDAOProvider);
  
  final wordsCount = await wordsDao.getWordsCount();
  final allCards = await cardsDao.getAllCards();
  final learnedCount = await cardsDao.getLearnedCardsCount();
  
  return {
    'database': dbInfo,
    'wordsCount': wordsCount,
    'totalCards': allCards.length,
    'learnedCards': learnedCount,
    'cardsByState': {
      'new': allCards.where((c) => c.state.name == 'new').length,
      'learning': allCards.where((c) => c.state.name == 'learning').length,
      'review': allCards.where((c) => c.state.name == 'review').length,
      'leech': allCards.where((c) => c.state.name == 'leech').length,
      'starred': allCards.where((c) => c.state.name == 'starred').length,
      'ambiguous': allCards.where((c) => c.state.name == 'ambiguous').length,
    },
  };
});