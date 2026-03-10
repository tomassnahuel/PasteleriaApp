/*import 'package:flutter/material.dart';
import '../../data/models/receta.dart';
import '../components/app_components.dart';
import '../theme/app_theme.dart';

class RecetaDetailScreen extends StatelessWidget {
  final Receta receta;

  const RecetaDetailScreen({required this.receta, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(receta.nombre),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSectionCard(
              title: 'Información',
              children: [
                if (receta.descripcion.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      receta.descripcion,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                Row(
                  children: [
                    const Icon(Icons.restaurant, size: 18, color: AppColors.textMuted),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${receta.porciones} porciones',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Insumos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...receta.insumos.map((ri) => Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.all(AppSpacing.md),
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
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ri.insumo.nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${ri.cantidad} ${ri.unidadReceta} × \$${ri.insumo.precioUnitario.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${ri.costo().toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: AppSpacing.md),
            AppSectionCard(
              title: 'Costo total',
              children: [
                AppSummaryRow(
                  label: 'Total',
                  value: receta.costoTotal(),
                  bold: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}*/

import 'package:flutter/material.dart';
import '../../data/models/receta.dart';
import '../components/app_components.dart';
import '../theme/app_theme.dart';

class RecetaDetailScreen extends StatelessWidget {
  final Receta receta;

  const RecetaDetailScreen({
    required this.receta,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final total = receta.costoTotal();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(receta.nombre),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// COSTO TOTAL (métrica principal)
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Row(
      children: const [
        Icon(
          Icons.calculate_outlined,
          size: 18,
          color: AppColors.textSecondary,
        ),
        SizedBox(width: 6),
        Text(
          "Costo de producción",
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    ),
    const SizedBox(height: 6),
    Text(
      "\$${total.toStringAsFixed(2)}",
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    ),
  ],
),
              /*child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Costo de producción",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "\$${total.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),*/
            ),

            const SizedBox(height: AppSpacing.lg),

            /// INFORMACIÓN
            AppSectionCard(
              title: 'Detalles de la receta',
              children: [
                if (receta.descripcion.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      receta.descripcion,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                Row(
                  children: [
                    const Icon(
                      Icons.restaurant,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${receta.porciones} porciones',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            /// INGREDIENTES
            Text(
              'Ingredientes (${receta.insumos.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
            ),

            const SizedBox(height: AppSpacing.sm),

            ...receta.insumos.map(
              (ri) => Container(
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
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 4,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.kitchen_outlined,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(
                    ri.insumo.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    '${ri.cantidad} ${ri.unidadReceta}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: Text(
                    '\$${ri.costo().toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
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