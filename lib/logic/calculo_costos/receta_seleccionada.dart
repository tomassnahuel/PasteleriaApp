import '../../data/models/receta.dart';

class RecetaSeleccionada {
  final Receta receta;
  int cantidad;

  RecetaSeleccionada({
    required this.receta,
    this.cantidad = 1,
  });

  double get costoUnitario {
    return receta.costoTotal();
  }

  double get costoTotal {
    return costoUnitario * cantidad;
  }
}
