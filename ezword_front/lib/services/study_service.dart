import '../models/study_session.dart';
import '../models/card.dart';
import '../config/api_config.dart';
import 'api_client.dart';

class StudyService {
  final ApiClient _apiClient = ApiClient();

  // Get daily study set
  Future<List<StudySessionCard>> getDailyStudyCards({
    int limit = 20,
  }) async {
    final response = await _apiClient.get(
      ApiConfig.dailySetsPath,
      queryParameters: {'limit': limit},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['cards'] ?? response.data;
      return data.map((json) => StudySessionCard.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch daily study cards: ${response.statusMessage}');
    }
  }

  // Submit review result
  Future<void> submitReview({
    required int cardId,
    required ReviewResult result,
    int? sessionDuration,
  }) async {
    final reviewData = {
      'cardId': cardId,
      'result': result.name,
      'timestamp': DateTime.now().toIso8601String(),
      if (sessionDuration != null) 'sessionDurationMs': sessionDuration,
    };

    final response = await _apiClient.post(
      ApiConfig.reviewsPath,
      data: reviewData,
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to submit review: ${response.statusMessage}');
    }
  }

  // Submit multiple reviews (batch)
  Future<void> submitBatchReviews(List<Map<String, dynamic>> reviews) async {
    final response = await _apiClient.post(
      '${ApiConfig.reviewsPath}/batch',
      data: {'reviews': reviews},
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to submit batch reviews: ${response.statusMessage}');
    }
  }

  // Mark word as leech
  Future<void> markAsLeech(int wordId) async {
    final response = await _apiClient.post(
      '${ApiConfig.leechPath}/$wordId',
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to mark word as leech: ${response.statusMessage}');
    }
  }

  // Get user learning statistics
  Future<Map<String, dynamic>> getLearningCounters({
    bool excludeLeech = true,
    bool excludeAmbiguous = true,
  }) async {
    final queryParams = <String, dynamic>{
      'excludeLeech': excludeLeech,
      'excludeAmbiguous': excludeAmbiguous,
    };

    final response = await _apiClient.get(
      ApiConfig.countersPath,
      queryParameters: queryParams,
    );

    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch learning counters: ${response.statusMessage}');
    }
  }

  // Get session history
  Future<List<Map<String, dynamic>>> getSessionHistory({
    int page = 0,
    int size = 10,
  }) async {
    final response = await _apiClient.get(
      '/sessions',
      queryParameters: {
        'page': page,
        'size': size,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['content'] ?? response.data;
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch session history: ${response.statusMessage}');
    }
  }

  // Save session snapshot (for interruption recovery)
  Future<void> saveSessionSnapshot(StudySession session) async {
    final snapshotData = {
      'sessionId': session.id,
      'currentIndex': session.currentIndex,
      'revealState': session.revealState.name,
      'mode': session.mode.name,
      'timestamp': DateTime.now().toIso8601String(),
      'cardIds': session.cards.map((card) => card.card.id).toList(),
    };

    final response = await _apiClient.post(
      '/sessions/snapshot',
      data: snapshotData,
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to save session snapshot: ${response.statusMessage}');
    }
  }

  // Restore session snapshot
  Future<StudySession?> restoreSessionSnapshot(String userId) async {
    final response = await _apiClient.get('/sessions/snapshot/$userId');

    if (response.statusCode == 200 && response.data != null) {
      // Note: This would need to be implemented based on the actual API response structure
      // For now, returning null as the backend API is not yet available
      return null;
    } else if (response.statusCode == 404) {
      return null; // No snapshot available
    } else {
      throw Exception('Failed to restore session snapshot: ${response.statusMessage}');
    }
  }
}