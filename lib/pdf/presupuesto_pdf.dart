/*

// PLANTILLA 1

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:hemacostos/data/models/item_presupuesto.dart';

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
                /*child: pw.Opacity(
                  opacity: 0.06,
                  child: pw.Center(
                    child: pw.Image(watermark, width: 320),
                  ),
                ),*/
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: pw.Opacity(
                  opacity: 0.06,
                  child: pw.Image (watermark, fit: pw.BoxFit.cover,),
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
*/

// PLANTILLA 2

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:hemacostos/data/models/item_presupuesto.dart';

class PresupuestoPdf {
  static const _rosa = PdfColor.fromInt(0xFFD86A8B);
  static const _rosaClaro = PdfColor.fromInt(0xFFF4C6D2);
  static const _rosaPastel = PdfColor.fromInt(0xFFFDF1F4);
  static const _grisTexto = PdfColor.fromInt(0xFF4A4A4A);
  static const _grisClaro = PdfColor.fromInt(0xFFF7F7F7);

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

    final logoBytes = await rootBundle.load('assets/images/logo_cupcake.png');
    final watermarkBytes =
        await rootBundle.load('assets/images/cupcake_watermark.png');
    final fontRegularData =
        await rootBundle.load('assets/fonts/Poppins-Regular.ttf');
    final fontBoldData =
        await rootBundle.load('assets/fonts/Poppins-Bold.ttf');

    final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());
    final watermark = pw.MemoryImage(watermarkBytes.buffer.asUint8List());
    final font = pw.Font.ttf(fontRegularData);
    final fontBold = pw.Font.ttf(fontBoldData);

    final total = items.fold<double>(0, (s, i) => s + i.subtotal);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 32),
        build: (ctx) => pw.Stack(
          children: [
            // Watermark

              pw.Positioned.fill(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: pw.Opacity(
                  opacity: 0.16,
                  child: pw.Image (watermark, fit: pw.BoxFit.cover,),
                ),
              ),

            // Contenido
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
                pw.SizedBox(height: 18),
                _fechaCliente(fecha, cliente, font, fontBold),
                pw.SizedBox(height: 14),
                if (mensaje1.isNotEmpty) ...[
                  pw.Text(
                    mensaje1,
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 10,
                      color: _grisTexto,
                      lineSpacing: 2,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                ],
                _tabla(items, total, font, fontBold),
                pw.SizedBox(height: 20),
                if (mensaje2.isNotEmpty)
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: _rosaPastel,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Text(
                      mensaje2,
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 9,
                        color: _grisTexto,
                        lineSpacing: 2,
                      ),
                    ),
                  ),
                pw.Spacer(),
                _footer(font),
              ],
            ),
          ],
        ),
      ),
    );

    return pdf;
  }

  // HEADER
  static pw.Widget _header({
    required pw.ImageProvider logo,
    required String negocio,
    required String telefono,
    required pw.Font font,
    required pw.Font fontBold,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: pw.BoxDecoration(
        gradient: const pw.LinearGradient(
          colors: [_rosa, _rosaClaro],
          begin: pw.Alignment.centerLeft,
          end: pw.Alignment.centerRight,
        ),
        borderRadius: pw.BorderRadius.circular(14),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 40,
                height: 40,
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  shape: pw.BoxShape.circle,
                ),
                child: pw.Center(
                  child: pw.Image(logo, width: 28, height: 28),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    negocio,
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 17,
                      color: PdfColors.white,
                    ),
                  ),
                  if (telefono.isNotEmpty)
                    pw.Text(
                      telefono,
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 10,
                        color: PdfColors.white,
                      ),
                    ),
                ],
              ),
            ],
          ),
          pw.Container(
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(20),
            ),
            child: pw.Text(
              'PRESUPUESTO',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 10,
                color: _rosa,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //  FECHA + CLIENTE
  static pw.Widget _fechaCliente(
    DateTime fecha,
    String cliente,
    pw.Font font,
    pw.Font fontBold,
  ) {
    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];
    final fechaTexto =
        '${fecha.day} de ${meses[fecha.month - 1]} de ${fecha.year}';

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Estimado/a:',
              style: pw.TextStyle(font: font, fontSize: 9, color: _grisTexto),
            ),
            pw.Text(
              cliente,
              style: pw.TextStyle(font: fontBold, fontSize: 14, color: _grisTexto),
            ),
          ],
        ),
        pw.Text(
          fechaTexto,
          style: pw.TextStyle(font: font, fontSize: 9, color: _grisTexto),
        ),
      ],
    );
  }

  //  TABLA
  static pw.Widget _tabla(
    List<ItemPresupuesto> items,
    double total,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // Header row
        pw.Container(
          padding:
              const pw.EdgeInsets.symmetric(vertical: 9, horizontal: 12),
          decoration: pw.BoxDecoration(
            color: _rosa,
            borderRadius: const pw.BorderRadius.only(
              topLeft: pw.Radius.circular(10),
              topRight: pw.Radius.circular(10),
            ),
          ),
          child: pw.Row(
            children: [
              _th('Producto', flex: 4, fontBold: fontBold),
              _th('Cant.', flex: 1, fontBold: fontBold, align: pw.TextAlign.center),
              _th('Precio unit.', flex: 2, fontBold: fontBold, align: pw.TextAlign.right),
              _th('Subtotal', flex: 2, fontBold: fontBold, align: pw.TextAlign.right),
            ],
          ),
        ),

        // Item rows
        ...items.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          return pw.Container(
            color: i.isOdd ? _grisClaro : PdfColors.white,
            padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 4,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        item.producto.isNotEmpty ? item.producto : '-',
                        style: pw.TextStyle(font: fontBold, fontSize: 10, color: _grisTexto),
                      ),
                      if (item.detalle.isNotEmpty)
                        pw.Text(
                          item.detalle,
                          style: pw.TextStyle(font: font, fontSize: 9, color: _rosaClaro),
                        ),
                    ],
                  ),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Text(
                    item.cantidad.toString(),
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(font: font, fontSize: 10, color: _grisTexto),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    '\$${item.precioUnitario.toStringAsFixed(2)}',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(font: font, fontSize: 10, color: _grisTexto),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    '\$${item.subtotal.toStringAsFixed(2)}',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(font: fontBold, fontSize: 10, color: _grisTexto),
                  ),
                ),
              ],
            ),
          );
        }).toList(),

        // divider
        pw.Container(height: 1.5, color: _rosaClaro),

        // TOTAL
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: pw.BoxDecoration(
            color: _rosaPastel,
            borderRadius: const pw.BorderRadius.only(
              bottomLeft: pw.Radius.circular(10),
              bottomRight: pw.Radius.circular(10),
            ),
          ),
          child: pw.Row(
            children: [
              pw.Spacer(flex: 5),
              pw.Expanded(
                flex: 2,
                child: pw.Text(
                  'TOTAL',
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(font: fontBold, fontSize: 11, color: _rosa),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                flex: 2,
                child: pw.Text(
                  '\$${total.toStringAsFixed(2)}',
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(font: fontBold, fontSize: 13, color: _rosa),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _th(
    String text, {
    required pw.Font fontBold,
    int flex = 1,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Expanded(
      flex: flex,
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          font: fontBold,
          fontSize: 10,
          color: PdfColors.white,
        ),
      ),
    );
  }

  //  FOOTER
  static pw.Widget _footer(pw.Font font) {
    return pw.Column(
      children: [
        pw.Divider(color: _rosaClaro, thickness: 0.5),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Container(
              width: 6,
              height: 6,
              decoration: pw.BoxDecoration(color: _rosa, shape: pw.BoxShape.circle),
            ),
            pw.SizedBox(width: 6),
            pw.Text(
              'Gracias por su confianza',
              style: pw.TextStyle(font: font, fontSize: 9, color: _rosa),
            ),
            pw.SizedBox(width: 6),
            pw.Container(
              width: 6,
              height: 6,
              decoration: pw.BoxDecoration(color: _rosa, shape: pw.BoxShape.circle),
            ),
          ],
        ),
      ],
    );
  }
}
