import 'package:flutter/material.dart';
import '../../data/models/receta.dart';

class RecetaDetailScreen extends StatelessWidget {
  final Receta receta;

  const RecetaDetailScreen({required this.receta, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(receta.nombre)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (receta.descripcion.isNotEmpty)
              Text('Descripción: ${receta.descripcion}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Porciones: ${receta.porciones}', style: const TextStyle(fontSize: 16)),
            const Divider(),
            const Text('Insumos:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: receta.insumos.length,
                itemBuilder: (context, index) {
                  final ri = receta.insumos[index];
                  return ListTile(
                    title: Text(ri.insumo.nombre),
                    subtitle: Text('${ri.cantidad} ${ri.unidadReceta} x \$${ri.insumo.precioUnitario.toStringAsFixed(2)}'),
                    trailing: Text('Total: \$${ri.costo().toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
            const Divider(),
            Text(
              'Costo total: \$${receta.costoTotal().toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
