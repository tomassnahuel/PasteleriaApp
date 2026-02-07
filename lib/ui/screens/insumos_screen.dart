import 'package:flutter/material.dart';
import '../../data/database/insumo_dao.dart';
import '../../data/models/insumo.dart';
import 'insumo_form_screen.dart';

class InsumosScreen extends StatefulWidget {
  const InsumosScreen({super.key});

  @override
  State<InsumosScreen> createState() => _InsumosScreenState();
}

class _InsumosScreenState extends State<InsumosScreen> {
  final InsumoDao _dao = InsumoDao();
  late Future<List<Insumo>> _insumosFuture;

  @override
  void initState() {
    super.initState();
    _cargarInsumos();
  }

  void _cargarInsumos() {
    _insumosFuture = _dao.obtenerInsumos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insumos'),
      ),
      body: FutureBuilder<List<Insumo>>(
        future: _insumosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar insumos'));
          }

          final insumos = snapshot.data ?? [];

          if (insumos.isEmpty) {
            return const Center(child: Text('No hay insumos cargados'));
          }

          return ListView.builder(
            itemCount: insumos.length,
            itemBuilder: (context, index) {
              final insumo = insumos[index];
              return ListTile(
                title: Text(insumo.nombre),
                subtitle: Text('${insumo.unidad} - \$${insumo.precioUnitario}'),
                trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    IconButton(
      icon: const Icon(Icons.edit, color: Color.fromARGB(255, 25, 25, 26)),
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InsumoFormScreen(insumo: insumo),
          ),
        );

        if (result == true) {
          setState(() {
            _cargarInsumos();
          });
        }
      },
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
          await _dao.eliminarInsumo(insumo.id!);
          setState(() {
            _cargarInsumos();
          });
        }
      },
    ),
  ],
),
);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const InsumoFormScreen(),),);
          if (result == true) {
            setState(() {
             _cargarInsumos(); 
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
