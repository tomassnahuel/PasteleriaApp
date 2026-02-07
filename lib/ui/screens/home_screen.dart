import 'package:flutter/material.dart';
import 'package:presupuestoapp/ui/screens/calculo_costos_screen.dart';
import 'package:presupuestoapp/ui/screens/historial_calculos_screen.dart';
import 'package:presupuestoapp/ui/screens/insumos_screen.dart';
import 'package:presupuestoapp/ui/screens/recetas_screen.dart';
import 'package:presupuestoapp/ui/screens/generar_presupuesto_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Presupuesto Pastelería'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MenuButton(
            title: 'Insumos',
            icon: Icons.inventory_2,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const InsumosScreen(),),);
              // próxima pantalla
            },
          ),
          _MenuButton(
            title: 'Recetas',
            icon: Icons.menu_book,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const RecetasScreen(),),);
            },
          ),
          _MenuButton(
            title: 'Cálculo de costos',
            icon: Icons.calculate,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CalculoCostosScreen(),),);
            },
          ),
          _MenuButton(
            title: 'Historial de costos',
            icon: Icons.history,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => HistorialCalculosScreen(),),);
            },
          ),
          _MenuButton(
            title: 'Generar presupuesto',
            icon: Icons.picture_as_pdf,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const GenerarPresupuestoScreen(),),);
            },
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuButton({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
