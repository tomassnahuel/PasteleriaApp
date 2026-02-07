class CalculoGuardado {
  int? id;
  String nombre;
  DateTime fecha;

  double subtotalRecetas;
  double subtotalExtras;
  double margenPct;
  double precioFinal;

  String detalleJson;

  CalculoGuardado({
    this.id,
    required this.nombre,
    required this.fecha,
    required this.subtotalRecetas,
    required this.subtotalExtras,
    required this.margenPct,
    required this.precioFinal,
    required this.detalleJson,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'fecha': fecha.toIso8601String(),
      'subtotal_recetas': subtotalRecetas,
      'subtotal_extras': subtotalExtras,
      'margen_pct': margenPct,
      'precio_final': precioFinal,
      'detalle_json': detalleJson,
    };
  }

  factory CalculoGuardado.fromMap(Map<String, dynamic> map) {
    return CalculoGuardado(
      id: map['id'],
      nombre: map['nombre'],
      fecha: DateTime.parse(map['fecha']),
      subtotalRecetas: map['subtotal_recetas'],
      subtotalExtras: map['subtotal_extras'],
      margenPct: map['margen_pct'],
      precioFinal: map['precio_final'],
      detalleJson: map['detalle_json'],
    );
  }
}
