import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../data/models/item_presupuesto.dart';
import '../../pdf/presupuesto_pdf.dart';
import '../components/app_components.dart';
import '../theme/app_theme.dart';

class GenerarPresupuestoScreen extends StatefulWidget {
  const GenerarPresupuestoScreen({super.key});

  @override
  State<GenerarPresupuestoScreen> createState() =>
      _GenerarPresupuestoScreenState();
} 

class _GenerarPresupuestoScreenState extends State<GenerarPresupuestoScreen> {
  final _clienteController = TextEditingController();

  final _mensaje1Controller = TextEditingController(
    text:
        'Gracias por ponerse en contacto con Mi Pastelería y considerar nuestros servicios para su próximo evento. Nos complace presentarle la siguiente cotización.',
  );

  final _mensaje2Controller = TextEditingController(
    text:
        'Para confirmar su pedido, se requiere un anticipo del 50% del costo total. Este anticipo debe abonarse dentro de los 15 días posteriores a la fecha de esta cotización. En caso de cancelación, el anticipo no será reembolsable.',
  );

  final _nombreNegocioController = TextEditingController(
    text: '',
  );

  final _telefonoController = TextEditingController(
    text: '',
  );

  final List<ItemPresupuesto> _items = [];

  double get _total {
    return _items.fold(0, (sum, item) => sum + item.subtotal);
  }

  void _agregarItem() {
    setState(() => _items.add(ItemPresupuesto()));
  }

  void _eliminarItem(ItemPresupuesto item) {
    setState(() => _items.remove(item));
  }

  @override
  void dispose() {
    _clienteController.dispose();
    _mensaje1Controller.dispose();
    _mensaje2Controller.dispose();
    _nombreNegocioController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

@override
void initState() {
  super.initState();
  _items.add(ItemPresupuesto());
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Generar presupuesto'),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSectionCard(
              title: 'Cliente',
              children: [
                TextFormField(
                  controller: _clienteController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del cliente',
                    hintText: 'Ej: María García',
                  ),
                ),
              ],
            ),
            const AppSectionSpacer(),
            AppSectionCard(
              title: 'Productos',
              children: [
                ..._items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;

                  return _ItemPresupuestoCard(
                    key: ValueKey(item), // Para poder eliminar correctamente
                    item: item,
                    onChanged: () => setState(() {}),
                    onDelete: () {
                      setState(() {
                        _items.removeAt(index);
                      });
                    },
                  );
                }),
                TextButton.icon(
                  onPressed: _agregarItem,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Agregar producto'),
                ),
              ],
            ),

            const AppSectionSpacer(),
            AppSectionCard(
              title: 'Total',
              children: [
                AppSummaryRow(
                  label: 'TOTAL',
                  value: _total,
                  bold: true,
                ),
              ],
            ),
            const AppSectionSpacer(),
            AppSectionCard(
              title: 'Datos del negocio',
              children: [
                TextFormField(
                  controller: _nombreNegocioController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del negocio',
                    hintText: 'Mi Pastelería',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _telefonoController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    hintText: '11 1234-5678',
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
            const AppSectionSpacer(),
            AppSectionCard(
              title: 'Mensajes del presupuesto',
              children: [
                TextFormField(
                  controller: _mensaje1Controller,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Mensaje inicial',
                    hintText: 'Texto de bienvenida o introducción',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _mensaje2Controller,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Mensaje final',
                    hintText: 'Condiciones, anticipo, cancelación',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            /// Generar PDF
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
                label: const Text('Generar PDF'),
                onPressed: () async {
                  // Validaciones para generar el PDF
                  if (_items.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Agregá al menos un producto'),
                      ),
                    );
                    return;
                  }
                  if (_nombreNegocioController.text.trim().isEmpty){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ingresá el nombre del negocio')
                      ),
                    );
                    return;
                  }
                  if (_clienteController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ingresá el nombre del cliente'),
                      ),
                    );
                    return;
                  }
                  final pdf = await PresupuestoPdf.generar(
                    negocio: _nombreNegocioController.text,
                    telefono: _telefonoController.text,
                    cliente: _clienteController.text,
                    fecha: DateTime.now(),
                    items: _items,
                    mensaje1: _mensaje1Controller.text,
                    mensaje2: _mensaje2Controller.text,
                  );

                  await Printing.layoutPdf(
                    onLayout: (format) async => pdf.save(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemPresupuestoCard extends StatelessWidget {
  final ItemPresupuesto item;
  final VoidCallback onChanged;
  final VoidCallback onDelete;

  const _ItemPresupuestoCard({
    super.key,
    required this.item,
    required this.onChanged,
    required this.onDelete,
  });



  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E0D9)),
      ),
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Producto',
              hintText: 'Ej: Torta de chocolate',
            ),
            onChanged: (v) {
              item.producto = v;
              onChanged();
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: item.cantidad.toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Cantidad'),
                  onChanged: (v) {
                    item.cantidad = int.tryParse(v) ?? 1;
                    onChanged();
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextFormField(
                  initialValue: item.precioUnitario.toStringAsFixed(2),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Precio unit.',
                    prefixText: '\$ ',
                  ),
                  onChanged: (v) {
                    item.precioUnitario = double.tryParse(v.replaceAll(',', '.')) ?? 0;
                    onChanged();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Detalle (opcional)',
              hintText: 'Descripción adicional',
            ),
            onChanged: (v) => item.detalle = v,
          ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Quitar'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
