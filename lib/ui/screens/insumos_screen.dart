import 'package:flutter/material.dart';
import '../../data/database/insumo_dao.dart';
import '../../data/models/insumo.dart';
import '../components/app_components.dart';
import '../theme/app_theme.dart';
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

  Future<void> _navegarAgregar() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const InsumoFormScreen()),
    );
    if (result == true && mounted) {
      setState(() => _cargarInsumos());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          children: const[
             Text(
          'Insumos',
          style: TextStyle(
            fontWeight: FontWeight.w600, 
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'Listado de insumos disponibles', 
          style: TextStyle(
            fontWeight: FontWeight.normal, 
            fontSize: 14,
            color: AppColors.textSecondary, 
          ),
        ),
          ],
        ),
      ),
      body: FutureBuilder<List<Insumo>>(
        future: _insumosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return AppEmptyState(
              icon: Icons.error_outline,
              message: 'Error al cargar insumos',
            );
          }

          final insumos = snapshot.data ?? [];

          if (insumos.isEmpty) {
            return AppEmptyState(
              icon: Icons.inventory_2_outlined,
              message: 'No hay insumos cargados.\nAgregá el primero para comenzar.',
              actionLabel: 'Agregar insumo',
              onAction: _navegarAgregar,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: insumos.length,
            itemBuilder: (context, index) {
              final insumo = insumos[index];
              return _InsumoCard(
                insumo: insumo,
                onEdit: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InsumoFormScreen(insumo: insumo),
                    ),
                  );
                  if (result == true && mounted) {
                    setState(() => _cargarInsumos());
                  }
                },
                onDelete: () async {
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
                          child: const Text('Eliminar', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await _dao.eliminarInsumo(insumo.id!);
                    if (mounted) setState(() => _cargarInsumos());
                  }
                },
              );
            },
          );
        },
      ),
floatingActionButton: FloatingActionButton.extended(
  onPressed: _navegarAgregar,
  icon: const Icon(Icons.add),
  label: const Text('Agregar'),
  backgroundColor: AppColors.primary,
),
    );
  }
}

class _InsumoCard extends StatelessWidget {
  final Insumo insumo;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _InsumoCard({
    required this.insumo,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                    
                  ),
                  child: const Icon(Icons.local_dining_outlined, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insumo.nombre,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '\$${insumo.precioUnitario.toStringAsFixed(2)} / ${insumo.unidad}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  color: AppColors.primary,
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: AppColors.error,
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
