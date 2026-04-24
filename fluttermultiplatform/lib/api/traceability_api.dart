import 'api_client.dart';

class TraceabilityApi {
  static Future getByBatchCode(String batchCode) => api.get('/traceability/$batchCode');
  static Future getAll() => api.get('/admin/traceability/logs');
  static Future verifyChain() => api.get('/admin/traceability/verify');
}

class ReviewApi {
  static Future create(Map<String, dynamic> data) => api.post('/reviews', data: data);
  static Future getByProduct(String productId) => api.get('/products/$productId/reviews');
}

class UserApi {
  static Future getAll({Map<String, dynamic>? params}) => api.get('/admin/users', queryParameters: params);
  static Future verify(String id) => api.put('/admin/users/$id/verify');
  static Future create(Map<String, dynamic> data) => api.post('/admin/users', data: data);
}

class ShrimpTypeApi {
  static Future getAll() => api.get('/shrimp-types');
  static Future create(Map<String, dynamic> data) => api.post('/admin/shrimp-types', data: data);
  static Future update(String id, Map<String, dynamic> data) => api.put('/admin/shrimp-types/$id', data: data);
  static Future delete(String id) => api.delete('/admin/shrimp-types/$id');
}

class DashboardApi {
  static Future getAdmin() => api.get('/admin/dashboard');
  static Future getPetambak() => api.get('/dashboard/petambak');
  static Future getLogistik() => api.get('/dashboard/logistik');
  static Future getKonsumen() => api.get('/dashboard/konsumen');
}
