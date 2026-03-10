import 'package:flutter/material.dart';
import '../../data/database/receta_dao.dart';
import '../../data/models/receta.dart';
import '../components/app_components.dart';
import '../theme/app_theme.dart';
import 'receta_detail_screen.dart';
import 'receta_form_screen.dart';

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
    setState(() => _recetas = recetas);
  }

  Future<void> _navegarAgregar() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RecetaFormScreen()),
    );
    if (result == true && mounted) _cargarRecetas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Recetas'),
        backgroundColor: AppColors.surface,
      ),
      body: _recetas.isEmpty
          ? AppEmptyState(
              icon: Icons.menu_book_outlined,
              message: 'No hay recetas.\nCreá la primera para comenzar.',
              actionLabel: 'Nueva receta',
              onAction: _navegarAgregar,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _recetas.length,
              itemBuilder: (context, index) {
                final receta = _recetas[index];
                return _RecetaCard(
                  receta: receta,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecetaDetailScreen(receta: receta),
                    ),
                  ),
                  onEdit: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecetaFormScreen(receta: receta),
                      ),
                    );
                    if (result == true && mounted) _cargarRecetas();
                  },
                  onDelete: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Eliminar receta'),
                        content: const Text('¿Seguro que querés eliminar esta receta?'),
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
                      await _dao.eliminarReceta(receta.id!);
                      if (mounted) _cargarRecetas();
                    }
                  },
                );
              },
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: _navegarAgregar,
              icon: const Icon(Icons.add),
              label: const Text('Nueva receta'),
              backgroundColor: AppColors.primary,
            ),
    );
  }
}

class _RecetaCard extends StatelessWidget {
  final Receta receta;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RecetaCard({
    required this.receta,
    required this.onTap,
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
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        receta.nombre,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Costo: \$${receta.costoTotal().toStringAsFixed(2)}',
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
