import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
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
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const NavBar(),
            const PageHero(
              titulo: 'Cotiza tu Proyecto',
              subtitulo: '¿Tenés una idea? Cuéntanos. Sin compromiso, sin costo inicial.',
            ),
            _buildFormSection(isMobile),
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: isMobile ? 60 : 100,
      ),
      color: AppColors.background,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Formulario de Cotización',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontSize: isMobile ? 28 : 36,
                  ),
            ),
            SizedBox(height: isMobile ? 40 : 60),
            // GRID DE CAMPOS
            if (!isMobile)
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'Nombre Completo',
                      controller: _nombreController,
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Campo requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildTextField(
                      label: 'Email',
                      controller: _emailController,
                      validator: (v) =>
                          v?.contains('@') ?? false ? null : 'Email inválido',
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  _buildTextField(
                    label: 'Nombre Completo',
                    controller: _nombreController,
                    validator: (v) =>
                        v?.isEmpty ?? true ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: 'Email',
                    controller: _emailController,
                    validator: (v) =>
                        v?.contains('@') ?? false ? null : 'Email inválido',
                  ),
                ],
              ),
            const SizedBox(height: 20),
            if (!isMobile)
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'Teléfono',
                      controller: _telefonoController,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildDropdown(
                      label: 'Servicio Interesado',
                      value: _servicioSeleccionado,
                      items: [
                        'Bots & Sistemas',
                        'Apps Flutter',
                        'Arduino & ESP32',
                        'Impresión 3D',
                        'Entrenamiento',
                      ],
                      onChanged: (v) =>
                          setState(() => _servicioSeleccionado = v ?? ''),
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  _buildTextField(
                    label: 'Teléfono',
                    controller: _telefonoController,
                  ),
                  const SizedBox(height: 20),
                  _buildDropdown(
                    label: 'Servicio Interesado',
                    value: _servicioSeleccionado,
                    items: [
                      'Bots & Sistemas',
                      'Apps Flutter',
                      'Arduino & ESP32',
                      'Impresión 3D',
                      'Entrenamiento',
                    ],
                    onChanged: (v) =>
                        setState(() => _servicioSeleccionado = v ?? ''),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'Descripción del Proyecto',
              controller: _descripcionController,
              maxLines: 6,
              validator: (v) =>
                  v?.isEmpty ?? true ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 20),
            _buildDropdown(
              label: 'Presupuesto Aproximado',
              value: _presupuestoSeleccionado,
              items: [
                '\$500 - \$1000',
                '\$1000 - \$5000',
                '\$5000+',
                'Sin presupuesto',
              ],
              onChanged: (v) =>
                  setState(() => _presupuestoSeleccionado = v ?? ''),
            ),
            SizedBox(height: isMobile ? 32 : 48),
            ElevatedButton(
              onPressed: _enviando ? null : _enviarCotizacion,
              child: _enviando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.textLight),
                      ),
                    )
                  : const Text('ENVIAR SOLICITUD'),
            ),
          ],
        ),
      ),
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
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
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
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          decoration: const InputDecoration(),
        ),
      ],
    );
  }
}
