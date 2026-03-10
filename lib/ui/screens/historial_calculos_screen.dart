import 'package:flutter/material.dart';

import '../../data/database/calculo_guardado_dao.dart';
import '../../data/models/calculo_guardado.dart';
import '../components/app_components.dart';
import '../theme/app_theme.dart';
import 'detalle_calculo_screen.dart';

class HistorialCalculosScreen extends StatefulWidget {
  const HistorialCalculosScreen({super.key});

  @override
  State<HistorialCalculosScreen> createState() => _HistorialCalculosScreenState();
}

class _HistorialCalculosScreenState extends State<HistorialCalculosScreen> {
  final _dao = CalculoGuardadoDao();
  late Future<List<CalculoGuardado>> _futureCalculos;

  @override
  void initState() {
    super.initState();
    _futureCalculos = _dao.obtenerTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Historial de cálculos'),
        backgroundColor: AppColors.surface,
      ),
      body: FutureBuilder<List<CalculoGuardado>>(
        future: _futureCalculos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return AppEmptyState(
              icon: Icons.history,
              message: 'No hay cálculos guardados.\nGuardá uno desde Cálculo de costos.',
            );
          }

          final calculos = snapshot.data!;
        
        calculos.sort((a, b) => b.fecha.compareTo(a.fecha));
        
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: calculos.length,
            itemBuilder: (context, i) {
              final c = calculos[i];
              return _CalculoCard(
                calculo: c,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetalleCalculoScreen(calculo: c),
                  ),
                ),
                onDelete: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Eliminar cálculo'),
                      content: const Text('¿Seguro que querés eliminar este cálculo?'),
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
                    await _dao.eliminarCalculo(c.id!);
                    if (mounted) {
                      setState(() {
                        _futureCalculos = _dao.obtenerTodos();
                      });
                    }
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _CalculoCard extends StatelessWidget {
  final CalculoGuardado calculo;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CalculoCard({
    required this.calculo,
    required this.onTap,
    required this.onDelete,
  });

  String _fmtFecha(DateTime f) {
    return '${f.day}/${f.month}/${f.year}';
  }

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
                const Icon(
                  Icons.receipt_long_outlined,
                  size: 20,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        calculo.nombre,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _fmtFecha(calculo.fecha),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${calculo.precioFinal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
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
