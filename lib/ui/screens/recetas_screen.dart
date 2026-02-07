import 'package:flutter/material.dart';
import '../../data/database/receta_dao.dart';
import '../../data/models/receta.dart';
import 'receta_form_screen.dart';
import 'receta_detail_screen.dart';

class RecetasScreen extends StatefulWidget {
  const RecetasScreen({super.key});

  @override
  State<RecetasScreen> createState() => _RecetasScreenState();
}

class _RecetasScreenState extends State<RecetasScreen> {
  final RecetaDao _dao = RecetaDao();
  List<Receta> _recetas = [];

  @override
  void initState() {
    super.initState();
    _cargarRecetas();
  }

  Future<void> _cargarRecetas() async {
    final recetas = await _dao.obtenerRecetas();
    setState(() {
      _recetas = recetas;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recetas'),
      ),
      body: ListView.builder(
        itemCount: _recetas.length,
        itemBuilder: (context, index) {
          final receta = _recetas[index];
          return ListTile(
            title: Text(receta.nombre),
            subtitle: Text('Costo total: \$${receta.costoTotal().toStringAsFixed(2)}'),
            
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => RecetaDetailScreen(receta: receta),),);
  },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecetaFormScreen(receta: receta),
                      ),
                    );
                    if (result == true) _cargarRecetas();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Eliminar receta'),
                        content: const Text('¿Seguro que querés eliminar esta receta?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancelar')),
                          TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Eliminar')),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await _dao.eliminarReceta(receta.id!);
                      _cargarRecetas();
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const RecetaFormScreen(),
            ),
          );
          if (result == true) _cargarRecetas();
        },
      ),
    );
  }
}
