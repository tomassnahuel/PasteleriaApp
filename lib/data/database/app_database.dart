import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  static Database? _database;

  AppDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'presupuestoapp.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE insumos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        unidad TEXT NOT NULL,
        precio_unitario REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE recetas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        descripcion TEXT,
        porciones INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE receta_ingredientes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        receta_id INTEGER NOT NULL,
        insumo_id INTEGER NOT NULL,
        cantidad REAL NOT NULL,
        unidad TEXT NOT NULL,
        FOREIGN KEY (receta_id) REFERENCES recetas(id),
        FOREIGN KEY (insumo_id) REFERENCES insumos(id)
      )
    ''');

  
    await db.execute('''
          CREATE TABLE calculos_guardados (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            fecha TEXT NOT NULL,
            subtotal_recetas REAL NOT NULL,
            subtotal_extras REAL NOT NULL,
            margen_pct REAL NOT NULL,
            precio_final REAL NOT NULL,
            detalle_json TEXT NOT NULL
          )
    ''');
  }
}
