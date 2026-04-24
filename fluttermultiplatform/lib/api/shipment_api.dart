import 'api_client.dart';

class PaymentApi {
  static Future createPayment(String orderId) => api.post('/payments/create', data: {'order_id': orderId});
  static Future getPayment(String orderId) => api.get('/payments/$orderId');
}

class ShipmentApi {
  static Future create(Map<String, dynamic> data) => api.post('/admin/shipments', data: data);
  static Future getMine() => api.get('/shipments');
  static Future getAll() => api.get('/admin/shipments');
  static Future updateStatus(String id, Map<String, dynamic> data) => api.put('/shipments/$id/status', data: data);
  static Future getLogs(String id) => api.get('/shipments/$id/logs');
}

class WithdrawalApi {
  static Future create(Map<String, dynamic> data) => api.post('/withdrawals', data: data);
  static Future getMine() => api.get('/withdrawals');
  static Future getAll() => api.get('/admin/withdrawals');
  static Future update(String id, Map<String, dynamic> data) => api.put('/admin/withdrawals/$id', data: data);
}
