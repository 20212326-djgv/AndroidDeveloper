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

  // Usuarios de prueba para desarrollo/demo
  final Map<String, Map<String, dynamic>> _usuariosPrueba = {
    'admin@medioambiente.gob.do': {
      'password': 'Admin123',
      'nombre': 'Administrador',
      'rol': 'Administrador',
      'cedula': '00100000001',
      'telefono': '8090000001',
    },
    'voluntario@itla.edu.do': {
      'password': 'Voluntario2025',
      'nombre': 'Juan Pérez',
      'rol': 'Voluntario',
      'cedula': '00200000002',
      'telefono': '8090000002',
    },
    'usuario@test.com': {
      'password': 'Test123',
      'nombre': 'Usuario de Prueba',
      'rol': 'Usuario',
      'cedula': '00300000003',
      'telefono': '8090000003',
    },
    'demo@medioambiente.gob.do': {
      'password': 'Demo2025',
      'nombre': 'Usuario Demo',
      'rol': 'Demo',
      'cedula': '00400000004',
      'telefono': '8090000004',
    },
    'test@test.com': {
      'password': '123456',
      'nombre': 'Test User',
      'rol': 'Test',
      'cedula': '00500000005',
      'telefono': '8090000005',
    },
  };

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

  // Login - Versión mejorada con usuarios de prueba
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 800));
      
      // OPCIÓN 1: Verificar si es usuario de prueba
      if (_usuariosPrueba.containsKey(email)) {
        final usuarioPrueba = _usuariosPrueba[email]!;
        
        if (usuarioPrueba['password'] == password) {
          // Login exitoso con usuario de prueba
          final token = 'token_prueba_${DateTime.now().millisecondsSinceEpoch}';
          
          final db = await database;
          
          // Insertar o actualizar usuario en la base de datos
          await db.insert(
            'usuarios',
            {
              'email': email,
              'nombre': usuarioPrueba['nombre'],
              'cedula': usuarioPrueba['cedula'],
              'telefono': usuarioPrueba['telefono'],
              'password': password,
              'token': token,
              'fecha_registro': DateTime.now().toIso8601String(),
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          
          _isLoggedIn = true;
          _currentUser = {
            'email': email,
            'nombre': usuarioPrueba['nombre'],
            'rol': usuarioPrueba['rol'],
            'cedula': usuarioPrueba['cedula'],
            'telefono': usuarioPrueba['telefono'],
            'token': token,
          };
          
          notifyListeners();
          
          return {
            'exito': true,
            'mensaje': 'Login exitoso',
            'token': token,
          };
        } else {
          return {
            'exito': false,
            'mensaje': 'Contraseña incorrecta',
          };
        }
      }
      
      // OPCIÓN 2: Buscar en base de datos existente
      final db = await database;
      final usuarios = await db.query(
        'usuarios',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );
      
      if (usuarios.isNotEmpty) {
        // Usuario encontrado en base de datos
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
      
      // OPCIÓN 3: Aceptar cualquier email válido (modo demo)
      if (email.contains('@') && password.length >= 6) {
        final token = 'token_demo_${DateTime.now().millisecondsSinceEpoch}';
        
        final db = await database;
        
        await db.insert(
          'usuarios',
          {
            'email': email,
            'nombre': 'Usuario Demo',
            'cedula': '00000000000',
            'telefono': '0000000000',
            'password': password,
            'token': token,
            'fecha_registro': DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        
        _isLoggedIn = true;
        _currentUser = {
          'email': email,
          'nombre': 'Usuario Demo',
          'rol': 'Usuario',
          'token': token,
        };
        
        notifyListeners();
        
        return {
          'exito': true,
          'mensaje': 'Login exitoso (modo demo)',
          'token': token,
        };
      }
      
      return {
        'exito': false,
        'mensaje': 'Credenciales inválidas. Use: demo@medioambiente.gob.do / Demo2025',
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
        'mensaje': 'Registro exitoso como voluntario',
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
      
      // Verificar si el email existe
      final db = await database;
      final usuarios = await db.query(
        'usuarios',
        where: 'email = ?',
        whereArgs: [email],
      );
      
      if (usuarios.isEmpty && !_usuariosPrueba.containsKey(email)) {
        return {
          'exito': false,
          'mensaje': 'Email no registrado',
        };
      }
      
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

  // Método para obtener credenciales de demo (útil para presentaciones)
  Map<String, String> getCredencialesDemo() {
    return {
      'Administrador': 'admin@medioambiente.gob.do / Admin123',
      'Voluntario': 'voluntario@itla.edu.do / Voluntario2025',
      'Demo': 'demo@medioambiente.gob.do / Demo2025',
      'Test Simple': 'test@test.com / 123456',
      'Usuario Genérico': 'cualquier@email.com / cualquier123',
    };
  }

  // Método para limpiar datos de prueba (solo desarrollo)
  Future<void> limpiarDatosPrueba() async {
    try {
      final db = await database;
      await db.delete('usuarios');
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      
      _isLoggedIn = false;
      _currentUser = null;
      
      notifyListeners();
      
      if (kDebugMode) {
        print('Datos de prueba limpiados');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error limpiando datos: $e');
      }
    }
  }
}