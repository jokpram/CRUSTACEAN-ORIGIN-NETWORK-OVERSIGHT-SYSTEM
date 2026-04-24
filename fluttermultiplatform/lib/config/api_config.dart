class ApiConfig {
  // Ganti dengan IP lokal jika test di device fisik
  static const String baseUrl = 'http://10.0.2.2:8081/api';
  // Untuk web/desktop: 'http://localhost:8081/api'
  // Untuk emulator Android: 'http://10.0.2.2:8081/api'

  static String get wsBase =>
      '${baseUrl.replaceFirst('http', 'ws')}/chat/ws';
}
