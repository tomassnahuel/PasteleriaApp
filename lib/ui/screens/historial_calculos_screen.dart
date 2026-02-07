import 'package:flutter/material.dart';

import '../../data/database/calculo_guardado_dao.dart';
import '../../data/models/calculo_guardado.dart';
import 'detalle_calculo_screen.dart';


class HistorialCalculosScreen extends StatefulWidget {
  const HistorialCalculosScreen({super.key});

  @override
  State<HistorialCalculosScreen> createState() => _HistorialCalculosScreenState();
}

class _HistorialCalculosScreenState extends State<HistorialCalculosScreen> {
  final _dao = CalculoGuardadoDao();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de cálculos'),
      ),
      body: FutureBuilder<List<CalculoGuardado>>(
        future: _dao.obtenerTodos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No hay cálculos guardados'),
            );
          }

          final calculos = snapshot.data!;

          return ListView.builder(
            itemCount: calculos.length,
            itemBuilder: (context, i) {
              final c = calculos[i];

              return Card(
                child: ListTile(
                  onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => DetalleCalculoScreen(calculo: c),
    ),
  );
},
                  title: Text(c.nombre),
                  subtitle: Text(_fmtFecha(c.fecha)),
                  trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Text(
      '\$${c.precioFinal.toStringAsFixed(2)}',
      style: const TextStyle(fontWeight: FontWeight.bold),
    ),
        IconButton(
      icon: const Icon(Icons.delete, color: Color.fromARGB(255, 25, 25, 26)),
      onPressed: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Eliminar insumo'),
            content: const Text('¿Seguro que querés eliminar este insumo?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        );

        if (confirm == true) {
          await _dao.eliminarCalculo(c.id!);
          setState(() {});
        }
      },
    ),
  ],
),

                ),
              );
            },
          );
        },
      ),
    );
  }

  String _fmtFecha(DateTime f) {
    return '${f.day}/${f.month}/${f.year}';
  }
}
