import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class AuthService extends ChangeNotifier {
  bool _isLoggedIn = false;
  Map<String, dynamic>? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get currentUser => _currentUser;

  // Database helper
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final db = await openDatabase(
      path.join(dbPath, 'medioambiente.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE usuarios('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'cedula TEXT UNIQUE, '
          'nombre TEXT, '
          'email TEXT UNIQUE, '
          'password TEXT, '
          'telefono TEXT, '
          'token TEXT, '
          'fecha_registro TEXT'
          ')',
        );
      },
      version: 1,
    );
    return db;
  }

  // Constructor
  AuthService() {
    _checkLoginStatus();
  }

  // Verificar estado de login
  Future<void> _checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token != null) {
        final db = await database;
        final usuario = await db.query(
          'usuarios',
          where: 'token = ?',
          whereArgs: [token],
        );
        
        if (usuario.isNotEmpty) {
          _isLoggedIn = true;
          _currentUser = usuario.first;
          notifyListeners();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking login status: $e');
      }
    }
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Simular llamada a API
      await Future.delayed(const Duration(seconds: 1));
      
      // En un caso real, aquí llamarías a tu API
      // Por ahora, simulamos un login exitoso si las credenciales no están vacías
      if (email.isNotEmpty && password.isNotEmpty) {
        final db = await database;
        
        // Buscar usuario en la base de datos
        final usuarios = await db.query(
          'usuarios',
          where: 'email = ? AND password = ?',
          whereArgs: [email, password],
        );
        
        if (usuarios.isEmpty) {
          // Usuario no encontrado, crear uno de ejemplo
          final token = 'token_${DateTime.now().millisecondsSinceEpoch}';
          
          await db.insert('usuarios', {
            'email': email,
            'nombre': 'Usuario de Prueba',
            'cedula': '00000000000',
            'telefono': '0000000000',
            'password': password,
            'token': token,
            'fecha_registro': DateTime.now().toIso8601String(),
          });
          
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          
          _isLoggedIn = true;
          _currentUser = {
            'email': email,
            'nombre': 'Usuario de Prueba',
            'token': token,
          };
          
          notifyListeners();
          
          return {
            'exito': true,
            'mensaje': 'Login exitoso',
            'token': token,
          };
        } else {
          // Usuario encontrado
          final usuario = usuarios.first;
          final token = 'token_${DateTime.now().millisecondsSinceEpoch}';
          
          // Actualizar token
          await db.update(
            'usuarios',
            {'token': token},
            where: 'id = ?',
            whereArgs: [usuario['id']],
          );
          
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          
          _isLoggedIn = true;
          _currentUser = usuario..['token'] = token;
          
          notifyListeners();
          
          return {
            'exito': true,
            'mensaje': 'Login exitoso',
            'token': token,
          };
        }
      }
      
      return {
        'exito': false,
        'mensaje': 'Credenciales inválidas',
      };
    } catch (e) {
      return {
        'exito': false,
        'mensaje': 'Error en el login: $e',
      };
    }
  }

  // Registro como voluntario
  Future<Map<String, dynamic>> registerVoluntario({
    required String cedula,
    required String nombre,
    required String email,
    required String password,
    required String telefono,
  }) async {
    try {
      final db = await database;
      
      // Verificar si el email ya existe
      final usuarios = await db.query(
        'usuarios',
        where: 'email = ?',
        whereArgs: [email],
      );
      
      if (usuarios.isNotEmpty) {
        return {
          'exito': false,
          'mensaje': 'El email ya está registrado',
        };
      }
      
      // Verificar si la cédula ya existe
      final cedulas = await db.query(
        'usuarios',
        where: 'cedula = ?',
        whereArgs: [cedula],
      );
      
      if (cedulas.isNotEmpty) {
        return {
          'exito': false,
          'mensaje': 'La cédula ya está registrada',
        };
      }
      
      // Crear usuario
      final token = 'token_${DateTime.now().millisecondsSinceEpoch}';
      
      await db.insert('usuarios', {
        'cedula': cedula,
        'nombre': nombre,
        'email': email,
        'password': password,
        'telefono': telefono,
        'token': token,
        'fecha_registro': DateTime.now().toIso8601String(),
      });
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      
      _isLoggedIn = true;
      _currentUser = {
        'cedula': cedula,
        'nombre': nombre,
        'email': email,
        'telefono': telefono,
        'token': token,
      };
      
      notifyListeners();
      
      return {
        'exito': true,
        'mensaje': 'Registro exitoso',
        'token': token,
      };
    } catch (e) {
      return {
        'exito': false,
        'mensaje': 'Error en el registro: $e',
      };
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      
      _isLoggedIn = false;
      _currentUser = null;
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error en logout: $e');
      }
    }
  }

  // Cambiar contraseña
  Future<Map<String, dynamic>> cambiarClave({
    required String claveActual,
    required String nuevaClave,
  }) async {
    try {
      if (!_isLoggedIn || _currentUser == null) {
        return {
          'exito': false,
          'mensaje': 'No hay usuario autenticado',
        };
      }
      
      final db = await database;
      final email = _currentUser!['email'];
      
      // Verificar contraseña actual
      final usuarios = await db.query(
        'usuarios',
        where: 'email = ? AND password = ?',
        whereArgs: [email, claveActual],
      );
      
      if (usuarios.isEmpty) {
        return {
          'exito': false,
          'mensaje': 'Contraseña actual incorrecta',
        };
      }
      
      // Actualizar contraseña
      await db.update(
        'usuarios',
        {'password': nuevaClave},
        where: 'email = ?',
        whereArgs: [email],
      );
      
      return {
        'exito': true,
        'mensaje': 'Contraseña cambiada exitosamente',
      };
    } catch (e) {
      return {
        'exito': false,
        'mensaje': 'Error al cambiar contraseña: $e',
      };
    }
  }

  // Recuperar contraseña
  Future<Map<String, dynamic>> recuperarClave(String email) async {
    try {
      // Simular envío de email
      await Future.delayed(const Duration(seconds: 1));
      
      return {
        'exito': true,
        'mensaje': 'Se ha enviado un correo para recuperar la contraseña',
      };
    } catch (e) {
      return {
        'exito': false,
        'mensaje': 'Error al recuperar contraseña: $e',
      };
    }
  }
}