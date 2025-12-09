import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://adamix.net/medioambiente/';
  
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return {
        'exito': false,
        'mensaje': 'Error de conexión: $e',
      };
    }
  }
  
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
        body: json.encode(data),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return {
        'exito': false,
        'mensaje': 'Error de conexión: $e',
      };
    }
  }
  
  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    final token = await _getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
  
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      try {
        return json.decode(response.body);
      } catch (e) {
        return {
          'exito': false,
          'mensaje': 'Error al procesar la respuesta',
        };
      }
    } else {
      return {
        'exito': false,
        'mensaje': 'Error ${response.statusCode}: ${response.reasonPhrase}',
      };
    }
  }
}