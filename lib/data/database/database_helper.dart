import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  
  factory DatabaseHelper() => _instance;
  
  DatabaseHelper._internal();
  
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      path.join(dbPath, 'medioambiente.db'),
      version: 1,
      onCreate: _onCreate,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    // Tabla de usuarios
    await db.execute('''
      CREATE TABLE usuarios(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cedula TEXT UNIQUE,
        nombre TEXT,
        email TEXT UNIQUE,
        password TEXT,
        telefono TEXT,
        token TEXT,
        fecha_registro TEXT
      )
    ''');
    
    // Tabla de reportes
    await db.execute('''
      CREATE TABLE reportes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        codigo TEXT,
        titulo TEXT,
        descripcion TEXT,
        foto TEXT,
        latitud REAL,
        longitud REAL,
        fecha TEXT,
        estado TEXT DEFAULT 'Pendiente',
        comentario TEXT,
        categoria TEXT,
        urgencia TEXT,
        usuario_id INTEGER,
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
      )
    ''');
    
    // Tabla de favoritos
    await db.execute('''
      CREATE TABLE favoritos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo TEXT,
        item_id INTEGER,
        datos TEXT,
        usuario_id INTEGER,
        fecha_agregado TEXT,
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
      )
    ''');
  }
  
  // Métodos para usuarios
  Future<int> insertUsuario(Map<String, dynamic> usuario) async {
    final db = await database;
    return await db.insert('usuarios', usuario);
  }
  
  Future<List<Map<String, dynamic>>> getUsuarios() async {
    final db = await database;
    return await db.query('usuarios');
  }
  
  Future<Map<String, dynamic>?> getUsuario(String email) async {
    final db = await database;
    final result = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first : null;
  }
  
  // Métodos para reportes
  Future<int> insertReporte(Map<String, dynamic> reporte) async {
    final db = await database;
    return await db.insert('reportes', reporte);
  }
  
  Future<List<Map<String, dynamic>>> getReportes() async {
    final db = await database;
    return await db.query('reportes', orderBy: 'fecha DESC');
  }
  
  Future<List<Map<String, dynamic>>> getReportesPorUsuario(int usuarioId) async {
    final db = await database;
    return await db.query(
      'reportes',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'fecha DESC',
    );
  }
  
  Future<int> updateReporteEstado(int id, String estado, String comentario) async {
    final db = await database;
    return await db.update(
      'reportes',
      {
        'estado': estado,
        'comentario': comentario,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Métodos para favoritos
  Future<int> agregarFavorito(Map<String, dynamic> favorito) async {
    final db = await database;
    return await db.insert('favoritos', favorito);
  }
  
  Future<List<Map<String, dynamic>>> getFavoritos(int usuarioId) async {
    final db = await database;
    return await db.query(
      'favoritos',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'fecha_agregado DESC',
    );
  }
  
  Future<int> eliminarFavorito(int id) async {
    final db = await database;
    return await db.delete(
      'favoritos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}