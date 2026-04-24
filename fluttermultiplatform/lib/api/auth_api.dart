import 'api_client.dart';

class AuthApi {
  static Future register(Map<String, dynamic> data) => api.post('/auth/register', data: data);
  static Future login(Map<String, dynamic> data) => api.post('/auth/login', data: data);
  static Future getProfile() => api.get('/auth/profile');
  static Future updateProfile(Map<String, dynamic> data) => api.put('/auth/profile', data: data);
}
