import '../models/word.dart';
import '../config/api_config.dart';
import 'api_client.dart';

class WordService {
  final ApiClient _apiClient = ApiClient();

  // Get word list with pagination
  Future<List<Word>> getWords({
    int page = 0,
    int size = 20,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
    };
    
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final response = await _apiClient.get(
      ApiConfig.wordsPath,
      queryParameters: queryParams,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['content'] ?? response.data;
      return data.map((json) => Word.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch words: ${response.statusMessage}');
    }
  }

  // Get word by ID
  Future<Word> getWordById(int id) async {
    final response = await _apiClient.get('${ApiConfig.wordsPath}/$id');

    if (response.statusCode == 200) {
      return Word.fromJson(response.data);
    } else {
      throw Exception('Failed to fetch word: ${response.statusMessage}');
    }
  }

  // Search words by term
  Future<List<Word>> searchWords(String term) async {
    final response = await _apiClient.get(
      '${ApiConfig.wordsPath}/search',
      queryParameters: {'q': term},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['results'] ?? response.data;
      return data.map((json) => Word.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search words: ${response.statusMessage}');
    }
  }

  // Get random word for practice
  Future<Word> getRandomWord() async {
    final response = await _apiClient.get('${ApiConfig.wordsPath}/random');

    if (response.statusCode == 200) {
      return Word.fromJson(response.data);
    } else {
      throw Exception('Failed to fetch random word: ${response.statusMessage}');
    }
  }

  // Get words by difficulty level
  Future<List<Word>> getWordsByDifficulty(String difficulty) async {
    final response = await _apiClient.get(
      ApiConfig.wordsPath,
      queryParameters: {'difficulty': difficulty},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['content'] ?? response.data;
      return data.map((json) => Word.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch words by difficulty: ${response.statusMessage}');
    }
  }
}