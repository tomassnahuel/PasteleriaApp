import 'package:flutter/material.dart';
import '../../data/database/insumo_dao.dart';
import '../../data/database/receta_dao.dart';
import '../../data/models/receta.dart';
import '../../data/models/insumo.dart';

class RecetaFormScreen extends StatefulWidget {
  final Receta? receta;
  const RecetaFormScreen({super.key, this.receta});

  @override
  State<RecetaFormScreen> createState() => _RecetaFormScreenState();
}

class _RecetaFormScreenState extends State<RecetaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final RecetaDao _recetaDao = RecetaDao();
  final InsumoDao _insumoDao = InsumoDao();

  String _nombre = '';
  List<RecetaInsumo> _insumosSeleccionados = [];
  List<Insumo> _todosInsumos = [];
  String _descripcion = '';
  int _porciones = 1;

  @override
  void initState() {
    super.initState();
    if (widget.receta != null) {
      _nombre = widget.receta!.nombre;
      _descripcion = widget.receta!.descripcion;
      _porciones = widget.receta!.porciones;
      _insumosSeleccionados = List.from(widget.receta!.insumos);
    }
    _cargarInsumos();
  }

  Future<void> _cargarInsumos() async {
    final insumos = await _insumoDao.obtenerInsumos();
    setState(() {
      _todosInsumos = insumos;
    });
  }

  void _agregarInsumo(Insumo insumo) {
    setState(() {
      _insumosSeleccionados.add(RecetaInsumo(insumo: insumo, cantidad: 0, unidadReceta: insumo.unidad));
    });
  }

  void _eliminarInsumo(RecetaInsumo ri) {
    setState(() {
      _insumosSeleccionados.remove(ri);
    });
  }

  Future<void> _guardarReceta() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final receta = Receta(
        id: widget.receta?.id,
        nombre: _nombre,
        descripcion: _descripcion,
        porciones: _porciones,
        insumos: _insumosSeleccionados,
      );
      await _recetaDao.insertarReceta(receta);
      if (!mounted) return; // widget ya no está en pantalla
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.receta == null ? 'Nueva Receta' : 'Editar Receta')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _nombre,
                decoration: const InputDecoration(labelText: 'Nombre de la receta'),
                validator: (value) => value!.isEmpty ? 'Ingrese un nombre' : null,
                onSaved: (value) => _nombre = value!,
              ),
              const SizedBox(height: 16),

              TextFormField(
  initialValue: _descripcion,
  decoration: const InputDecoration(labelText: 'Descripción (opcional)'),
  onSaved: (value) => _descripcion = value ?? '',
),
const SizedBox(height: 16),
TextFormField(
  initialValue: _porciones.toString(),
  decoration: const InputDecoration(labelText: 'Porciones'),
  keyboardType: TextInputType.number,
  validator: (value) {
    if (value == null || value.isEmpty) return 'Ingrese porciones';
    final n = int.tryParse(value);
    if (n == null || n <= 0) return 'Porciones inválidas';
    return null;
  },
  onSaved: (value) => _porciones = int.parse(value!),
),

            TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Agregar insumo'),
                      content: DropdownButtonFormField<Insumo>(
                        hint: const Text('Seleccionar insumo'),
                        items: _todosInsumos.map((insumo) {
                          return DropdownMenuItem(
                            value: insumo,
                            child: Text(insumo.nombre),
                          );
                        }).toList(),
                        onChanged: (insumo) {
                          if (insumo != null) {
                            _agregarInsumo(insumo);
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                  );
                },
                child: const Text('Agregar Insumo'),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _insumosSeleccionados.length,
                  itemBuilder: (context, index) {
                    final ri = _insumosSeleccionados[index];
                    final List<String> unidadesPosibles = ['g','kg','ml', 'Litro', 'unidad'];
                    return Row(
                      children: [
                        Expanded(child: Text(ri.insumo.nombre)),
                        SizedBox(
                          width: 80,
                          child: TextFormField(
                            initialValue: ri.cantidad.toString(),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Cantidad'),
                            onChanged: (v) {
                              ri.cantidad = double.tryParse(v) ?? 0;
                            },
                          ),
                        ), 
                        SizedBox(
                          width: 100,
                          child: DropdownButtonFormField<String>(
                            initialValue: ri.unidadReceta,
                            items: unidadesPosibles.map((u) => DropdownMenuItem(
                              value: u,
                              child: Text(u),
                              )).toList(),
                              onChanged: (v) {
                                if (v != null) setState(()=> ri.unidadReceta = v);
                              },
                              /*return DropdownMenuItem(
                                value: u,
                                child: Text(u),
                              );
                            }).toList(),
                            onChanged: (v) {
                              if (v != null) setState(()=> ri.unidadReceta = v);
                            },*/
                            decoration: const InputDecoration(labelText: 'Unidad'),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _eliminarInsumo(ri),
                        ),
                      ],
                    );
                  },
                ),
              ),

  
              /* DropdownButtonFormField<Insumo>(
                hint: const Text('Agregar insumo'),
                items: _todosInsumos.map((insumo) {
                  return DropdownMenuItem(
                    value: insumo,
                    child: Text(insumo.nombre),
                  );
                }).toList(),
                onChanged: (insumo) {
                  if (insumo != null) _agregarInsumo(insumo);
                },
              ),*/
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _guardarReceta,
                child: const Text('Guardar Receta'),
              ), 
            ],
          ),
        ),
      ),
    );
  }
}
