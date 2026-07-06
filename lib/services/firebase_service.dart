import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== PROYECTOS ====================
  Future<List<Proyecto>> obtenerProyectos() async {
    try {
      final snapshot = await _firestore
          .collection('proyectos')
          .orderBy('fechaCreacion', descending: true)
          .get();
      return snapshot.docs.map((doc) => Proyecto.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error al obtener proyectos: $e');
      return [];
    }
  }

  Future<Proyecto?> obtenerProyecto(String id) async {
    try {
      final doc = await _firestore.collection('proyectos').doc(id).get();
      if (doc.exists) {
        return Proyecto.fromFirestore(doc);
      }
    } catch (e) {
      print('Error al obtener proyecto: $e');
    }
    return null;
  }

Future<void> crearProyecto(Proyecto proyecto) async {
    try {
      await _firestore.collection('proyectos').doc(proyecto.id).set(
            proyecto.toFirestore(),
          );
    } catch (e) {
      print('Error al crear proyecto: $e');
      rethrow;
    }
  }

  Future<void> actualizarProyecto(String id, Proyecto proyecto) async {
    try {
      await _firestore.collection('proyectos').doc(id).update(
            proyecto.toFirestore(),
          );
    } catch (e) {
      print('Error al actualizar proyecto: $e');
      rethrow;
    }
  }

  Future<void> eliminarProyecto(String id) async {
    try {
      await _firestore.collection('proyectos').doc(id).delete();
    } catch (e) {
      print('Error al eliminar proyecto: $e');
      rethrow;
    }
  }

  // ==================== IMPRESIONES 3D ====================
  Future<List<Impresion3D>> obtenerImpresiones3D() async {
    try {
      final snapshot = await _firestore
          .collection('impresiones3d')
          .where('disponible', isEqualTo: true)
          .orderBy('fechaCreacion', descending: true)
          .get();
      return snapshot.docs.map((doc) => Impresion3D.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error al obtener impresiones 3D: $e');
      return [];
    }
  }

  Future<List<Impresion3D>> obtenerImpresiones3DPorCategoria(String categoria) async {
    try {
      final snapshot = await _firestore
          .collection('impresiones3d')
          .where('categoria', isEqualTo: categoria)
          .where('disponible', isEqualTo: true)
          .orderBy('fechaCreacion', descending: true)
          .get();
      return snapshot.docs.map((doc) => Impresion3D.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error al obtener impresiones 3D por categoría: $e');
      return [];
    }
  }

  Future<Impresion3D?> obtenerImpresion3D(String id) async {
    try {
      final doc = await _firestore.collection('impresiones3d').doc(id).get();
      if (doc.exists) {
        return Impresion3D.fromFirestore(doc);
      }
    } catch (e) {
      print('Error al obtener impresión 3D: $e');
    }
    return null;
  }

  Future<void> crearImpresion3D(Impresion3D impresion) async {
    try {
      await _firestore.collection('impresiones3d').doc(impresion.id).set(
            impresion.toFirestore(),
          );
    } catch (e) {
      print('Error al crear impresión 3D: $e');
    }
  }

  Future<List<String>> obtenerCategoriasImpresion3D() async {
    try {
      final snapshot = await _firestore.collection('categorias3d').get();
      return snapshot.docs
          .map((doc) => doc['nombre'] as String)
          .toList();
    } catch (e) {
      print('Error al obtener categorías: $e');
      return [];
    }
  }

  // ==================== COTIZACIONES ====================
  Future<void> crearCotizacion(Cotizacion cotizacion) async {
    try {
      await _firestore.collection('cotizaciones').doc(cotizacion.id).set(
            cotizacion.toFirestore(),
          );
    } catch (e) {
      print('Error al crear cotización: $e');
      rethrow;
    }
  }

  Future<Cotizacion?> obtenerCotizacion(String id) async {
    try {
      final doc = await _firestore.collection('cotizaciones').doc(id).get();
      if (doc.exists) {
        return Cotizacion.fromFirestore(doc);
      }
    } catch (e) {
      print('Error al obtener cotización: $e');
    }
    return null;
  }

  Future<List<Cotizacion>> obtenerCotizaciones() async {
    try {
      final snapshot = await _firestore
          .collection('cotizaciones')
          .orderBy('fechaCreacion', descending: true)
          .get();
      return snapshot.docs.map((doc) => Cotizacion.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error al obtener cotizaciones: $e');
      return [];
    }
  }

  // ==================== EQUIPO ====================
  Future<List<MiembroEquipo>> obtenerEquipo() async {
    try {
      final snapshot = await _firestore
          .collection('equipo')
          .orderBy('nombre')
          .get();
      return snapshot.docs.map((doc) => MiembroEquipo.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error al obtener equipo: $e');
      return [];
    }
  }

  // ==================== PEDIDOS ====================
  /// Solo Admin y Luchin pueden llamar a esto (validar permiso 'pedidos.crear'
  /// en la UI antes de invocar). Los clientes nunca crean pedidos directo;
  /// siempre pasan primero por una Cotización que Admin revisa por WhatsApp.
  Future<void> crearPedido(Pedido pedido) async {
    try {
      await _firestore.collection('pedidos').doc(pedido.id).set(
            pedido.toFirestore(),
          );
    } catch (e) {
      print('Error al crear pedido: $e');
      rethrow;
    }
  }

  Future<List<Pedido>> obtenerPedidos() async {
    try {
      final snapshot = await _firestore
          .collection('pedidos')
          .orderBy('fechaCreacion', descending: true)
          .get();
      return snapshot.docs.map((doc) => Pedido.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error al obtener pedidos: $e');
      return [];
    }
  }

  /// Pedidos visibles para Fifi: solo los que requieren pintado y ya
  /// terminaron la etapa de impresión (estado >= 'En Pintado').
  Future<List<Pedido>> obtenerPedidosParaPintado() async {
    try {
      final snapshot = await _firestore
          .collection('pedidos')
          .where('requierePintado', isEqualTo: true)
          .where('estado', whereIn: [EstadoPedido.enPintado, EstadoPedido.listo, EstadoPedido.entregado])
          .orderBy('fechaCreacion', descending: true)
          .get();
      return snapshot.docs.map((doc) => Pedido.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error al obtener pedidos para pintado: $e');
      return [];
    }
  }

  Future<Pedido?> obtenerPedido(String id) async {
    try {
      final doc = await _firestore.collection('pedidos').doc(id).get();
      if (doc.exists) {
        return Pedido.fromFirestore(doc);
      }
    } catch (e) {
      print('Error al obtener pedido: $e');
    }
    return null;
  }

  Future<void> actualizarPedido(String id, Map<String, dynamic> cambios) async {
    try {
      await _firestore.collection('pedidos').doc(id).update(cambios);
    } catch (e) {
      print('Error al actualizar pedido: $e');
      rethrow;
    }
  }

  /// Avanza el estado del pedido. Solo válido si el nuevo estado pertenece
  /// al flujo correcto (con o sin pintado) - ver [EstadoPedido.flujoPara].
  Future<void> actualizarEstadoPedido(String id, String nuevoEstado) async {
    await actualizarPedido(id, {'estado': nuevoEstado});
  }

  // ==================== USUARIOS INTERNOS ====================
  Future<List<Usuario>> obtenerUsuarios() async {
    try {
      final snapshot = await _firestore.collection('usuarios').orderBy('nombre').get();
      return snapshot.docs.map((doc) => Usuario.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error al obtener usuarios: $e');
      return [];
    }
  }

  Future<void> actualizarPermisosUsuario(String username, List<String> permisos) async {
    try {
      await _firestore.collection('usuarios').doc(username).update({'permisos': permisos});
    } catch (e) {
      print('Error al actualizar permisos: $e');
      rethrow;
    }
  }

  // ==================== BÚSQUEDA ====================
  Future<List<Impresion3D>> buscarImpresiones3D(String query) async {
    try {
      final snapshot = await _firestore
          .collection('impresiones3d')
          .where('nombre', isGreaterThanOrEqualTo: query)
          .where('nombre', isLessThan: query + 'z')
          .get();
      return snapshot.docs.map((doc) => Impresion3D.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error al buscar impresiones 3D: $e');
      return [];
    }
  }

  
}

