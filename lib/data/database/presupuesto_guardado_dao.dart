import 'package:sqflite/sqflite.dart';

import '../models/presupuesto_guardado.dart';
import 'app_database.dart';

class PresupuestoGuardadoDao {
  Future<void> insertar(PresupuestoGuardado presupuesto) async {
    final db = await AppDatabase.instance.database;
    await db.insert(
      'presupuestos_guardados',
      presupuesto.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PresupuestoGuardado>> obtenerTodos() async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(
      'presupuestos_guardados',
      orderBy: 'fecha DESC',
    );
    return maps.map(PresupuestoGuardado.fromMap).toList();
  }

  Future<void> eliminarPresupuesto(int id) async {
    final db = await AppDatabase.instance.database;
    await db.delete(
      'presupuestos_guardados',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

