class ItemPresupuesto {
  String producto;
  int cantidad;
  double precioUnitario;
  String detalle;

  ItemPresupuesto({
    this.producto = '',
    this.cantidad = 1,
    this.precioUnitario = 0,
    this.detalle = '',
  });

  double get subtotal => cantidad * precioUnitario;
}
