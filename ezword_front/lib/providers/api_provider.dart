import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';
import '../services/word_service.dart';
import '../services/study_service.dart';
import '../models/word.dart';
import '../models/study_session.dart';
import '../models/card.dart';

// API Client provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final apiClient = ApiClient();
  apiClient.initialize();
  return apiClient;
});

// Service providers
final wordServiceProvider = Provider<WordService>((ref) {
  ref.watch(apiClientProvider); // Ensure API client is initialized
  return WordService();
});

final studyServiceProvider = Provider<StudyService>((ref) {
  ref.watch(apiClientProvider); // Ensure API client is initialized
  return StudyService();
});

// Authentication state provider
final authStateProvider = StateProvider<bool>((ref) => false);

// Daily study cards provider
final dailyStudyCardsProvider = FutureProvider<List<StudySessionCard>>((ref) async {
  final studyService = ref.read(studyServiceProvider);
  return await studyService.getDailyStudyCards(limit: 20);
});

// Words provider with pagination
final wordsProvider = FutureProvider.family<List<Word>, Map<String, dynamic>>((ref, params) async {
  final wordService = ref.read(wordServiceProvider);
  return await wordService.getWords(
    page: params['page'] ?? 0,
    size: params['size'] ?? 20,
    search: params['search'],
  );
});

// Word by ID provider
final wordByIdProvider = FutureProvider.family<Word, int>((ref, id) async {
  final wordService = ref.read(wordServiceProvider);
  return await wordService.getWordById(id);
});

// Random word provider
final randomWordProvider = FutureProvider<Word>((ref) async {
  final wordService = ref.read(wordServiceProvider);
  return await wordService.getRandomWord();
});

// Learning counters provider
final learningCountersProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final studyService = ref.read(studyServiceProvider);
  return await studyService.getLearningCounters(
    excludeLeech: true,
    excludeAmbiguous: true,
  );
});

// Session history provider
final sessionHistoryProvider = FutureProvider.family<List<Map<String, dynamic>>, Map<String, int>>((ref, params) async {
  final studyService = ref.read(studyServiceProvider);
  return await studyService.getSessionHistory(
    page: params['page'] ?? 0,
    size: params['size'] ?? 10,
  );
});

// Network connectivity state
final networkStateProvider = StateProvider<bool>((ref) => true);

// Loading states for different operations
final isSubmittingReviewProvider = StateProvider<bool>((ref) => false);
final isMarkingLeechProvider = StateProvider<bool>((ref) => false);

// Error state provider
final errorStateProvider = StateProvider<String?>((ref) => null);

// API helpers for mutations
class ApiMutations {
  final Ref ref;
  
  ApiMutations(this.ref);
  
  Future<void> submitReview({
    required int cardId,
    required ReviewResult result,
    int? sessionDuration,
  }) async {
    ref.read(isSubmittingReviewProvider.notifier).state = true;
    ref.read(errorStateProvider.notifier).state = null;
    
    try {
      final studyService = ref.read(studyServiceProvider);
      await studyService.submitReview(
        cardId: cardId,
        result: result,
        sessionDuration: sessionDuration,
      );
      
      // Invalidate related providers to refresh data
      ref.invalidate(learningCountersProvider);
      ref.invalidate(dailyStudyCardsProvider);
    } catch (e) {
      ref.read(errorStateProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      ref.read(isSubmittingReviewProvider.notifier).state = false;
    }
  }
  
  Future<void> markAsLeech(int wordId) async {
    ref.read(isMarkingLeechProvider.notifier).state = true;
    ref.read(errorStateProvider.notifier).state = null;
    
    try {
      final studyService = ref.read(studyServiceProvider);
      await studyService.markAsLeech(wordId);
      
      // Invalidate related providers
      ref.invalidate(learningCountersProvider);
      ref.invalidate(dailyStudyCardsProvider);
    } catch (e) {
      ref.read(errorStateProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      ref.read(isMarkingLeechProvider.notifier).state = false;
    }
  }
}

// API mutations provider
final apiMutationsProvider = Provider<ApiMutations>((ref) => ApiMutations(ref));