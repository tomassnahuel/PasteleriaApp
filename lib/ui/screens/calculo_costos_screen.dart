import 'dart:convert';

import 'package:flutter/material.dart';

import '../../data/database/calculo_guardado_dao.dart';
import '../../data/database/receta_dao.dart';
import '../../data/models/calculo_guardado.dart';
import '../../data/models/receta.dart';
import '../../logic/calculo_costos/calculo_costos_service.dart';
import '../../logic/calculo_costos/costo_extra.dart';
import '../../logic/calculo_costos/receta_seleccionada.dart';
import '../components/app_components.dart';
import '../theme/app_theme.dart';

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
  final _packagingController = TextEditingController(text: '0');
  final _margenController = TextEditingController(text: '50');

  @override
  void initState() {
    super.initState();
    _cargarRecetas();
  }

  @override
  void dispose() {
    _packagingController.dispose();
    _margenController.dispose();
    super.dispose();
  }

/// Guarda el cálculo actual en la base de datos

  Future<void> _guardarCalculo() async {
    // no permitir guardar si no hay recetas
    if (_recetasSeleccionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay recetas seleccionadas')),
      );
      return;
    }

    final nombreController = TextEditingController();
  // pedir nombre del cálculo
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Guardar cálculo'),
        content: TextField(
          controller: nombreController,
          decoration: const InputDecoration(
            labelText: 'Nombre del cálculo',
            hintText: 'Ej: Pedido cumpleaños María',
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

    final subtotalRecetas = _recetasSeleccionadas.fold<double>(
      0,
      (sum, r) => sum + r.costoTotal,
    );

    final subtotalExtras = _costosExtras.fold<double>(
      0,
      (sum, c) => sum + c.precio,
    );

    final costoBase = subtotalRecetas + subtotalExtras;

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

/// Carga todas las recetas disponibles desde la DB
  Future<void> _cargarRecetas() async {
    final recetas = await _recetaDao.obtenerRecetas();
    setState(() => _todasLasRecetas = recetas);
  }

/// Agrega una receta al cálculo actual
  void _agregarReceta(Receta receta) {
    // evitar duplicados
    final existe = _recetasSeleccionadas.any((r) => r.receta.id == receta.id);
    if (existe) return;
    setState(() {
      _recetasSeleccionadas.add(RecetaSeleccionada(receta: receta));
    });
  }

  void _agregarCostoExtra() {
    setState(() {
      _costosExtras.add(CostoExtra(nombre: '', precio: 0));
    });
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Cálculo de costos'),
        backgroundColor: AppColors.surface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // padding dinámico para que el teclado no tape los inputs
          padding: EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            top: AppSpacing.md,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSectionCard(
                title: 'Recetas',
                children: [
                  DropdownButtonFormField<Receta>(
                    hint: const Text('Seleccionar receta'),
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
                  const SizedBox(height: AppSpacing.sm),
                  ..._recetasSeleccionadas.map((rs) => _RecetaSeleccionadaTile(
                        rs: rs,
                        onCantidadChanged: (v) {
                          setState(() {
                            rs.cantidad = int.tryParse(v) ?? 1;
                          });
                        },
                        onRemove: () {
                          setState(() => _recetasSeleccionadas.remove(rs));
                        },
                      )),
                ],
              ),
              const AppSectionSpacer(),
                AppSectionCard(
                  title: 'Costos extra',
                  children: [
                    ..._costosExtras.asMap().entries.map((entry) {
                      final index = entry.key;
                      final c = entry.value;

                      return Padding(
                        key: ValueKey(c), // clave única para este costo
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Concepto',
                                  hintText: 'Ej: Confites',
                                ),
                                onChanged: (v) => c.nombre = v,
                              ),
                            ),

                            const SizedBox(width: AppSpacing.sm),

                            SizedBox(
                              width: 100,
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Precio',
                                  prefixText: '\$ ',
                                ),
                                onChanged: (v) {
                                  setState(() {
                                    c.precio = double.tryParse(v) ?? 0;
                                  });
                                },
                              ),
                            ),

                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              color: AppColors.error,
                              onPressed: () {
                                setState(() {
                                  _costosExtras.removeAt(index); // elimina el correcto
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }),

                    TextButton.icon(
                      onPressed: _agregarCostoExtra,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Agregar costo extra'),
                    ),
                  ],
                ),

              const AppSectionSpacer(),
              AppSectionCard(
                title: 'Configuración',
                children: [
                  const SizedBox(height: AppSpacing.md),
                  // costo de packaging (se sincroniza con la lista de extras)
                  TextFormField(
                    controller: _packagingController,
                    keyboardType: TextInputType.number,
                    
                    decoration: const InputDecoration(
                      labelText: 'Costo de packaging',
                      prefixText: '\$ ',
                      hintText: '0',
                    ),
                    onChanged: (v) {
                  setState(() {
                    final precio = double.tryParse(v) ?? 0;

                    final index = _costosExtras.indexWhere(
                      (c) => c.nombre.toLowerCase() == 'packaging',
                    );
                    // Verificación de si existe packaging
                    if (index != -1) {
                      _costosExtras[index].precio = precio;
                    } else if (precio > 0) {
                      _costosExtras.add(
                        CostoExtra(nombre: 'Packaging', precio: precio),
                      );
                    }
                  });
                },

                  ),
                  const SizedBox(height: AppSpacing.md),
                  // % de ganancia
                  TextFormField(
                    controller: _margenController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Margen de ganancia (%)',
                      hintText: '50',
                    ),
                    onChanged: (v) {
                      setState(() {
                        _margenGanancia = double.tryParse(v) ?? 0;
                      });
                    },
                  ),
                ],
              ),
              const AppSectionSpacer(),
              AppSectionCard(
                title: 'Resumen',
                children: [
                  AppSummaryRow(label: 'Costo base', value: costoBase),
                  AppSummaryRow(
                    label: 'Margen (${_margenGanancia.toInt()}%)',
                    value: precioFinal - costoBase,
                  ),
                  const Divider(height: AppSpacing.lg),
                  AppSummaryRow(label: 'Precio final', value: precioFinal, bold: true),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save_outlined, size: 20),
                  label: const Text('Guardar cálculo'),
                  onPressed: _guardarCalculo,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecetaSeleccionadaTile extends StatelessWidget {
  final RecetaSeleccionada rs;
  final ValueChanged<String> onCantidadChanged;
  final VoidCallback onRemove;

  const _RecetaSeleccionadaTile({
    required this.rs,
    required this.onCantidadChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E0D9)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              rs.receta.nombre,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(
            width: 64,
            child: TextFormField(
              initialValue: rs.cantidad.toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cant',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              onChanged: onCantidadChanged,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 80,
            child: Text(
      '\$${rs.costoUnitario.toStringAsFixed(0)} c/u',
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.textMuted,
      ),
    ),
            
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            color: AppColors.error,
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
