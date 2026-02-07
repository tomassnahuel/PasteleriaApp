import 'insumo.dart';

class Receta {
  final int? id;
  String nombre;
  List<RecetaInsumo> insumos;
  int porciones;
  String descripcion;

  Receta({
    this.id, 
    required this.nombre, 
    this.descripcion = '',
    this.porciones = 1,
    this.insumos = const[],
    
    });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'porciones': porciones,
      // Los insumos se guardan en otra tabla, no acá directamente
    };
  }

  factory Receta.fromMap(Map<String, dynamic> map) {
  return Receta(
    id: map['id'],
    nombre: map['nombre'],
    descripcion: map['descripcion'] ?? '',
    porciones: map['porciones'],
    insumos: [], // se cargan después desde receta_ingredientes
  );
}

  double costoTotal() {
    return insumos.fold(0, (total, i) => total + i.costo());
  }
}

// Relación Receta ↔ Insumo con cantidad usada
class RecetaInsumo {
  final Insumo insumo;
  double cantidad;
  String unidadReceta; 

  RecetaInsumo({
    required this.insumo,
    required this.cantidad,
    String? unidadReceta,
  }) : unidadReceta = unidadReceta ?? insumo.unidad;

  double costo() {
// Convertision a unidad base del insumo. REVISAR
  double factor = _factorConversion(unidadReceta, insumo.unidad);
  return insumo.precioUnitario * cantidad * factor;
  }

  double _factorConversion(String from, String to) {
    if (from == to) return 1.0;
    if (from == 'kg' && to == 'g') return 1000.0;
    if (from == 'g' && to == 'kg') return 0.001;
    if (from == 'Litro' && to == 'ml') return 1000.0;
    if (from == 'ml' && to == 'Litro') return 0.001;
    // Agregar más conversiones si es necesario
    return 1;
  }
}
