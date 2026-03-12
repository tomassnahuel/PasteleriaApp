import 'package:flutter/material.dart';
import '../../data/database/insumo_dao.dart';
import '../../data/database/receta_dao.dart';
import '../../data/models/insumo.dart';
import '../../data/models/receta.dart';
import '../theme/app_theme.dart';

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
  String _descripcion = '';

  List<RecetaInsumo> _insumosSeleccionados = [];
  List<Insumo> _todosInsumos = [];

  final List<String> _unidadesPosibles = ['g', 'kg', 'ml', 'Litro', 'unidad'];

  @override
  void initState() {
    super.initState();

    if (widget.receta != null) {
      _nombre = widget.receta!.nombre;
      _descripcion = widget.receta!.descripcion;
      _insumosSeleccionados = List.from(widget.receta!.insumos);
    }

    _cargarInsumos();
  }

  Future<void> _cargarInsumos() async {
    final insumos = await _insumoDao.obtenerInsumos();
    setState(() => _todosInsumos = insumos);
  }

  void _agregarInsumo(Insumo insumo) {
    setState(() {
      _insumosSeleccionados.add(
        RecetaInsumo(
          insumo: insumo,
          cantidad: 0,
          unidadReceta: insumo.unidad,
        ),
      );
    });
  }

  void _eliminarInsumo(RecetaInsumo ri) {
    setState(() => _insumosSeleccionados.remove(ri));
  }

  Future<void> _guardarReceta() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final receta = Receta(
        id: widget.receta?.id,
        nombre: _nombre,
        descripcion: _descripcion,
        insumos: _insumosSeleccionados,
      );

      await _recetaDao.insertarReceta(receta);

      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  void _mostrarDialogoAgregarInsumo() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Agregar insumo'),
        content: DropdownButtonFormField<Insumo>(
          decoration: const InputDecoration(labelText: 'Seleccionar insumo'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.receta == null ? 'Nueva receta' : 'Editar receta'),
        backgroundColor: AppColors.surface,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      initialValue: _nombre,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la receta',
                        hintText: 'Ej: Torta de chocolate',
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Ingrese un nombre' : null,
                      onSaved: (value) => _nombre = value ?? '',
                    ),

                    const SizedBox(height: AppSpacing.md),

                    TextFormField(
                      initialValue: _descripcion,
                      decoration: const InputDecoration(
                        labelText: 'Descripción (opcional)',
                        hintText: 'Breve descripción del producto',
                      ),
                      maxLines: 2,
                      onSaved: (value) => _descripcion = value ?? '',
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    Row(
                      children: [
                        Text(
                          'Insumos',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed:
                              _todosInsumos.isEmpty ? null : _mostrarDialogoAgregarInsumo,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Agregar'),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    if (_insumosSeleccionados.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'Sin insumos. Tocá "Agregar" para sumar ingredientes.',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    else
                      ..._insumosSeleccionados.map(
                        (ri) => _InsumoRecetaTile(
                          ri: ri,
                          unidadesPosibles: _unidadesPosibles,
                          onCantidadChanged: (v) {
                            ri.cantidad = double.tryParse(v) ?? 0;
                            setState(() {});
                          },
                          onUnidadChanged: (v) {
                            if (v != null) {
                              setState(() => ri.unidadReceta = v);
                            }
                          },
                          onDelete: () => _eliminarInsumo(ri),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              color: AppColors.surface,
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _guardarReceta,
                    child: const Text('Guardar receta'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsumoRecetaTile extends StatelessWidget {
  final RecetaInsumo ri;
  final List<String> unidadesPosibles;
  final ValueChanged<String> onCantidadChanged;
  final ValueChanged<String?> onUnidadChanged;
  final VoidCallback onDelete;

  const _InsumoRecetaTile({
    required this.ri,
    required this.unidadesPosibles,
    required this.onCantidadChanged,
    required this.onUnidadChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E0D9)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              ri.insumo.nombre,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          SizedBox(
            width: 70,
            child: TextFormField(
              initialValue: ri.cantidad.toString(),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Cant',
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              onChanged: onCantidadChanged,
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          Expanded(
  flex: 2,
  child: DropdownButtonFormField<String>(
    value: ri.unidadReceta,
    decoration: const InputDecoration(
      labelText: 'Unid',
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    ),
    items: unidadesPosibles
        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
        .toList(),
    onChanged: onUnidadChanged,
  ),
),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            color: AppColors.error,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}