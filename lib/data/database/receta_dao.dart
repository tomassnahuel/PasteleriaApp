import 'package:sqflite/sqflite.dart';
import 'app_database.dart';
import '../models/receta.dart';
import '../models/insumo.dart';

class RecetaDao {
  final dbProvider = AppDatabase.instance;

  
  // Insertar receta FALTA ACTUALIZAR LA RECETA AL GUARDAR
  /*Future<int> insertarReceta(Receta receta) async {
    final db = await dbProvider.database;

    // Inserta receta principal
    int recetaId = await db.insert(
      'recetas',
      receta.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Inserta los insumos relacionados 
    for (var ri in receta.insumos) {
      await db.insert(
        'receta_ingredientes',
        {
          'receta_id': recetaId,
          'insumo_id': ri.insumo.id,
          'cantidad': ri.cantidad,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    return recetaId;
  }*/

  Future<int> insertarReceta(Receta receta) async {
  final db = await dbProvider.database;
  int recetaId;

  if (receta.id != null) {
    // Ya existe: actualizar receta
    await db.update(
      'recetas',
      receta.toMap(),
      where: 'id = ?',
      whereArgs: [receta.id],
    );
    recetaId = receta.id!;

    // Primero, eliminar los insumos antiguos
    await db.delete(
      'receta_ingredientes',
      where: 'receta_id = ?',
      whereArgs: [recetaId],
    );
  } else {
    // Nueva receta: insertar
    recetaId = await db.insert(
      'recetas',
      receta.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Inserta los insumos actuales
  for (var ri in receta.insumos) {
    await db.insert(
      'receta_ingredientes',
      {
        'receta_id': recetaId,
        'insumo_id': ri.insumo.id,
        'cantidad': ri.cantidad,
        'unidad': ri.unidadReceta,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  return recetaId;
}


  // --------------------------
  // Obtener todas las recetas
  // --------------------------
  Future<List<Receta>> obtenerRecetas() async {
    final db = await dbProvider.database;

    // Traemos todas las recetas
    final recetasMaps = await db.query('recetas');

    List<Receta> recetas = [];

    for (var rMap in recetasMaps) {
      final receta = Receta.fromMap(rMap);

      // Traemos los insumos de cada receta
      final insumosMaps = await db.query(
        'receta_ingredientes',
        where: 'receta_id = ?',
        whereArgs: [receta.id],
      );

      List<RecetaInsumo> insumos = [];

      for (var imap in insumosMaps) {
        // Obtener info completa del insumo
        final insumoMap = await db.query(
          'insumos',
          where: 'id = ?',
          whereArgs: [imap['insumo_id']],
        );

        if (insumoMap.isNotEmpty) {
          final insumo = Insumo.fromMap(insumoMap.first);
          final cantidad = (imap['cantidad'] as num).toDouble();
          final unidadReceta = (imap['unidad'] as String?) ?? insumo.unidad; 
          insumos.add(RecetaInsumo(insumo: insumo, cantidad: cantidad, unidadReceta: unidadReceta));
        }
      }

      receta.insumos = insumos;
      recetas.add(receta);
    }
 
    return recetas;
  }

  // --------------------------
  // Eliminar receta
  // --------------------------
  Future<void> eliminarReceta(int id) async {
    final db = await dbProvider.database;

    //eliminamos los ingredientes
    await db.delete(
      'receta_ingredientes',
      where: 'receta_id = ?',
      whereArgs: [id],
    );

    //eliminamos la receta
    await db.delete(
      'recetas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
