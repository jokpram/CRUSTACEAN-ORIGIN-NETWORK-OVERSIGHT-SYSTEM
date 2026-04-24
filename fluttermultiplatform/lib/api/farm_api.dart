import 'api_client.dart';

class FarmApi {
  static Future create(Map<String, dynamic> data) => api.post('/farms', data: data);
  static Future getMyFarms() => api.get('/farms');
  static Future getFarm(String id) => api.get('/farms/$id');
  static Future update(String id, Map<String, dynamic> data) => api.put('/farms/$id', data: data);
  static Future delete(String id) => api.delete('/farms/$id');
  static Future createPond(String farmId, Map<String, dynamic> data) => api.post('/farms/$farmId/ponds', data: data);
  static Future getPonds(String farmId) => api.get('/farms/$farmId/ponds');
}

class CultivationApi {
  static Future create(Map<String, dynamic> data) => api.post('/cultivations', data: data);
  static Future getMyCycles() => api.get('/cultivations');
  static Future getCycle(String id) => api.get('/cultivations/$id');
  static Future update(String id, Map<String, dynamic> data) => api.put('/cultivations/$id', data: data);
}

class HarvestApi {
  static Future create(Map<String, dynamic> data) => api.post('/harvests', data: data);
  static Future getMyHarvests() => api.get('/harvests');
}

class BatchApi {
  static Future create(Map<String, dynamic> data) => api.post('/batches', data: data);
  static Future getMyBatches() => api.get('/batches');
  static Future getByCode(String code) => api.get('/batches/$code');
}
