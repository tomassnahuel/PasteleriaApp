import 'package:sqflite/sqflite.dart';
import '../models/calculo_guardado.dart';
import 'app_database.dart';

class CalculoGuardadoDao {
  Future<void> insertar(CalculoGuardado calculo) async {
    final db = await AppDatabase.instance.database;

    await db.insert(
      'calculos_guardados',
      calculo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CalculoGuardado>> obtenerTodos() async {
    final db = await AppDatabase.instance.database;

    final maps = await db.query(
      'calculos_guardados',
      orderBy: 'fecha DESC',
    );

    return maps
        .map((m) => CalculoGuardado.fromMap(m))
        .toList();
  }

Future<void> eliminarCalculo(int id) async {
  final db = await AppDatabase.instance.database;
  await db.delete(
    'calculos_guardados',
    where: 'id = ?',
    whereArgs: [id],
  );
}

}
