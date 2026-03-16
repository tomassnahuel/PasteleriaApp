class PresupuestoGuardado {
  int? id;
  String cliente;
  String negocio;
  String? telefono;
  DateTime fecha;
  double total;
  String filePath;
  String displayName;

  PresupuestoGuardado({
    this.id,
    required this.cliente,
    required this.negocio,
    this.telefono,
    required this.fecha,
    required this.total,
    required this.filePath,
    required this.displayName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cliente': cliente,
      'negocio': negocio,
      'telefono': telefono,
      'fecha': fecha.toIso8601String(),
      'total': total,
      'file_path': filePath,
      'display_name': displayName,
    };
  }

  factory PresupuestoGuardado.fromMap(Map<String, dynamic> map) {
    return PresupuestoGuardado(
      id: map['id'] as int?,
      cliente: map['cliente'] as String,
      negocio: map['negocio'] as String,
      telefono: map['telefono'] as String?,
      fecha: DateTime.parse(map['fecha'] as String),
      total: (map['total'] as num).toDouble(),
      filePath: map['file_path'] as String,
      displayName: map['display_name'] as String,
    );
  }
}

