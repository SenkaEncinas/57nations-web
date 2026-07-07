import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

/// Todos los métodos de lectura dejan que las excepciones se propaguen
/// (sin capturarlas ni devolver listas vacías silenciosamente): así cada
/// pantalla puede distinguir "no hay datos" de "falló la conexión" y
/// mostrarle al usuario un estado de error real en vez de una lista vacía
/// sin explicación.
class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== PROYECTOS ====================
  Future<List<Proyecto>> obtenerProyectos() async {
    final snapshot = await _firestore
        .collection('proyectos')
        .orderBy('fechaCreacion', descending: true)
        .get();
    return snapshot.docs.map((doc) => Proyecto.fromFirestore(doc)).toList();
  }

  Future<Proyecto?> obtenerProyecto(String id) async {
    final doc = await _firestore.collection('proyectos').doc(id).get();
    if (doc.exists) {
      return Proyecto.fromFirestore(doc);
    }
    return null;
  }

  Future<void> crearProyecto(Proyecto proyecto) async {
    await _firestore.collection('proyectos').doc(proyecto.id).set(
          proyecto.toFirestore(),
        );
  }

  Future<void> actualizarProyecto(String id, Proyecto proyecto) async {
    await _firestore.collection('proyectos').doc(id).update(
          proyecto.toFirestore(),
        );
  }

  Future<void> eliminarProyecto(String id) async {
    await _firestore.collection('proyectos').doc(id).delete();
  }

  // ==================== IMPRESIONES 3D ====================
  Future<List<Impresion3D>> obtenerImpresiones3D() async {
    final snapshot = await _firestore
        .collection('impresiones3d')
        .where('disponible', isEqualTo: true)
        .orderBy('fechaCreacion', descending: true)
        .get();
    return snapshot.docs.map((doc) => Impresion3D.fromFirestore(doc)).toList();
  }

  Future<List<Impresion3D>> obtenerImpresiones3DPorCategoria(String categoria) async {
    final snapshot = await _firestore
        .collection('impresiones3d')
        .where('categoria', isEqualTo: categoria)
        .where('disponible', isEqualTo: true)
        .orderBy('fechaCreacion', descending: true)
        .get();
    return snapshot.docs.map((doc) => Impresion3D.fromFirestore(doc)).toList();
  }

  Future<Impresion3D?> obtenerImpresion3D(String id) async {
    final doc = await _firestore.collection('impresiones3d').doc(id).get();
    if (doc.exists) {
      return Impresion3D.fromFirestore(doc);
    }
    return null;
  }

  Future<void> crearImpresion3D(Impresion3D impresion) async {
    await _firestore.collection('impresiones3d').doc(impresion.id).set(
          impresion.toFirestore(),
        );
  }

  /// Para el panel de administración del catálogo (permiso
  /// 'catalogo3d.administrar'): trae TODAS las piezas, incluidas las no
  /// disponibles — a diferencia del catálogo público que filtra disponible.
  Future<List<Impresion3D>> obtenerTodasImpresiones3D() async {
    final snapshot = await _firestore
        .collection('impresiones3d')
        .orderBy('fechaCreacion', descending: true)
        .get();
    return snapshot.docs.map((doc) => Impresion3D.fromFirestore(doc)).toList();
  }

  Future<void> actualizarImpresion3D(String id, Impresion3D impresion) async {
    await _firestore.collection('impresiones3d').doc(id).update(
          impresion.toFirestore(),
        );
  }

  Future<void> eliminarImpresion3D(String id) async {
    await _firestore.collection('impresiones3d').doc(id).delete();
  }

  Future<List<String>> obtenerCategoriasImpresion3D() async {
    final snapshot = await _firestore.collection('categorias3d').get();
    return snapshot.docs.map((doc) => doc['nombre'] as String).toList();
  }

  // ==================== COTIZACIONES ====================
  Future<void> crearCotizacion(Cotizacion cotizacion) async {
    await _firestore.collection('cotizaciones').doc(cotizacion.id).set(
          cotizacion.toFirestore(),
        );
  }

  Future<Cotizacion?> obtenerCotizacion(String id) async {
    final doc = await _firestore.collection('cotizaciones').doc(id).get();
    if (doc.exists) {
      return Cotizacion.fromFirestore(doc);
    }
    return null;
  }

  Future<List<Cotizacion>> obtenerCotizaciones() async {
    final snapshot = await _firestore
        .collection('cotizaciones')
        .orderBy('fechaCreacion', descending: true)
        .get();
    return snapshot.docs.map((doc) => Cotizacion.fromFirestore(doc)).toList();
  }

  /// Solo Admin (permiso 'cotizaciones.eliminar', implícito en admin.total).
  /// Las reglas de Firestore también restringen el delete a admin.
  Future<void> eliminarCotizacion(String id) async {
    await _firestore.collection('cotizaciones').doc(id).delete();
  }

  // ==================== EQUIPO ====================
  Future<List<MiembroEquipo>> obtenerEquipo() async {
    final snapshot = await _firestore.collection('equipo').orderBy('nombre').get();
    return snapshot.docs.map((doc) => MiembroEquipo.fromFirestore(doc)).toList();
  }

  /// Un miembro puntual por id de documento (perfil público de equipo).
  Future<MiembroEquipo?> obtenerMiembroEquipo(String id) async {
    final doc = await _firestore.collection('equipo').doc(id).get();
    if (doc.exists) {
      return MiembroEquipo.fromFirestore(doc);
    }
    return null;
  }

  /// Documento de equipo del usuario logueado ("Mi Currículum").
  /// Se busca por campo `username` (no por id de documento) para que también
  /// funcione con documentos viejos creados a mano con otro id.
  Future<MiembroEquipo?> obtenerMiembroEquipoPorUsername(String username) async {
    final snapshot = await _firestore
        .collection('equipo')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return MiembroEquipo.fromFirestore(snapshot.docs.first);
  }

  /// Crea o pisa el documento de equipo del miembro. Las reglas de Firestore
  /// solo permiten esto si `miembro.username` coincide con el login de quien
  /// escribe (o si es admin.total).
  Future<void> crearOActualizarMiembroEquipo(MiembroEquipo miembro) async {
    await _firestore.collection('equipo').doc(miembro.id).set(miembro.toFirestore());
  }

  // ==================== PEDIDOS ====================
  /// Solo Admin y Luchin pueden llamar a esto (validar permiso 'pedidos.crear'
  /// en la UI antes de invocar). Los clientes nunca crean pedidos directo;
  /// siempre pasan primero por una Cotización que Admin revisa por WhatsApp.
  Future<void> crearPedido(Pedido pedido) async {
    await _firestore.collection('pedidos').doc(pedido.id).set(
          pedido.toFirestore(),
        );
  }

  Future<List<Pedido>> obtenerPedidos() async {
    final snapshot = await _firestore
        .collection('pedidos')
        .orderBy('fechaCreacion', descending: true)
        .get();
    return snapshot.docs.map((doc) => Pedido.fromFirestore(doc)).toList();
  }

  /// Pedidos visibles para Fifi: solo los que requieren pintado y ya
  /// terminaron la etapa de impresión (estado >= 'En Pintado').
  Future<List<Pedido>> obtenerPedidosParaPintado() async {
    final snapshot = await _firestore
        .collection('pedidos')
        .where('requierePintado', isEqualTo: true)
        .where('estado', whereIn: [EstadoPedido.enPintado, EstadoPedido.listo, EstadoPedido.entregado])
        .orderBy('fechaCreacion', descending: true)
        .get();
    return snapshot.docs.map((doc) => Pedido.fromFirestore(doc)).toList();
  }

  Future<Pedido?> obtenerPedido(String id) async {
    final doc = await _firestore.collection('pedidos').doc(id).get();
    if (doc.exists) {
      return Pedido.fromFirestore(doc);
    }
    return null;
  }

  Future<void> actualizarPedido(String id, Map<String, dynamic> cambios) async {
    await _firestore.collection('pedidos').doc(id).update(cambios);
  }

  /// Avanza el estado del pedido. Solo válido si el nuevo estado pertenece
  /// al flujo correcto (con o sin pintado) - ver [EstadoPedido.flujoPara].
  Future<void> actualizarEstadoPedido(String id, String nuevoEstado) async {
    await actualizarPedido(id, {'estado': nuevoEstado});
  }

  // ==================== USUARIOS INTERNOS ====================
  Future<List<Usuario>> obtenerUsuarios() async {
    final snapshot = await _firestore.collection('usuarios').orderBy('nombre').get();
    return snapshot.docs.map((doc) => Usuario.fromFirestore(doc)).toList();
  }

  Future<void> actualizarPermisosUsuario(String username, List<String> permisos) async {
    await _firestore.collection('usuarios').doc(username).update({'permisos': permisos});
  }

  // ==================== BÚSQUEDA ====================
  Future<List<Impresion3D>> buscarImpresiones3D(String query) async {
    final snapshot = await _firestore
        .collection('impresiones3d')
        .where('nombre', isGreaterThanOrEqualTo: query)
        .where('nombre', isLessThan: '${query}z')
        .get();
    return snapshot.docs.map((doc) => Impresion3D.fromFirestore(doc)).toList();
  }
}
