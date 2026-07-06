import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../services/cloudinary_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

/// Selector de fotos reutilizable con subida real a Cloudinary.
///
/// - Modo múltiple (default): el usuario agrega N imágenes.
/// - Modo única ([unaSola]: true): para fotos de perfil — elegir una nueva
///   reemplaza a la anterior.
///
/// Muestra thumbnails con opción de eliminar, spinner mientras sube y
/// reintento si una subida falla. Cada vez que cambia la lista de URLs
/// ya subidas llama a [onChanged] — el padre guarda esas URLs en Firestore.
class SelectorFotos extends StatefulWidget {
  final List<String> fotosIniciales;
  final ValueChanged<List<String>> onChanged;
  final bool unaSola;
  final String? etiqueta;

  const SelectorFotos({
    super.key,
    this.fotosIniciales = const [],
    required this.onChanged,
    this.unaSola = false,
    this.etiqueta,
  });

  @override
  State<SelectorFotos> createState() => _SelectorFotosState();
}

/// Estado interno de cada foto del selector.
class _FotoItem {
  final Uint8List? bytes; // preview local mientras sube (null si vino de URL)
  final String? nombreArchivo;
  String? url; // seteada cuando la subida termina
  bool subiendo;
  bool conError;

  _FotoItem.deUrl(String this.url)
      : bytes = null,
        nombreArchivo = null,
        subiendo = false,
        conError = false;

  _FotoItem.local(Uint8List this.bytes, this.nombreArchivo)
      : url = null,
        subiendo = true,
        conError = false;
}

class _SelectorFotosState extends State<SelectorFotos> {
  final _cloudinary = CloudinaryService();
  late List<_FotoItem> _fotos;

  @override
  void initState() {
    super.initState();
    _fotos = widget.fotosIniciales.map(_FotoItem.deUrl).toList();
  }

  bool get _haySubidasEnCurso => _fotos.any((f) => f.subiendo);

  void _notificar() {
    widget.onChanged(
      _fotos.where((f) => f.url != null).map((f) => f.url!).toList(),
    );
  }

  Future<void> _elegirFotos() async {
    final resultado = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: !widget.unaSola,
      withData: true, // necesario en web para tener los bytes
    );
    if (resultado == null || resultado.files.isEmpty) return;

    final nuevos = <_FotoItem>[];
    for (final archivo in resultado.files) {
      if (archivo.bytes == null) continue;
      nuevos.add(_FotoItem.local(archivo.bytes!, archivo.name));
    }
    if (nuevos.isEmpty) return;

    setState(() {
      if (widget.unaSola) {
        _fotos = [nuevos.first];
      } else {
        _fotos.addAll(nuevos);
      }
    });
    _notificar(); // si en modo única se reemplazó una URL ya subida

    for (final item in nuevos) {
      _subir(item);
    }
  }

  Future<void> _subir(_FotoItem item) async {
    setState(() {
      item.subiendo = true;
      item.conError = false;
    });
    try {
      final url = await _cloudinary.subirImagen(
        item.bytes!,
        nombreArchivo: item.nombreArchivo,
      );
      if (!mounted) return;
      setState(() {
        item.url = url;
        item.subiendo = false;
      });
      _notificar();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        item.subiendo = false;
        item.conError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: AppColors.error),
      );
    }
  }

  void _eliminar(_FotoItem item) {
    setState(() => _fotos.remove(item));
    _notificar();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.etiqueta != null) ...[
          Text(
            widget.etiqueta!,
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            ..._fotos.map((f) => _Thumbnail(
                  item: f,
                  onEliminar: () => _eliminar(f),
                  onReintentar: () => _subir(f),
                )),
            if (!widget.unaSola || _fotos.isEmpty) _BotonAgregar(onTap: _elegirFotos),
            if (widget.unaSola && _fotos.isNotEmpty)
              // En modo única, el botón cambia la foto en vez de agregar otra
              _BotonAgregar(onTap: _elegirFotos, cambiar: true),
          ],
        ),
        if (_haySubidasEnCurso)
          const Padding(
            padding: EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              'Subiendo fotos... no guardes todavía.',
              style: TextStyle(color: AppColors.warning, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final _FotoItem item;
  final VoidCallback onEliminar;
  final VoidCallback onReintentar;

  const _Thumbnail({
    required this.item,
    required this.onEliminar,
    required this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    Widget imagen;
    if (item.bytes != null) {
      imagen = Image.memory(item.bytes!, fit: BoxFit.cover);
    } else if (item.url != null) {
      imagen = Image.network(item.url!, fit: BoxFit.cover);
    } else {
      imagen = const Icon(Icons.image_outlined, color: AppColors.textDim);
    }

    return SizedBox(
      width: 84,
      height: 84,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            clipBehavior: Clip.hardEdge,
            decoration: ShapeDecoration(
              color: AppColors.surface,
              shape: AppTheme.cutCorner(
                size: AppTheme.cutSizeSm,
                side: BorderSide(
                  color: item.conError ? AppColors.error : AppColors.border,
                ),
              ),
            ),
            child: imagen,
          ),
          if (item.subiendo)
            Container(
              color: AppColors.overlayDark,
              child: const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          if (item.conError)
            Container(
              color: AppColors.overlayDark,
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.error, size: 22),
                  tooltip: 'Reintentar subida',
                  onPressed: onReintentar,
                ),
              ),
            ),
          if (!item.subiendo)
            Positioned(
              top: 2,
              right: 2,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: onEliminar,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.overlayDark,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 14, color: AppColors.textLight),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BotonAgregar extends StatelessWidget {
  final VoidCallback onTap;
  final bool cambiar;

  const _BotonAgregar({required this.onTap, this.cambiar = false});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 84,
          height: 84,
          decoration: ShapeDecoration(
            shape: AppTheme.cutCorner(
              size: AppTheme.cutSizeSm,
              side: BorderSide(
                color: AppColors.violetaPrincipal.withValues(alpha: 0.6),
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                cambiar ? Icons.swap_horiz : Icons.add_photo_alternate_outlined,
                color: AppColors.violetaPrincipal,
                size: 24,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                cambiar ? 'Cambiar' : 'Agregar',
                style: const TextStyle(
                  color: AppColors.violetaPrincipal,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
