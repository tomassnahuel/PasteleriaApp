/* import 'package:flutter/material.dart';
import '../../data/models/item_presupuesto.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../pdf/presupuesto_pdf.dart';


class GenerarPresupuestoScreen extends StatefulWidget {
  const GenerarPresupuestoScreen({super.key});

  @override
  State<GenerarPresupuestoScreen> createState() =>
      _GenerarPresupuestoScreenState();
}

class _GenerarPresupuestoScreenState
    extends State<GenerarPresupuestoScreen> {
  final _clienteController = TextEditingController();

  final List<ItemPresupuesto> _items = [];

  final _mensaje1Controller = TextEditingController(
    text:
        'Gracias por ponerse en contacto con nuestro emprendimiento y considerar nuestros servicios para su próximo evento.',
  );

  final _mensaje2Controller = TextEditingController(
    text:
        'Para confirmar su pedido, se requiere un anticipo del 50% del costo total. En caso de cancelación, el anticipo no será reembolsable.',
  );

  void _agregarItem() {
    setState(() {
      _items.add(ItemPresupuesto());
    });
  }

  void _eliminarItem(ItemPresupuesto item) {
    setState(() {
      _items.remove(item);
    });
  }

  double get _total {
    return _items.fold(
      0,
      (sum, item) => sum + item.subtotal,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generar presupuesto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // ============================
            // CLIENTE
            // ============================
            TextFormField(
              controller: _clienteController,
              decoration: const InputDecoration(
                labelText: 'Nombre del cliente',
              ),
            ),

            const SizedBox(height: 24),

            // ============================
            // PRODUCTOS
            // ============================
            Text(
              'Productos',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 8),

            ..._items.map((item) => _itemCard(item)),

            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _agregarItem,
                child: const Text('+ Agregar producto'),
              ),
            ),

            const SizedBox(height: 16),

            // ============================
            // TOTAL
            // ============================
            Card(
              color: Colors.pink.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '\$${_total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ============================
            // MENSAJE 1
            // ============================
            TextFormField(
              controller: _mensaje1Controller,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Mensaje inicial',
              ),
            ),

            const SizedBox(height: 16),

            // ============================
            // MENSAJE 2
            // ============================
            TextFormField(
              controller: _mensaje2Controller,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Mensaje final',
              ),
            ),

            const SizedBox(height: 32),

            // ============================
            // GENERAR PDF
            // ============================
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Generar presupuesto en PDF'),
              onPressed: ()async {
    final pdf = await PresupuestoPdf.generar(
      negocio: 'Mi Pastelería',
      telefono: '11 1234-5678',
      cliente: _clienteController.text,
      fecha: DateTime.now(),
      items: _items,
      mensaje1: _mensaje1Controller.text,
      mensaje2: _mensaje2Controller.text,
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  },
),
          ],
        ),
      ),
    );
  }

  // ============================
  // CARD DE ITEM
  // ============================
  Widget _itemCard(ItemPresupuesto item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Producto'),
              onChanged: (v) {
                setState(() {
                  item.producto = v;
                });
              },
            ),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: item.cantidad.toString(),
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Cantidad'),
                    onChanged: (v) {
                      setState(() {
                        item.cantidad = int.tryParse(v) ?? 1;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Precio unitario'),
                    onChanged: (v) {
                      setState(() {
                        item.precioUnitario =
                            double.tryParse(v) ?? 0;
                      });
                    },
                  ),
                ),
              ],
            ),

            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Detalle (opcional)',
              ),
              onChanged: (v) {
                item.detalle = v;
              },
            ),

            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _eliminarItem(item),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 */

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../data/models/item_presupuesto.dart';
import '../../pdf/presupuesto_pdf.dart';

class GenerarPresupuestoScreen extends StatefulWidget {
  const GenerarPresupuestoScreen({super.key});

  @override
  State<GenerarPresupuestoScreen> createState() =>
      _GenerarPresupuestoScreenState();
}

class _GenerarPresupuestoScreenState
    extends State<GenerarPresupuestoScreen> {
  final _clienteController = TextEditingController();

  final _mensaje1Controller = TextEditingController(
    text:
        'Gracias por ponerse en contacto con Mi Pastelería y considerar nuestros servicios para su próximo evento. Nos complace presentarle la siguiente cotización.',
  );

  final _mensaje2Controller = TextEditingController(
    text:
        'Para confirmar su pedido, se requiere un anticipo del 50% del costo total. Este anticipo debe abonarse dentro de los 15 días posteriores a la fecha de esta cotización. En caso de cancelación, el anticipo no será reembolsable.',
  );

  final _nombreNegocioController = TextEditingController(
    text: 'Ingresar Nombre',
  );

  final _telefonoController = TextEditingController(
    text: 'Ingresar Teléfono',
  );

  final List<ItemPresupuesto> _items = [];

 /*  double get _total =>
      _items.fold(0, (sum, item) => sum + item.subtotal); */
double get _total {
    return _items.fold(
      0,
      (sum, item) => sum + item.subtotal,
    );
  }
  void _agregarItem() {
    setState(() {
      _items.add(ItemPresupuesto());
    });
  }

  void _eliminarItem(ItemPresupuesto item) {
    setState(() {
      _items.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generar presupuesto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextFormField(
              controller: _clienteController,
              decoration:
                  const InputDecoration(labelText: 'Nombre del cliente'),
            ),

            const SizedBox(height: 24),

            Text(
              'Productos',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 8),
            ..._items.map(_itemCard),

            TextButton(
              onPressed: _agregarItem,
              child: const Text('+ Agregar producto'),
            ),

            const SizedBox(height: 16),

            Card(
              color: Colors.pink.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '\$ ${_total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            TextFormField(
              controller: _nombreNegocioController,
              maxLines: 1,
              decoration:
                  const InputDecoration(labelText: 'Nombre del negocio'),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _telefonoController,
              maxLines: 1,
              decoration:
                  const InputDecoration(labelText: 'Teléfono del negocio'),
            ),

            const SizedBox(height: 32),

            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Generar PDF'),
              onPressed: () async {
                final pdf = await PresupuestoPdf.generar(
                  negocio: _nombreNegocioController.text,
                  telefono: _telefonoController.text,
                  cliente: _clienteController.text,
                  fecha: DateTime.now(),
                  items: _items,
                  mensaje1: _mensaje1Controller.text,
                  mensaje2: _mensaje2Controller.text,
                );

                await Printing.layoutPdf(
                  onLayout: (format) async => pdf.save(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemCard(ItemPresupuesto item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextFormField(
              decoration:
                  const InputDecoration(labelText: 'Producto'),
              onChanged: (v) => item.producto = v,
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: item.cantidad.toString(),
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Cantidad'),
                    onChanged: (v) {
                      setState(() {
                        item.cantidad = int.tryParse(v) ?? 1;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Precio unitario'),
                      onChanged: (v) {
                        setState(() {
                          item.precioUnitario = double.tryParse(v) ?? 0;
                        });
                      },
                  ),
                ),
              ],
            ),
            TextFormField(
              decoration:
                  const InputDecoration(labelText: 'Detalle (opcional)'),
              onChanged: (v) => item.detalle = v,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _eliminarItem(item),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
