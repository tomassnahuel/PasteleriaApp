class Insumo {
  final int? id;
  final String nombre;
  final String unidad;
  final double precioUnitario;


Insumo ({

  this.id,
  required this.nombre,
  required this.unidad,
  required this.precioUnitario,

});

Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'unidad': unidad,
      'precio_unitario': precioUnitario,
    };
  }

factory Insumo.fromMap(Map<String, dynamic> map) {
    return Insumo(
      id: map['id'],
      nombre: map['nombre'],
      unidad: map['unidad'],
      precioUnitario: map['precio_unitario'],
    );
}
}