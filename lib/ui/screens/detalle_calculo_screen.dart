import 'dart:convert';

import 'package:flutter/material.dart';

import '../../data/models/calculo_guardado.dart';

class DetalleCalculoScreen extends StatelessWidget {
  final CalculoGuardado calculo;

  const DetalleCalculoScreen({
    super.key,
    required this.calculo,
  });

  @override
  Widget build(BuildContext context) {
    final detalle = jsonDecode(calculo.detalleJson);

    final recetas = detalle['recetas'] as List<dynamic>;
    final extras = detalle['costos_extras'] as List<dynamic>;
    //final packaging = (detalle['packaging'] as num?)?.toDouble() ?? 0.0;
    final margenPct = (detalle['margen_pct'] as num).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: Text(calculo.nombre),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // ======================
            // RECETAS
            // ======================
            // EDICION: Agregado tarjeta con nombre, fecha y precio final
            Card(
  elevation: 2,
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          calculo.nombre,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Fecha: ${calculo.fecha.toLocal().toString().split(' ')[0]}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Text(
          'Precio final',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        Text(
          '\$${calculo.precioFinal.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  ),
),
const SizedBox(height: 24),



            Text('Recetas',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),

// EDICION: Cambiado a tarjetas para cada receta

...recetas.map((r) {
final cantidad = (r['cantidad'] as int?) ?? 1;

final total = ((r['total'] ?? r['costo']) as num).toDouble();

final unitario = r['precio_unitario'] != null
    ? (r['precio_unitario'] as num).toDouble()
    : total / cantidad;


  return Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            r['nombre'],
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$cantidad x \$${unitario.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '\$${total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}),





// EDICION: Cambiado a tarjetas para cada receta
/* ...recetas.map((r) => Card(
  child: ListTile(
    title: Text(
      r['nombre'],
      style: const TextStyle(fontWeight: FontWeight.w500),
    ),
    trailing: Text(
      '\$${(r['costo'] as num).toStringAsFixed(2)}',
      style: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
)),
 */


/*             ...recetas.map((r) => ListTile(
                  title: Text(r['nombre']),
                  trailing: Text(
                    '\$${(r['costo'] as num).toStringAsFixed(2)}',
                  ),
                )), */

            const Divider(height: 32),

            // ======================
            // COSTOS EXTRAS
            // ======================

            Text('Costos extras',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),

// EDICION: Cambiado a tarjetas para cada costo extra

...extras
    .where((e) => (e['precio'] as num) > 0)
    .map((e) => Card(
          child: ListTile(
            title: Text(e['nombre']),
            trailing: Text(
              '\$${(e['precio'] as num).toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        )),

          /*   ...extras.map((e) => ListTile(
                  title: Text(e['nombre']),
                  trailing: Text(
                    '\$${(e['precio'] as num).toStringAsFixed(2)}',
                  ),
                )),
 */
            //if (packaging > 0) ...[
            //  const Divider(),
            //  _fila('Packaging', packaging),
            //],

            const Divider(height: 32),

            // ======================
            // RESUMEN
            // ======================

// EDICION: Resumen en tarjeta            

Card(
  elevation: 2,
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Resumen',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),

        _fila('Subtotal recetas', calculo.subtotalRecetas),
        _fila('Subtotal extras', calculo.subtotalExtras),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Margen'),
              Text('${margenPct.toStringAsFixed(0)} %'),
            ],
          ),
        ),

        const Divider(height: 24),
        _fila('Precio final', calculo.precioFinal, bold: true),
      ],
    ),
  ),
),


/*             Text('Resumen',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),

            _fila('Subtotal recetas', calculo.subtotalRecetas),
            _fila('Subtotal extras', calculo.subtotalExtras),
            Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    const Text('Margen'),
    Text('${margenPct.toStringAsFixed(0)} %'),
  ],
),

            const Divider(),
            _fila('Precio final', calculo.precioFinal, bold: true), */
          ],
        ),
      ),
    );
  }

  Widget _fila(String label, double valor, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '\$${valor.toStringAsFixed(2)}',
            style: bold
                ? const TextStyle(fontWeight: FontWeight.bold)
                : null,
          ),
        ],
      ),
    );
  }
}
