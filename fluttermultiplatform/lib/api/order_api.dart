import 'api_client.dart';

class OrderApi {
  static Future create(Map<String, dynamic> data) => api.post('/orders', data: data);
  static Future getMyOrders({Map<String, dynamic>? params}) => api.get('/orders', queryParameters: params);
  static Future getAll({Map<String, dynamic>? params}) => api.get('/admin/orders', queryParameters: params);
  static Future getOrder(String id) => api.get('/orders/$id');
  static Future cancel(String id) => api.put('/orders/$id/cancel');
  static Future getMySales({Map<String, dynamic>? params}) => api.get('/sales', queryParameters: params);
}
