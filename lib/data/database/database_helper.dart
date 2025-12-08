import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
    String path = join(await getDatabasesPath(), 'medioambiente.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cedula TEXT UNIQUE,
        nombre TEXT,
        email TEXT UNIQUE,
        password TEXT,
        telefono TEXT,
        token TEXT
      )
    ''');

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
        estado TEXT,
        comentario TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE favoritos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo TEXT,
        item_id INTEGER,
        datos TEXT
      )
    ''');
  }

  // Métodos CRUD para usuarios
  Future<int> insertUsuario(Map<String, dynamic> usuario) async {
    Database db = await database;
    return await db.insert('usuarios', usuario);
  }

  Future<Map<String, dynamic>?> getUsuario(String email) async {
    Database db = await database;
    List<Map> result = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Métodos para reportes
  Future<int> insertReporte(Map<String, dynamic> reporte) async {
    Database db = await database;
    return await db.insert('reportes', reporte);
  }

  Future<List<Map<String, dynamic>>> getReportes() async {
    Database db = await database;
    return await db.query('reportes', orderBy: 'fecha DESC');
  }
}