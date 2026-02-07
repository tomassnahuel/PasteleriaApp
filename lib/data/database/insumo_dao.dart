import 'package:sqflite/sqflite.dart';
import 'app_database.dart';
import '../models/insumo.dart';

class InsumoDao {
  Future<int> insertarInsumo(Insumo insumo) async {
    final db = await AppDatabase.instance.database;
    return await db.insert(
      'insumos',
      insumo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Insumo>> obtenerInsumos() async {
    final db = await AppDatabase.instance.database;
    final List<Map<String, dynamic>> maps =
        await db.query('insumos');

    return maps.map((map) => Insumo.fromMap(map)).toList();
  }

  Future<void> eliminarInsumo(int id) async {
    final db = await AppDatabase.instance.database;
    await db.delete(
      'insumos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
