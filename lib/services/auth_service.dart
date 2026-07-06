import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

/// Maneja el login interno del panel (Admin / Luchin / Fifi / futuros socios).
///
/// El usuario ve solo "Usuario" y "Contraseña" en pantalla, pero por detrás
/// usamos Firebase Auth (email + password) mapeando:
///   username "luchin"  ->  email interno "luchin@57nations.internal"
/// Esto nos da toda la seguridad de Firebase Auth sin exponer emails reales
/// ni pedirle a la gente que recuerde un correo.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _dominioInterno = '57nations.internal';

  String _emailDesdeUsername(String username) {
    final limpio = username.trim().toLowerCase();
    return '$limpio@$_dominioInterno';
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get usuarioActual => _auth.currentUser;

  /// Login con usuario y contraseña. Lanza [FirebaseAuthException] si falla.
  Future<Usuario?> login(String username, String password) async {
    final email = _emailDesdeUsername(username);
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user == null) return null;

    return obtenerPerfilUsuario(username.trim().toLowerCase());
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Trae el documento de permisos/rol desde Firestore (colección `usuarios`,
  /// documento con id = username). Este documento NO tiene la contraseña
  /// (eso lo maneja Firebase Auth); solo guarda rol y permisos.
  Future<Usuario?> obtenerPerfilUsuario(String username) async {
    try {
      final doc = await _firestore.collection('usuarios').doc(username).get();
      if (doc.exists) {
        return Usuario.fromFirestore(doc);
      }
    } catch (e) {
      print('Error al obtener perfil de usuario: $e');
    }
    return null;
  }

  /// Recupera el perfil (rol/permisos) del usuario actualmente logueado,
  /// usando la parte local del email interno como username.
  Future<Usuario?> obtenerPerfilActual() async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) return null;
    final username = user.email!.split('@').first;
    return obtenerPerfilUsuario(username);
  }

  /// Solo para uso de Admin: crea un usuario interno nuevo (Auth + Firestore).
  /// Requiere que quien llame ya tenga permiso 'usuarios.administrar'.
  Future<void> crearUsuarioInterno({
    required String username,
    required String password,
    required String nombre,
    required String rol,
    required List<String> permisos,
  }) async {
    final email = _emailDesdeUsername(username);
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final usuario = Usuario(
      id: username.trim().toLowerCase(),
      username: username.trim().toLowerCase(),
      nombre: nombre,
      rol: rol,
      permisos: permisos,
      activo: true,
      fechaCreacion: DateTime.now(),
    );

    await _firestore
        .collection('usuarios')
        .doc(usuario.id)
        .set(usuario.toFirestore());

    // Nota: crear un usuario nuevo con createUserWithEmailAndPassword
    // automáticamente inicia sesión como ese usuario. Si Admin está creando
    // socios desde su propio panel, hay que volver a loguearlo o usar
    // una Cloud Function con Admin SDK para evitar este efecto secundario.
    // Por ahora, dejamos la nota para la fase de backend/Cloud Functions.
    if (credential.user == null) {
      throw Exception('No se pudo crear el usuario en Firebase Auth');
    }
  }
}
