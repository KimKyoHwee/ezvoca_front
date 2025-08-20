class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api',
  );
  
  static const String version = 'v1';
  
  // Endpoints
  static const String authPath = '/auth';
  static const String wordsPath = '/words';
  static const String dailySetsPath = '/daily-sets';
  static const String reviewsPath = '/reviews';
  static const String leechPath = '/leech';
  static const String countersPath = '/me/counters';
  
  // Timeout settings
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
}