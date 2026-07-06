import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_colors.dart';
import '../../services/auth_service.dart';
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '57 NATIONS',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: AppColors.violetaPrincipal,
                          fontSize: 32,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'PANEL INTERNO',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          letterSpacing: 3,
                        ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
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
                        const SizedBox(height: 16),
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
                              onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                            ),
                          ),
                          style: const TextStyle(color: AppColors.textLight),
                          validator: (v) => (v?.isEmpty ?? true) ? 'Ingresa tu contraseña' : null,
                          onFieldSubmitted: (_) => _iniciarSesion(),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              _error!,
                              style: const TextStyle(color: AppColors.error, fontSize: 13),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _cargando ? null : _iniciarSesion,
                          child: _cargando
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.textLight),
                                  ),
                                )
                              : const Text('INGRESAR'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false),
                    child: const Text('← Volver a la web pública'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
