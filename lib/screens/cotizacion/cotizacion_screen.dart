import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../services/firebase_service.dart';
import '../../models/models.dart';
import '../../utils/responsive.dart';
import '../../widgets/widgets.dart';
import '../../utils/whatsapp_helper.dart';

class CotizacionScreen extends StatefulWidget {
  const CotizacionScreen({super.key});

  @override
  State<CotizacionScreen> createState() => _CotizacionScreenState();
}

class _CotizacionScreenState extends State<CotizacionScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormState>();

  // Campos del formulario
  late TextEditingController _nombreController;
  late TextEditingController _emailController;
  late TextEditingController _telefonoController;
  late TextEditingController _descripcionController;

  String _servicioSeleccionado = 'Bots & Sistemas';
  String _presupuestoSeleccionado = 'Sin presupuesto';
  bool _enviando = false;

  static const _servicios = [
    'Bots & Sistemas',
    'Apps Flutter',
    'Arduino & ESP32',
    'Impresión 3D',
    'Entrenamiento',
  ];

  static const _presupuestos = [
    '\$500 - \$1000',
    '\$1000 - \$5000',
    '\$5000+',
    'Sin presupuesto',
  ];

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _emailController = TextEditingController();
    _telefonoController = TextEditingController();
    _descripcionController = TextEditingController();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _enviarCotizacion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _enviando = true);

    try {
      final cotizacion = Cotizacion(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nombreCliente: _nombreController.text,
        email: _emailController.text,
        telefono: _telefonoController.text,
        servicio: _servicioSeleccionado,
        descripcion: _descripcionController.text,
        presupuesto: _presupuestoSeleccionado,
        fechaCreacion: DateTime.now(),
        estado: 'Pendiente',
      );

      // 1) Guardar en Firestore para que quede registro histórico
      await _firebaseService.crearCotizacion(cotizacion);

      // 2) Abrir WhatsApp con el mensaje ya redactado, dirigido a Senka (Admin).
      //    Esto NO le escribe al cliente; es el cliente quien manda el mensaje
      //    a 57 Nations con toda la info ya ordenada.
      await WhatsAppHelper.enviarCotizacionPorWhatsApp(cotizacion);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '¡Cotización guardada! Se abrió WhatsApp para que nos envíes tu consulta.',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        _limpiarFormulario();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _enviando = false);
    }
  }

  void _limpiarFormulario() {
    _nombreController.clear();
    _emailController.clear();
    _telefonoController.clear();
    _descripcionController.clear();
    setState(() {
      _servicioSeleccionado = 'Bots & Sistemas';
      _presupuestoSeleccionado = 'Sin presupuesto';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: const WhatsAppFlotante(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const NavBar(),
            const PageHero(
              overline: 'Cotización',
              titulo: 'Cotizá tu proyecto',
              subtitulo:
                  '¿Tenés una idea? Contanos. Al enviar, se abre WhatsApp con tu '
                  'consulta ya redactada — sin compromiso, sin costo inicial.',
            ),
            _buildFormSection(),
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    final isMobile = Responsive.isMobile(context);

    return PageSection(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.maxFormWidth),
          child: TechCard(
            showCornerBrackets: true,
            padding: EdgeInsets.all(isMobile ? AppSpacing.xl : AppSpacing.section),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    overline: 'Formulario',
                    titulo: 'Contanos tu idea',
                    subtitulo:
                        'Mientras más detalle nos des, más precisa va a ser la cotización.',
                    compacto: true,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _filaDoble(
                    isMobile,
                    _buildTextField(
                      label: 'Nombre completo',
                      controller: _nombreController,
                      validator: (v) => v?.isEmpty ?? true ? 'Campo requerido' : null,
                    ),
                    _buildTextField(
                      label: 'Email',
                      controller: _emailController,
                      validator: (v) => v?.contains('@') ?? false ? null : 'Email inválido',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _filaDoble(
                    isMobile,
                    _buildTextField(
                      label: 'Teléfono (WhatsApp)',
                      controller: _telefonoController,
                    ),
                    _buildDropdown(
                      label: 'Servicio de interés',
                      value: _servicioSeleccionado,
                      items: _servicios,
                      onChanged: (v) => setState(() => _servicioSeleccionado = v ?? ''),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _buildTextField(
                    label: 'Descripción del proyecto',
                    controller: _descripcionController,
                    maxLines: 6,
                    validator: (v) => v?.isEmpty ?? true ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _buildDropdown(
                    label: 'Presupuesto aproximado',
                    value: _presupuestoSeleccionado,
                    items: _presupuestos,
                    onChanged: (v) => setState(() => _presupuestoSeleccionado = v ?? ''),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _enviando ? null : _enviarCotizacion,
                      icon: _enviando
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(AppColors.textLight),
                              ),
                            )
                          : const Icon(Icons.send_outlined, size: 18),
                      label: Text(_enviando ? 'ENVIANDO...' : 'ENVIAR SOLICITUD'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Dos campos lado a lado en desktop, apilados en mobile.
  Widget _filaDoble(bool isMobile, Widget izquierda, Widget derecha) {
    if (isMobile) {
      return Column(
        children: [izquierda, const SizedBox(height: AppSpacing.xl), derecha],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: izquierda),
        const SizedBox(width: AppSpacing.xl),
        Expanded(child: derecha),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(color: AppColors.textLight),
          decoration: const InputDecoration(),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<String>(
          initialValue: value,
          dropdownColor: AppColors.surfaceElevated,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
          decoration: const InputDecoration(),
        ),
      ],
    );
  }
}
