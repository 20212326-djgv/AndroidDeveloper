import 'dart:convert';

class MockApiService {
  Future<Map<String, dynamic>> get(String endpoint) async {
    // Simular retardo de red
    await Future.delayed(const Duration(seconds: 1));
    
    // Datos mock para diferentes endpoints
    switch (endpoint) {
      case 'noticias':
        return {
          'exito': true,
          'datos': [
            {
              'id': '1',
              'titulo': 'Ministerio lanza campaña de reforestación',
              'descripcion': 'Se plantarán 100,000 árboles',
              'fecha': '2025-11-20',
              'imagen': 'https://picsum.photos/400/300?random=1',
            },
          ],
        };
        
      case 'areas-protegidas':
        return {
          'exito': true,
          'datos': [
            {
              'id': '1',
              'nombre': 'Parque Nacional Los Haitises',
              'descripcion': 'Área protegida con manglares',
              'latitud': '19.0333',
              'longitud': '-69.5833',
              'imagen': 'https://picsum.photos/400/300?random=2',
            },
          ],
        };
        
      default:
        return {'exito': true, 'datos': []};
    }
  }
  
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));
    
    return {
      'exito': true,
      'mensaje': 'Operación exitosa',
      'codigo': 'REP-${DateTime.now().millisecondsSinceEpoch}',
    };
  }
}