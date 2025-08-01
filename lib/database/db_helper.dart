// lib/database/db_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:kinesiology_app/models/user.dart';
import 'package:kinesiology_app/models/fms_test.dart';

// Clase para manejar todas las operaciones de la base de datos
class DatabaseHelper {
  static Database? _database; // Instancia de la base de datos
  static final DatabaseHelper _instance = DatabaseHelper._internal(); // Singleton

  // Constructor interno para el singleton
  DatabaseHelper._internal();

  // Factory constructor para devolver la misma instancia
  factory DatabaseHelper() => _instance;

  // Getter para la instancia de la base de datos
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await initDb(); // Si no está inicializada, la inicializa
    return _database!;
  }

  // Inicializa la base de datos
  Future<Database> initDb() async {
    final databasePath = await getDatabasesPath(); // Obtiene la ruta de la base de datos
    final path = join(databasePath, 'kinesiology.db'); // Une la ruta con el nombre del archivo de la DB

    // Abre la base de datos, si no existe, la crea llamando a onCreate
    return await openDatabase(
      path,
      version: 1, // Versión de la base de datos
      onCreate: _onCreate, // Función para crear tablas
    );
  }

  // Crea las tablas en la base de datos
  Future<void> _onCreate(Database db, int version) async {
    // Tabla de usuarios
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        address TEXT,
        dni TEXT UNIQUE,
        gender TEXT,
        age INTEGER,
        primarySport TEXT,
        dominantHemisphere TEXT,
        phone TEXT,
        weight REAL,
        height REAL,
        primaryOccupation TEXT
      )
    ''');

    // Tabla de tests FMS
    await db.execute('''
      CREATE TABLE fms_tests(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        date TEXT,
        rawScore INTEGER,
        totalScore INTEGER,
        comments TEXT,
        exercisesResults TEXT, -- Almacena los resultados de los ejercicios como un JSON String
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
  }

  // --- Operaciones CRUD para Usuarios ---

  // Inserta un nuevo usuario
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  // Obtiene todos los usuarios
  Future<List<User>> getUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  // Actualiza un usuario existente
  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Elimina un usuario por su ID
  Future<int> deleteUser(int id) async {
    final db = await database;
    // La eliminación en cascada en fms_tests se maneja con FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Operaciones CRUD para Tests FMS ---

  // Inserta un nuevo test FMS
  Future<int> insertFmsTest(FmsTest test) async {
    final db = await database;
    return await db.insert('fms_tests', test.toMap());
  }

  // Obtiene todos los tests FMS para un usuario específico
  Future<List<FmsTest>> getFmsTestsForUser(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'fms_tests',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC', // Ordenar por fecha descendente
    );
    return List.generate(maps.length, (i) => FmsTest.fromMap(maps[i]));
  }

  // Actualiza un test FMS existente
  Future<int> updateFmsTest(FmsTest test) async {
    final db = await database;
    return await db.update(
      'fms_tests',
      test.toMap(),
      where: 'id = ?',
      whereArgs: [test.id],
    );
  }

  // Elimina un test FMS por su ID
  Future<int> deleteFmsTest(int id) async {
    final db = await database;
    return await db.delete(
      'fms_tests',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Cierra la base de datos (generalmente no se usa en aplicaciones móviles)
  Future<void> closeDb() async {
    final db = await database;
    db.close();
    _database = null; // Resetea la instancia para que se inicialice de nuevo si se necesita
  }
}