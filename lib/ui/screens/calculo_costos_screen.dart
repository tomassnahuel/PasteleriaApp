import 'package:flutter/material.dart';

import '../../data/database/receta_dao.dart';
import '../../data/models/receta.dart';

import '../../logic/calculo_costos/receta_seleccionada.dart';
import '../../logic/calculo_costos/costo_extra.dart';
import '../../logic/calculo_costos/calculo_costos_service.dart';

import '../../data/database/calculo_guardado_dao.dart';
import '../../data/models/calculo_guardado.dart';
import 'dart:convert';


class CalculoCostosScreen extends StatefulWidget {
  const CalculoCostosScreen({super.key});

  @override
  State<CalculoCostosScreen> createState() => _CalculoCostosScreenState();
}

class _CalculoCostosScreenState extends State<CalculoCostosScreen> {
  final RecetaDao _recetaDao = RecetaDao();
  final CalculoGuardadoDao _calculoDao = CalculoGuardadoDao();

  List<Receta> _todasLasRecetas = [];
  List<RecetaSeleccionada> _recetasSeleccionadas = [];
  List<CostoExtra> _costosExtras = [];

  double _margenGanancia = 50;

  @override
  void initState() {
    super.initState();
    _cargarRecetas();
  }

 Future<void> _guardarCalculo() async {
  if (_recetasSeleccionadas.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No hay recetas seleccionadas')),
    );
    return;
  }

  final nombreController = TextEditingController();

  final confirmar = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Guardar cálculo'),
      content: TextField(
        controller: nombreController,
        decoration: const InputDecoration(
          labelText: 'Nombre del cálculo',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Guardar'),
        ),
      ],
    ),
  );

  if (confirmar != true) return;

  final nombre = nombreController.text.trim();
  if (nombre.isEmpty) return;

  // ----------------------------
  // ARMADO DEL DETALLE (JSON)
  // ----------------------------
  final detalle = {
    'recetas': _recetasSeleccionadas.map((r) => {
      'id': r.receta.id,
      'nombre': r.receta.nombre,
      'cantidad': r.cantidad,
      'precio_unitario': r.costoUnitario,
      'costo': r.costoTotal,
    }).toList(),
    'costos_extras': _costosExtras.map((c) => {
      'nombre': c.nombre,
      'precio': c.precio,
    }).toList(),
    'packaging': _costosExtras
        .where((c) => c.nombre == 'Packaging')
        .map((c) => c.precio)
        .fold(0.0, (a, b) => a + b),
    'margen_pct': _margenGanancia,
  };

/*   final costoBase = CalculoCostosService.costoBase(
    recetas: _recetasSeleccionadas,
    extras: _costosExtras,
  ); */

  final subtotalRecetas = _recetasSeleccionadas.fold<double>(
    0,
    (sum, r) => sum + r.costoTotal,
  );

  final subtotalExtras = _costosExtras.fold<double>(
    0,
    (sum, c) => sum + c.precio,
  );

  final costoBase = subtotalRecetas + subtotalExtras;

  //final costoExtras = _costosExtras.fold<double>(0, (sum, c) => sum + c.precio);
  final precioFinal = CalculoCostosService.precioFinal(
    costoBase: costoBase,
    margenPct: _margenGanancia,
  );

  final calculo = CalculoGuardado(
    nombre: nombre,
    fecha: DateTime.now(),
    subtotalRecetas: subtotalRecetas,
    subtotalExtras: subtotalExtras,
    margenPct: _margenGanancia,
    precioFinal: precioFinal,
    detalleJson: jsonEncode(detalle),
  );

  await _calculoDao.insertar(calculo);

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Cálculo guardado correctamente')),
  );
}



  Future<void> _cargarRecetas() async {
    final recetas = await _recetaDao.obtenerRecetas();
    setState(() {
      _todasLasRecetas = recetas;
    });
  }

  void _agregarReceta(Receta receta) {
    final existe = _recetasSeleccionadas.any(
      (r) => r.receta.id == receta.id,
    );

    if (existe) return;

    setState(() {
      _recetasSeleccionadas.add(
        RecetaSeleccionada(receta: receta),
      );
    });
  }


  void _agregarCostoExtra() {
    setState(() {
      _costosExtras.add(
        CostoExtra(nombre: '', precio: 0),
      );
    });
  }

  Widget _fila(String label, double valor, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          '\$${valor.toStringAsFixed(2)}',
          style: bold
              ? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
              : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final costoBase = CalculoCostosService.costoBase(
      recetas: _recetasSeleccionadas,
      extras: _costosExtras,
    );

    final precioFinal = CalculoCostosService.precioFinal(
      costoBase: costoBase,
      margenPct: _margenGanancia,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cálculo de costos'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            children: [

            // =========================
            // RECETAS
            // =========================
            const Text('Recetas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButtonFormField<Receta>(
              hint: const Text('Agregar receta'),
              items: _todasLasRecetas.map((r) {
                return DropdownMenuItem(
                  value: r,
                  child: Text(r.nombre),
                );
              }).toList(),
              onChanged: (receta) {
                if (receta != null) _agregarReceta(receta);
              },
            ),

            const SizedBox(height: 8),

            ..._recetasSeleccionadas.map((rs) {
              return Row(
                children: [
                  Expanded(child: Text(rs.receta.nombre)),
                  SizedBox(
                    width: 60,
                    child: TextFormField(
                      initialValue: rs.cantidad.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Cant'),
                      onChanged: (v) {
                        setState(() {
                          rs.cantidad = int.tryParse(v) ?? 1;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('\$${rs.costoTotal.toStringAsFixed(2)}'),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      setState(() {
                        _recetasSeleccionadas.remove(rs);
                      });
                    }
                  )
                ],
              );
            }),

            const Divider(),

            // =========================
            // COSTOS EXTRA
            // =========================
            const Text('Costos extra', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ..._costosExtras.map((c) {
              return Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Concepto'),
                      onChanged: (v) => c.nombre = v,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Precio'),
                      onChanged: (v) {
                        setState(() {
                          c.precio = double.tryParse(v) ?? 0;
                        });
                      },
                    ),
                  ),
                ],
              );
            }),

            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _agregarCostoExtra,
                child: const Text('+ Agregar costo extra'),
              ),
            ),

            const Divider(),

            // =========================
            // PACKAGING
            // =========================
            TextFormField(
              initialValue: '0',
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Costo de packaging', prefixText: '\$'),
              onChanged: (v) {
                setState(() {
                  final precio = double.tryParse(v) ?? 0;
                  final existe = _costosExtras.indexWhere((c) => c.nombre == 'Packaging');
                  if (existe >= 0) {
                    _costosExtras[existe].precio = precio;
                  } else {
                    _costosExtras.add(CostoExtra(nombre: 'Packaging', precio: precio));
                  }
                });
              },
            ),

            // =========================
            // MARGEN
            // =========================
            TextFormField(
              initialValue: _margenGanancia.toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Margen de ganancia (%)'),
              onChanged: (v) {
                setState(() {
                  _margenGanancia = double.tryParse(v) ?? 0;
                });
              },
            ),

            const Divider(),

            // =========================
            // RESUMEN
            // =========================
            /*Text('Costo base: \$${costoBase.toStringAsFixed(2)}'),
            const SizedBox(height: 4),
            Text(
              'Precio final sugerido: \$${precioFinal.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),*/
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Resumen', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    _fila('Costo base', costoBase),
                    _fila('Margen (${_margenGanancia.toInt()}%)', precioFinal - costoBase),
                    const Divider(),
                    _fila('Precio final', precioFinal, bold: true),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Guardar cálculo'),
            onPressed: _guardarCalculo,
          ),
          ],
        ),
      ),
    ),
    );
  }
}
