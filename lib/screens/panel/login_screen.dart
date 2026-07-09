import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../services/auth_service.dart';
import '../../widgets/widgets.dart';
import 'panel_shell.dart';

/// Login del panel interno para Admin, Luchin, Fifi y futuros socios.
/// El usuario ve "Usuario" y "Contraseña" — nunca un campo de email.
class PanelLoginScreen extends StatefulWidget {
  const PanelLoginScreen({super.key});

  @override
  State<PanelLoginScreen> createState() => _PanelLoginScreenState();
}

class _PanelLoginScreenState extends State<PanelLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _cargando = false;
  String? _error;
  bool _passwordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final usuario = await _authService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (usuario == null) {
        setState(() => _error = 'No se encontró tu perfil interno. Contacta a Admin.');
        return;
      }

      if (!usuario.activo) {
        setState(() => _error = 'Tu cuenta está desactivada. Contacta a Admin.');
        return;
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PanelShell(usuario: usuario)),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
          _error = 'Usuario o contraseña incorrectos.';
        } else {
          _error = 'Error al iniciar sesión: ${e.message}';
        }
      });
    } catch (e) {
      setState(() => _error = 'No pudimos conectar con el servidor. Revisá tu conexión e intentá de nuevo.');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Fondo con gradiente de marca, liso. El grid de circuito y las
          // esquinas TechCornerDecoration quedan reservados al Hero del
          // Home (dirección minimalista, ver CLAUDE.md).
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AppColors.primaryGradient),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/logos/logo_57nations.png',
                        height: 56,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'PANEL INTERNO',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              letterSpacing: 4,
                              color: AppColors.cianTech,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      TechCard(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Usuario',
                                prefixIcon: Icon(Icons.person_outline, color: AppColors.textMuted),
                              ),
                              style: const TextStyle(color: AppColors.textLight),
                              validator: (v) => (v?.isEmpty ?? true) ? 'Ingresa tu usuario' : null,
                              onFieldSubmitted: (_) => _iniciarSesion(),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_passwordVisible,
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textMuted),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible ? Icons.visibility_off : Icons.visibility,
                                    color: AppColors.textMuted,
                                  ),
                                  onPressed: () =>
                                      setState(() => _passwordVisible = !_passwordVisible),
                                ),
                              ),
                              style: const TextStyle(color: AppColors.textLight),
                              validator: (v) =>
                                  (v?.isEmpty ?? true) ? 'Ingresa tu contraseña' : null,
                              onFieldSubmitted: (_) => _iniciarSesion(),
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: AppSpacing.lg),
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: ShapeDecoration(
                                  color: AppColors.error.withValues(alpha: 0.1),
                                  shape: const BeveledRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                    side: BorderSide(color: AppColors.error),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline,
                                        color: AppColors.error, size: 18),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: Text(
                                        _error!,
                                        style: const TextStyle(
                                            color: AppColors.error, fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.xl),
                            ElevatedButton(
                              onPressed: _cargando ? null : _iniciarSesion,
                              child: _cargando
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(AppColors.textLight),
                                      ),
                                    )
                                  : const Text('INGRESAR'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      TextButton.icon(
                        onPressed: () =>
                            Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false),
                        icon: const Icon(Icons.arrow_back, size: 16),
                        label: const Text('Volver a la web pública'),
                        style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
