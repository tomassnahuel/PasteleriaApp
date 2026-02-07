import 'package:flutter/material.dart';
import '../../data/database/insumo_dao.dart';
import '../../data/models/insumo.dart';

class InsumoFormScreen extends StatefulWidget {
  final Insumo? insumo;

  const InsumoFormScreen({
    super.key,
    this.insumo,
  });

  @override
  State<InsumoFormScreen> createState() => _InsumoFormScreenState();
}

class _InsumoFormScreenState extends State<InsumoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _unidadController = TextEditingController();
  final _precioController = TextEditingController();
  final List<String> _unidadesDisponibles = ['g','kg','ml', 'Litro', 'unidad']; //Revisar unidades ¿L == Litro?
  String? _unidadSeleccionada;

  final InsumoDao _dao = InsumoDao();

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final insumo = Insumo(
      id: widget.insumo?.id,
      nombre: _nombreController.text.trim(),
      unidad: _unidadSeleccionada!,
      precioUnitario: double.parse(_precioController.text),
    );

    await _dao.insertarInsumo(insumo);

    if (!mounted) return;
    Navigator.pop(context, true);
  }

@override
void initState() {
  super.initState();

  if (widget.insumo != null) {
    _nombreController.text = widget.insumo!.nombre;
    _unidadSeleccionada = widget.insumo!.unidad;
    _precioController.text = widget.insumo!.precioUnitario.toString();
  } else {
    _unidadSeleccionada = _unidadesDisponibles[0];
  }
}

  @override
  void dispose() {
    _nombreController.dispose();
    _unidadController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.insumo == null ? 'Agregar insumo' : 'Editar insumo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              DropdownButtonFormField<String>(
                initialValue: _unidadSeleccionada,
                decoration: const InputDecoration(labelText: 'Unidad'),
                items: _unidadesDisponibles.map((u) {
                  return DropdownMenuItem(
                  value: u,
                  child: Text(u),
                );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                  _unidadSeleccionada = value;
                });
                },
              validator: (value) => value == null || value.isEmpty ? 'Seleccione una unidad' : null,
),

              /*TextFormField(
                controller: _unidadController,
                decoration: const InputDecoration(labelText: 'Unidad (kg, g, un)'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),*/
              TextFormField(
                controller: _precioController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo obligatorio';
                  if (double.tryParse(v) == null) return 'Número inválido';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _guardar,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
