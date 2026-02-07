import 'receta_seleccionada.dart';
import 'costo_extra.dart';

class CalculoCostosService {

  // Subtotal recetas
  static double subtotalRecetas(List<RecetaSeleccionada> recetas) {
    return recetas.fold(0, (total, r) => total + r.costoTotal);
  }

  // Subtotal costos extra
  static double subtotalExtras(List<CostoExtra> extras) {
    return extras.fold(0, (total, e) => total + e.precio);
  }

  // Costo base total
  static double costoBase({
    required List<RecetaSeleccionada> recetas,
    required List<CostoExtra> extras,
  }) {
    return subtotalRecetas(recetas) + subtotalExtras(extras);
  }

  // Ganancia
  static double ganancia({
    required double costoBase,
    required double margenPct,
  }) {
    return costoBase * (margenPct / 100);
  }

  // Precio final sugerido
  static double precioFinal({
    required double costoBase,
    required double margenPct,
  }) {
    final g = ganancia(costoBase: costoBase, margenPct: margenPct);
    return costoBase + g;
  }
}
