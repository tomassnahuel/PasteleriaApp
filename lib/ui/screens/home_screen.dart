import 'package:flutter/material.dart';
import 'package:presupuestoapp/ui/components/app_components.dart';
import 'package:presupuestoapp/ui/screens/calculo_costos_screen.dart';
import 'package:presupuestoapp/ui/screens/generar_presupuesto_screen.dart';
import 'package:presupuestoapp/ui/screens/historial_calculos_screen.dart';
import 'package:presupuestoapp/ui/screens/insumos_screen.dart';
import 'package:presupuestoapp/ui/screens/recetas_screen.dart';
import 'package:presupuestoapp/ui/theme/app_theme.dart';

/// Pantalla principal: menú de navegación con tarjetas claras.
/// Jerarquía visual: iconos en contenedores, títulos legibles, áreas de toque amplias.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
/*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Presupuesto Pastelería'),
        backgroundColor: AppColors.surface,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            const SizedBox(height: AppSpacing.sm),
            AppMenuCard(
              title: 'Insumos',
              icon: Icons.inventory_2_outlined,
              iconColor: AppColors.primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InsumosScreen()),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppMenuCard(
              title: 'Recetas',
              icon: Icons.menu_book_outlined,
              iconColor: AppColors.secondaryDark,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RecetasScreen()),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppMenuCard(
              title: 'Cálculo de costos',
              icon: Icons.calculate_outlined,
              iconColor: AppColors.accent,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CalculoCostosScreen()),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppMenuCard(
              title: 'Historial de costos',
              icon: Icons.history,
              iconColor: AppColors.primaryLight,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistorialCalculosScreen()),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppMenuCard(
              title: 'Generar presupuesto',
              icon: Icons.picture_as_pdf_outlined,
              iconColor: AppColors.secondary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GenerarPresupuestoScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        title: const Text("Costos de Pastelería"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// HERO
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cake_outlined, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Calculá tus costos",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Creá recetas, calculá precios y generá presupuestos profesionales.",
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              "Gestión",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [

                _MenuCard(
                  title: 'Insumos',
                  icon: Icons.inventory_2_outlined,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const InsumosScreen())),
                ),

                _MenuCard(
                  title: 'Recetas',
                  icon: Icons.menu_book_outlined,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RecetasScreen())),
                ),

                _MenuCard(
                  title: 'Costos',
                  icon: Icons.calculate_outlined,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CalculoCostosScreen())),
                ),

                _MenuCard(
                  title: 'Historial',
                  icon: Icons.history_outlined,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => HistorialCalculosScreen())),
                ),
              ],
            ),

            const SizedBox(height: 28),

            const Text(
              "Herramientas",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _PrimaryActionCard(
              title: "Generar Presupuesto PDF",
              subtitle: "Crea presupuestos listos para enviar a tus clientes.",
              icon: Icons.picture_as_pdf_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const GenerarPresupuestoScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: AppColors.primary),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13),
                  )
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16)
          ],
        ),
      ),
    );
  }
}