import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../config/app_config.dart';

/// Un ítem (línea) de la cotización en PDF. Es un dato ephemeral de UI —
/// NO se persiste en Firestore en ningún lado. El PDF generado es el único
/// "guardado" de esta cotización: una vez descargado, el precio queda fijo
/// en el documento aunque después alguien cambie la calculadora o los
/// datos del formulario.
class ItemCotizacionPdf {
  final String descripcion;
  final double cantidad;
  final double precioUnitario;

  const ItemCotizacionPdf({
    required this.descripcion,
    required this.cantidad,
    required this.precioUnitario,
  });

  double get subtotal => cantidad * precioUnitario;
}

/// Datos completos de la cotización a volcar en el PDF. Todo ephemeral,
/// vive solo en el estado de `CotizacionPdfScreen` mientras se arma el
/// documento — nada de esto toca Firestore.
class DatosCotizacionPdf {
  final String clienteNombre;
  final String clienteContacto; // teléfono o email, opcional
  final String generadoPor; // nombre de quien genera la cotización
  final List<ItemCotizacionPdf> items;
  final String condiciones;

  const DatosCotizacionPdf({
    required this.clienteNombre,
    required this.clienteContacto,
    required this.generadoPor,
    required this.items,
    required this.condiciones,
  });

  double get total => items.fold(0.0, (suma, i) => suma + i.subtotal);
}

/// Arma el PDF profesional de la cotización. Usa las fuentes estándar del
/// PDF (Helvetica) — soportan tildes y ñ sin depender de bajar una fuente
/// por red al momento de generar el documento (más confiable que pedir
/// Inter desde Google Fonts justo al exportar).
class PdfCotizacionService {
  static const PdfColor _violeta = PdfColor.fromInt(0xFF7F77DD);
  static const PdfColor _negro = PdfColor.fromInt(0xFF000000);
  static const PdfColor _grisTexto = PdfColor.fromInt(0xFF4A4A4A);
  static const PdfColor _grisClaro = PdfColor.fromInt(0xFFF2F2F5);
  static const PdfColor _blanco = PdfColor.fromInt(0xFFFFFFFF);

  static pw.MemoryImage? _logoCache;

  static Future<pw.MemoryImage> _logo() async {
    if (_logoCache != null) return _logoCache!;
    final bytes = await rootBundle.load('assets/logos/logo_57nations.png');
    _logoCache = pw.MemoryImage(bytes.buffer.asUint8List());
    return _logoCache!;
  }

  static String _bs(double n) => 'Bs ${n.toStringAsFixed(2)}';

  static String _fecha(DateTime f) {
    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];
    return '${f.day} de ${meses[f.month - 1]} de ${f.year}';
  }

  /// Número de referencia solo para mostrar en el documento (no es un
  /// contador de Firestore — no hay secuencia oficial porque no se persiste
  /// nada). Formato: AAAAMMDD-HHmm.
  static String _referencia(DateTime f) {
    String p2(int n) => n.toString().padLeft(2, '0');
    return 'COT-${f.year}${p2(f.month)}${p2(f.day)}-${p2(f.hour)}${p2(f.minute)}';
  }

  static Future<Uint8List> generar(DatosCotizacionPdf datos) async {
    final doc = pw.Document();
    final logo = await _logo();
    final ahora = DateTime.now();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 36, 36, 36),
        header: (context) => _encabezado(logo, ahora),
        footer: (context) => _pie(context),
        build: (context) => [
          pw.SizedBox(height: 16),
          _bloqueCliente(datos),
          pw.SizedBox(height: 20),
          _tablaItems(datos.items),
          pw.SizedBox(height: 12),
          _filaTotal(datos.total),
          pw.SizedBox(height: 24),
          if (datos.condiciones.trim().isNotEmpty) _bloqueCondiciones(datos.condiciones),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _encabezado(pw.MemoryImage logo, DateTime ahora) {
    return pw.Column(
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Image(logo, height: 34),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'COTIZACIÓN',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 18,
                    color: _violeta,
                    letterSpacing: 1.5,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(_referencia(ahora),
                    style: const pw.TextStyle(fontSize: 9, color: _grisTexto)),
                pw.Text(_fecha(ahora), style: const pw.TextStyle(fontSize: 9, color: _grisTexto)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Container(height: 1.5, color: _violeta),
      ],
    );
  }

  static pw.Widget _bloqueCliente(DatosCotizacionPdf datos) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: const pw.BoxDecoration(color: _grisClaro),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('COTIZACIÓN PARA',
              style: const pw.TextStyle(
                  fontSize: 9, color: _grisTexto, letterSpacing: 1)),
          pw.SizedBox(height: 3),
          pw.Text(
            datos.clienteNombre.isEmpty ? 'Cliente' : datos.clienteNombre,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          if (datos.clienteContacto.trim().isNotEmpty) ...[
            pw.SizedBox(height: 2),
            pw.Text(datos.clienteContacto,
                style: const pw.TextStyle(fontSize: 10, color: _grisTexto)),
          ],
          if (datos.generadoPor.trim().isNotEmpty) ...[
            pw.SizedBox(height: 6),
            pw.Text('Preparado por ${datos.generadoPor} — 57 Nations',
                style: const pw.TextStyle(fontSize: 9, color: _grisTexto)),
          ],
        ],
      ),
    );
  }

  static pw.Widget _tablaItems(List<ItemCotizacionPdf> items) {
    return pw.Table(
      columnWidths: const {
        0: pw.FlexColumnWidth(5),
        1: pw.FlexColumnWidth(1.4),
        2: pw.FlexColumnWidth(2),
        3: pw.FlexColumnWidth(2),
      },
      children: [
        // Encabezado de la tabla
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _negro),
          children: [
            _celdaHeader('Descripción', alinearDerecha: false),
            _celdaHeader('Cant.'),
            _celdaHeader('Precio unit.'),
            _celdaHeader('Subtotal'),
          ],
        ),
        // Filas de ítems, con fondo alternado para lectura fácil
        for (var i = 0; i < items.length; i++)
          pw.TableRow(
            decoration: pw.BoxDecoration(
              color: i.isEven ? _blanco : _grisClaro,
            ),
            children: [
              _celda(items[i].descripcion, alinearDerecha: false),
              _celda(items[i].cantidad % 1 == 0
                  ? items[i].cantidad.toStringAsFixed(0)
                  : items[i].cantidad.toString()),
              _celda(_bs(items[i].precioUnitario)),
              _celda(_bs(items[i].subtotal), negrita: true),
            ],
          ),
      ],
    );
  }

  static pw.Widget _celdaHeader(String texto, {bool alinearDerecha = true}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 9, horizontal: 8),
      child: pw.Text(
        texto,
        textAlign: alinearDerecha ? pw.TextAlign.right : pw.TextAlign.left,
        style: pw.TextStyle(
          color: _blanco,
          fontWeight: pw.FontWeight.bold,
          fontSize: 9,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  static pw.Widget _celda(String texto, {bool alinearDerecha = true, bool negrita = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: pw.Text(
        texto,
        textAlign: alinearDerecha ? pw.TextAlign.right : pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: 10,
          color: _negro,
          fontWeight: negrita ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _filaTotal(double total) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: const pw.BoxDecoration(color: _violeta),
          child: pw.Row(
            children: [
              pw.Text('TOTAL  ',
                  style: pw.TextStyle(
                      color: _blanco, fontSize: 11, fontWeight: pw.FontWeight.bold)),
              pw.Text(
                _bs(total),
                style: pw.TextStyle(
                    color: _blanco, fontSize: 15, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _bloqueCondiciones(String condiciones) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _grisClaro, width: 1)),
      ),
      child: pw.Text(
        condiciones,
        style: const pw.TextStyle(fontSize: 9, color: _grisTexto, lineSpacing: 2),
      ),
    );
  }

  static pw.Widget _pie(pw.Context context) {
    return pw.Column(
      children: [
        pw.Container(height: 0.75, color: _grisClaro),
        pw.SizedBox(height: 6),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              '57 Nations · Santa Cruz, Bolivia · WhatsApp +${AppConfig.whatsappAdminNumero}',
              style: const pw.TextStyle(fontSize: 8, color: _grisTexto),
            ),
            pw.Text(
              'Página ${context.pageNumber} de ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: _grisTexto),
            ),
          ],
        ),
      ],
    );
  }
}
