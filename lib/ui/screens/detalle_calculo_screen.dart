import 'dart:convert';

import 'package:flutter/material.dart';

import '../../data/models/calculo_guardado.dart';
import '../components/app_components.dart';
import '../theme/app_theme.dart';

class DetalleCalculoScreen extends StatelessWidget {
  final CalculoGuardado calculo;

  const DetalleCalculoScreen({
    super.key,
    required this.calculo,
  });

  @override
  Widget build(BuildContext context) {
// Parseo Json
   Map<String, dynamic> detalle = {};

      try {
        detalle = jsonDecode(calculo.detalleJson);
      } catch (_) {}


    final recetas = (detalle['recetas'] ?? []) as List<dynamic>;
    final extras = (detalle['costos_extras'] ?? []) as List<dynamic>;
    final margenPct = ((detalle['margen_pct'] ?? calculo.margenPct) as num).toDouble();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(calculo.nombre),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSectionCard(
              title: calculo.nombre,
              children: [
                
                Row(
                  children: [
                      const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: AppColors.textMuted,
                      ),
                  const SizedBox(width: 6),
                    Text(
                      calculo.fecha.toLocal().toString().split(' ')[0],
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                AppSummaryRow(
                  label: 'Precio final',
                  value: calculo.precioFinal,
                  bold: true,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Recetas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...recetas.map((r) {
              final cantidad = (r['cantidad'] as int?) ?? 1;
              final total = ((r['total'] ?? r['costo']) as num).toDouble();
              final unitario = r['precio_unitario'] != null
                  ? (r['precio_unitario'] as num).toDouble()
                  : total / cantidad;

              return Container(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r['nombre'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '$cantidad unidad${cantidad > 1 ? "es" : ""} × \$${unitario.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Costos extras',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...extras
                .where((e) => (e['precio'] as num) > 0)
                .map((e) => Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE8E0D9)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            e['nombre'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '\$${(e['precio'] as num).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    )),
            const SizedBox(height: AppSpacing.lg),
            AppSectionCard(
              title: 'Resumen',
              children: [
                AppSummaryRow(label: 'Subtotal recetas', value: calculo.subtotalRecetas),
                AppSummaryRow(label: 'Subtotal extras', value: calculo.subtotalExtras),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Margen',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${margenPct.toStringAsFixed(0)} %',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSummaryRow(
  label: 'Ganancia',
  value: calculo.precioFinal - (calculo.subtotalRecetas + calculo.subtotalExtras),
),
                const Divider(height: AppSpacing.lg),
                AppSummaryRow(label: 'Precio final', value: calculo.precioFinal, bold: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
