import 'dart:convert';
import 'package:http/http.dart' as http;

class NetworkUtils {
  static Future<Map<String, dynamic>> get(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<Map<String, dynamic>> post(String url, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<Map<String, dynamic>> uploadFile(
    String url, 
    String filePath, 
    Map<String, String> fields,
  ) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      
      // Agregar archivo
      request.files.add(await http.MultipartFile.fromPath(
        'file', 
        filePath,
      ));
      
      // Agregar campos
      request.fields.addAll(fields);
      
      var response = await request.send();
      
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        return json.decode(responseData);
      } else {
        throw Exception('Error HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de subida: $e');
    }
  }

  static bool isOnline() {
    // Implementar lógica para verificar conexión
    return true;
  }
}