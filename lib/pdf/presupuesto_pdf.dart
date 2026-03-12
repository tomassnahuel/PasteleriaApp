import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:presupuestoapp/data/models/item_presupuesto.dart';

class PresupuestoPdf {
  // Colores base
static const rosaFuerte = PdfColor.fromInt(0xFFD86A8B);
static const rosaClaro = PdfColor.fromInt(0xFFF4C6D2);
static const rosaMuyClaro = PdfColor.fromInt(0xFFFDF1F4);

  static Future<pw.Document> generar({
    required String negocio,
    required String telefono,
    required String cliente,
    required DateTime fecha,
    required List<ItemPresupuesto> items,
    required String mensaje1,
    required String mensaje2,
  }) async {
    final pdf = pw.Document();

    // Assets
// Imágenes
final logoBytes =
    await rootBundle.load('assets/images/logo_cupcake.png');
final watermarkBytes =
    await rootBundle.load('assets/images/cupcake_watermark.png');

final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());
final watermark = pw.MemoryImage(watermarkBytes.buffer.asUint8List());

// Fuentes
final fontRegularData =
    await rootBundle.load('assets/fonts/Poppins-Regular.ttf');
final fontBoldData =
    await rootBundle.load('assets/fonts/Poppins-Bold.ttf');

final font = pw.Font.ttf(fontRegularData);
final fontBold = pw.Font.ttf(fontBoldData);

    final total = items.fold<double>(
      0,
      (sum, i) => sum + i.subtotal,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Stack(
            children: [
              // ======================
              // WATERMARK
              // ======================
              pw.Positioned.fill(
                child: pw.Opacity(
                  opacity: 0.06,
                  child: pw.Center(
                    child: pw.Image(watermark, width: 320),
                  ),
                ),
              ),

              // ======================
              // CONTENIDO
              // ======================
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _header(
                    logo: logo,
                    negocio: negocio,
                    telefono: telefono,
                    font: font,
                    fontBold: fontBold,
                  ),
                  pw.SizedBox(height: 20),

                  _fechaCliente(fecha, cliente, font, fontBold),
                  pw.SizedBox(height: 16),

                  pw.Text(
                    mensaje1,
                    style: pw.TextStyle(font: font),
                  ),

                  pw.SizedBox(height: 24),

                  _tabla(items, total, font, fontBold),

                  pw.SizedBox(height: 24),

                  pw.Text(
                    mensaje2,
                    style: pw.TextStyle(font: font),
                  ),

                  pw.Spacer(),
                  _footer(),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  // ======================
  // HEADER
  // ======================
  static pw.Widget _header({
    required pw.ImageProvider logo,
    required String negocio,
    required String telefono,
    required pw.Font font,
    required pw.Font fontBold,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: rosaFuerte,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            children: [
              pw.Image(logo, width: 36),
              pw.SizedBox(width: 8),
              pw.Text(
                negocio,
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 18,
                  color: PdfColors.white,
                ),
              ),
            ],
          ),
          pw.Text(
            telefono,
            style: pw.TextStyle(
              font: font,
              color: PdfColors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ======================
  // FECHA + CLIENTE
  // ======================
static pw.Widget _fechaCliente(
  DateTime fecha,
  String cliente,
  pw.Font font,
  pw.Font fontBold,
) {
  const meses = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  final fechaTexto =
      '${fecha.day} de ${meses[fecha.month - 1]} de ${fecha.year}';

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          fechaTexto,
          style: pw.TextStyle(font: font),
        ),
      ),
      pw.SizedBox(height: 12),
      pw.Align(
        alignment: pw.Alignment.centerLeft,
        child: pw.Text(
          'Estimado/a $cliente:',
          style: pw.TextStyle(font: fontBold),
        ),
      ),
    ],
  );
}

// TABLA
static pw.Widget _tabla(
  List<ItemPresupuesto> items,
  double total,
  pw.Font font,
  pw.Font fontBold,
) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      // ======================
      // ENCABEZADO
      // ======================
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: pw.BoxDecoration(
          color: rosaClaro,
          borderRadius: const pw.BorderRadius.only(
            topLeft: pw.Radius.circular(12),
            topRight: pw.Radius.circular(12),
          ),
        ),
        child: pw.Row(
          children: [
            _cell('Producto', flex: 4, font: fontBold, color: PdfColors.white),
            _cell('Cant.', flex: 1, font: fontBold, color: PdfColors.white, align: pw.TextAlign.center),
            _cell('Precio', flex: 2, font: fontBold, color: PdfColors.white, align: pw.TextAlign.right),
            _cell('Subtotal', flex: 2, font: fontBold, color: PdfColors.white, align: pw.TextAlign.right),
          ],
        ),
      ),

      // ======================
      // FILAS
      // ======================
      ...items.map((item) {
        return pw.Column(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              child: pw.Row(
                children: [
                  _cell('${item.producto}\n${item.detalle}', flex: 4, font: font),
                  _cell(item.cantidad.toString(), flex: 1, font: font, align: pw.TextAlign.center),
                  _cell('\$${item.precioUnitario.toStringAsFixed(2)}', flex: 2, font: font, align: pw.TextAlign.right),
                  _cell('\$${item.subtotal.toStringAsFixed(2)}', flex: 2, font: font, align: pw.TextAlign.right),
                ],
              ),
            ),

            // Línea separadora rosa
            pw.Container(
              height: 1,
              color: rosaMuyClaro,
            ),
          ],
        );
      }).toList(),

      pw.SizedBox(height: 12),

      // ======================
      // TOTAL
      // ======================
      pw.Container(
  padding: const pw.EdgeInsets.symmetric(vertical: 10),
  decoration: pw.BoxDecoration(
    border: pw.Border(
      top: pw.BorderSide(
        color: rosaClaro,
        width: 2,
      ),
    ),
  ),
  child: pw.Row(
    children: [
      pw.Spacer(flex: 5),
      _cell(
        'TOTAL',
        flex: 2,
        font: fontBold,
        align: pw.TextAlign.right,
      ),
      _cell(
        '\$${total.toStringAsFixed(2)}',
        flex: 2,
        font: fontBold,
        align: pw.TextAlign.right,
      ),
    ],
  ),
),
    ],
  );
}

static pw.Widget _cell(
  String text, {
  required pw.Font font,
  int flex = 1,
  PdfColor? color,
  pw.TextAlign align = pw.TextAlign.left,
}) {
  return pw.Expanded(
    flex: flex,
    child: pw.Text(
      text,
      textAlign: align,
      style: pw.TextStyle(
        font: font,
        fontSize: 11,
        color: color ?? PdfColors.black,
      ),
    ),
  );
}

  // ======================
  // FOOTER
  // ======================
  static pw.Widget _footer() {
    return pw.Container(
      height: 8,
      decoration: pw.BoxDecoration(
        color: rosaFuerte,
        borderRadius: pw.BorderRadius.circular(12),
      ),
    );
  }
}
