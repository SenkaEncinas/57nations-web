import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

/// Subida de imágenes a Cloudinary (plan gratuito) usando un upload preset
/// SIN FIRMAR — no requiere API secret en el cliente, por eso es seguro
/// tenerlo acá. Reemplaza a Firebase Storage, que exigiría plan Blaze.
///
/// El preset se configura en el dashboard de Cloudinary
/// (Settings → Upload → Upload presets, modo "Unsigned").
class CloudinaryService {
  static const String _cloudName = 'rvl1xuhh';
  static const String _uploadPreset = '57nations_uploads';

  /// Devuelve la URL de Cloudinary con transformación de tamaño/compresión
  /// (`w_<ancho>,c_limit,q_auto,f_auto`): Cloudinary sirve una versión
  /// redimensionada y en el mejor formato para el navegador, sin que el
  /// usuario haga nada. `c_limit` nunca agranda una imagen más chica.
  ///
  /// Si la URL no es de Cloudinary (fotos viejas cargadas a mano) o ya trae
  /// una transformación, se devuelve intacta — nunca rompe una imagen.
  static String optimizar(String urlOriginal, {required int ancho}) {
    const marcador = '/image/upload/';
    if (!urlOriginal.contains('res.cloudinary.com') ||
        !urlOriginal.contains(marcador)) {
      return urlOriginal;
    }
    final indice = urlOriginal.indexOf(marcador) + marcador.length;
    final resto = urlOriginal.substring(indice);
    // Ya transformada (empieza con parámetros tipo "w_..." o "q_...").
    if (RegExp(r'^[a-z]+_[^/]+/').hasMatch(resto)) return urlOriginal;
    return '${urlOriginal.substring(0, indice)}w_$ancho,c_limit,q_auto,f_auto/$resto';
  }

  static final Uri _uploadUrl =
      Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');

  /// Sube los bytes de una imagen y devuelve la URL segura (https) final.
  /// Lanza [CloudinaryException] si Cloudinary rechaza la subida.
  Future<String> subirImagen(Uint8List bytes, {String? nombreArchivo}) async {
    final request = http.MultipartRequest('POST', _uploadUrl)
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: nombreArchivo ?? 'imagen.jpg',
      ));

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode != 200) {
      String detalle = 'HTTP ${streamed.statusCode}';
      try {
        final json = jsonDecode(body) as Map<String, dynamic>;
        detalle = (json['error']?['message'] as String?) ?? detalle;
      } catch (_) {
        // cuerpo no-JSON: dejamos el código HTTP como detalle
      }
      throw CloudinaryException('No se pudo subir la imagen: $detalle');
    }

    final json = jsonDecode(body) as Map<String, dynamic>;
    final url = json['secure_url'] as String?;
    if (url == null) {
      throw CloudinaryException('Cloudinary respondió sin secure_url');
    }
    return url;
  }
}

class CloudinaryException implements Exception {
  final String mensaje;

  CloudinaryException(this.mensaje);

  @override
  String toString() => mensaje;
}
