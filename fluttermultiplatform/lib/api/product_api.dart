import 'api_client.dart';

class ProductApi {
  static Future getMarketplace({Map<String, dynamic>? params}) => api.get('/products', queryParameters: params);
  static Future getProduct(String id) => api.get('/products/$id');
  static Future getMyProducts() => api.get('/products/my');
  static Future create(Map<String, dynamic> data) => api.post('/products', data: data);
  static Future update(String id, Map<String, dynamic> data) => api.put('/products/$id', data: data);
  static Future delete(String id) => api.delete('/products/$id');
  static Future getReviews(String id) => api.get('/products/$id/reviews');
}
