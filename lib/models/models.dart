import 'package:cloud_firestore/cloud_firestore.dart';

// ==================== CATEGORÍAS DE PROYECTO/SERVICIO ====================
/// Lista fija de categorías para clasificar proyectos del Portfolio.
/// Corresponde a los 5 servicios oficiales del Home + "Web" (que por ahora
/// no tiene tarjeta propia en el Home, solo existe como categoría interna).
class CategoriasProyecto {
  static const String bots = 'Bots & Sistemas';
  static const String flutter = 'Apps Flutter';
  static const String arduino = 'Arduino & ESP32';
  static const String impresion3d = 'Impresión 3D';
  static const String entrenamiento = 'Entrenamiento';
  static const String web = 'Páginas Web';

  static const List<String> todas = [
    bots,
    flutter,
    arduino,
    impresion3d,
    entrenamiento,
    web,
  ];
}

// ==================== PROYECTO ====================
class Proyecto {
  final String id;
  final String titulo;
  final String cliente;
  final String descripcion;
  final List<String> imagenes;
  final List<String> tecnologias;
  final String categoria; // una de CategoriasProyecto.todas
  final String estado; // "Completo", "En progreso", etc.
  final DateTime fechaCreacion;
  final String contenidoDetallado;

  Proyecto({
    required this.id,
    required this.titulo,
    required this.cliente,
    required this.descripcion,
    required this.imagenes,
    required this.tecnologias,
    required this.categoria,
    required this.estado,
    required this.fechaCreacion,
    required this.contenidoDetallado,
  });

  factory Proyecto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Proyecto(
      id: doc.id,
      titulo: data['titulo'] ?? '',
      cliente: data['cliente'] ?? '',
      descripcion: data['descripcion'] ?? '',
      imagenes: List<String>.from(data['imagenes'] ?? []),
      categoria: data['categoria'] ?? CategoriasProyecto.web,
      tecnologias: List<String>.from(data['tecnologias'] ?? []),
      estado: data['estado'] ?? '',
      fechaCreacion: (data['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
      contenidoDetallado: data['contenidoDetallado'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'titulo': titulo,
      'cliente': cliente,
      'descripcion': descripcion,
      'imagenes': imagenes,
      'tecnologias': tecnologias,
      'categoria': categoria,
      'estado': estado,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'contenidoDetallado': contenidoDetallado,
    };
  }
}
// ==================== IMPRESIÓN 3D ====================
class Impresion3D {
  final String id;
  final String nombre;
  final String descripcion;
  final List<String> imagenes;
  final double precioBase;
  final String material; // PLA+, ABS, PETG, etc.
  final double peso; // en gramos
  final String categoria; // Decorativa, Funcional, Accesorio, etc.
  final bool disponible;
  final DateTime fechaCreacion;
  final String? archivo3d; // URL al archivo 3D
  final int tiempoImpresion; // en minutos
  final List<String> coloresDisponibles;

  Impresion3D({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.imagenes,
    required this.precioBase,
    required this.material,
    required this.peso,
    required this.categoria,
    required this.disponible,
    required this.fechaCreacion,
    this.archivo3d,
    required this.tiempoImpresion,
    required this.coloresDisponibles,
  });

  factory Impresion3D.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Impresion3D(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      imagenes: List<String>.from(data['imagenes'] ?? []),
      precioBase: (data['precioBase'] ?? 0).toDouble(),
      material: data['material'] ?? '',
      peso: (data['peso'] ?? 0).toDouble(),
      categoria: data['categoria'] ?? '',
      disponible: data['disponible'] ?? true,
      fechaCreacion: (data['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
      archivo3d: data['archivo3d'],
      tiempoImpresion: data['tiempoImpresion'] ?? 0,
      coloresDisponibles: List<String>.from(data['coloresDisponibles'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'imagenes': imagenes,
      'precioBase': precioBase,
      'material': material,
      'peso': peso,
      'categoria': categoria,
      'disponible': disponible,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'archivo3d': archivo3d,
      'tiempoImpresion': tiempoImpresion,
      'coloresDisponibles': coloresDisponibles,
    };
  }
}

// ==================== COTIZACIÓN ====================
class Cotizacion {
  final String id;
  final String nombreCliente;
  final String email;
  final String telefono;
  final String servicio; // Bots, Flutter, Arduino, 3D, Entrenamiento
  final String descripcion;
  final String presupuesto; // $500-1000, $1000-5000, $5000+, Sin presupuesto
  final String? archivoUrl;
  final DateTime fechaCreacion;
  final String estado; // Pendiente, En revisión, Respondida, Rechazada
  final String? respuestaAdmin;
  final double? presupuestoFinal;

  Cotizacion({
    required this.id,
    required this.nombreCliente,
    required this.email,
    required this.telefono,
    required this.servicio,
    required this.descripcion,
    required this.presupuesto,
    this.archivoUrl,
    required this.fechaCreacion,
    required this.estado,
    this.respuestaAdmin,
    this.presupuestoFinal,
  });

  factory Cotizacion.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Cotizacion(
      id: doc.id,
      nombreCliente: data['nombreCliente'] ?? '',
      email: data['email'] ?? '',
      telefono: data['telefono'] ?? '',
      servicio: data['servicio'] ?? '',
      descripcion: data['descripcion'] ?? '',
      presupuesto: data['presupuesto'] ?? '',
      archivoUrl: data['archivoUrl'],
      fechaCreacion: (data['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
      estado: data['estado'] ?? 'Pendiente',
      respuestaAdmin: data['respuestaAdmin'],
      presupuestoFinal: (data['presupuestoFinal'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombreCliente': nombreCliente,
      'email': email,
      'telefono': telefono,
      'servicio': servicio,
      'descripcion': descripcion,
      'presupuesto': presupuesto,
      'archivoUrl': archivoUrl,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'estado': estado,
      'respuestaAdmin': respuestaAdmin,
      'presupuestoFinal': presupuestoFinal,
    };
  }
}

// ==================== USUARIO (sistema de roles interno) ====================
/// Sistema de permisos escalable: en vez de "hardcodear" cada socio/rol,
/// cada usuario tiene un arreglo de permisos (strings). Así, cuando se suma
/// un socio nuevo o un servicio nuevo, solo se le asignan permisos nuevos
/// sin tocar código.
///
/// Permisos disponibles (convención "modulo.accion"):
///   - admin.total                 → ve y edita absolutamente todo
///   - pedidos.crear                → puede crear pedidos nuevos
///   - pedidos.ver_todos            → ve todos los datos del pedido (cliente, precio, etc.)
///   - pedidos.ver_pintado          → ve solo lo esencial de pedidos que requieren pintado
///                                    (pieza, foto, colores, fecha límite - sin cliente/precio)
///   - pedidos.actualizar_impresion → puede cambiar estado/fecha de la etapa de impresión
///   - pedidos.actualizar_pintado   → puede cambiar estado/fecha de la etapa de pintado
///   - calculadora.usar             → acceso a la calculadora de costos 3D
///   - cotizaciones.ver             → puede ver cotizaciones entrantes de la web
///   - usuarios.administrar         → puede crear/editar otros usuarios internos
class Usuario {
  final String id;
  final String username; // usuario de login (no email)
  final String nombre;
  final String rol; // "admin" | "socio" | "colaborador" (solo informativo/UI)
  final List<String> permisos;
  final bool activo;
  final DateTime fechaCreacion;

  Usuario({
    required this.id,
    required this.username,
    required this.nombre,
    required this.rol,
    required this.permisos,
    required this.activo,
    required this.fechaCreacion,
  });

  bool tienePermiso(String permiso) {
    return permisos.contains('admin.total') || permisos.contains(permiso);
  }

  /// Email interno usado para autenticar contra Firebase Auth por detrás,
  /// mientras el usuario solo ve "usuario" y "contraseña" en la UI.
  String get emailInterno => '$username@57nations.internal';

  factory Usuario.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Usuario(
      id: doc.id,
      username: data['username'] ?? '',
      nombre: data['nombre'] ?? '',
      rol: data['rol'] ?? 'colaborador',
      permisos: List<String>.from(data['permisos'] ?? []),
      activo: data['activo'] ?? true,
      fechaCreacion: (data['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'nombre': nombre,
      'rol': rol,
      'permisos': permisos,
      'activo': activo,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
    };
  }
}

// ==================== CÁLCULO DE COSTOS 3D ====================
/// Réplica exacta de la lógica de la calculadora HTML de Luchin.
/// Moneda: Bolivianos (Bs).
class CalculoCostos3D {
  final double precioFilamento; // Bs/kg
  final double peso; // gramos
  final int horas;
  final int minutos;
  final double potencia; // Watts
  final double precioKwh; // Bs/kWh
  final double desgastePorcentaje; // %
  final double fallosPorcentaje; // %
  final double margenPorcentaje; // %

  CalculoCostos3D({
    required this.precioFilamento,
    required this.peso,
    required this.horas,
    required this.minutos,
    required this.potencia,
    required this.precioKwh,
    required this.desgastePorcentaje,
    required this.fallosPorcentaje,
    required this.margenPorcentaje,
  });

  double get tiempoHoras => horas + minutos / 60;
  double get costoMaterial => (peso / 1000) * precioFilamento;
  double get costoElectrico => (potencia / 1000) * tiempoHoras * precioKwh;
  double get _subtotal => costoMaterial + costoElectrico;
  double get costoDesgaste => _subtotal * (desgastePorcentaje / 100);
  double get _conDesgaste => _subtotal + costoDesgaste;
  double get costoFallos => _conDesgaste * (fallosPorcentaje / 100);
  double get costoTotal => _conDesgaste + costoFallos;
  double get precioVenta => costoTotal * (1 + margenPorcentaje / 100);
  double get ganancia => precioVenta - costoTotal;

  factory CalculoCostos3D.fromMap(Map<String, dynamic> data) {
    return CalculoCostos3D(
      precioFilamento: (data['precioFilamento'] ?? 0).toDouble(),
      peso: (data['peso'] ?? 0).toDouble(),
      horas: (data['horas'] ?? 0).toInt(),
      minutos: (data['minutos'] ?? 0).toInt(),
      potencia: (data['potencia'] ?? 0).toDouble(),
      precioKwh: (data['precioKwh'] ?? 0).toDouble(),
      desgastePorcentaje: (data['desgastePorcentaje'] ?? 0).toDouble(),
      fallosPorcentaje: (data['fallosPorcentaje'] ?? 0).toDouble(),
      margenPorcentaje: (data['margenPorcentaje'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'precioFilamento': precioFilamento,
      'peso': peso,
      'horas': horas,
      'minutos': minutos,
      'potencia': potencia,
      'precioKwh': precioKwh,
      'desgastePorcentaje': desgastePorcentaje,
      'fallosPorcentaje': fallosPorcentaje,
      'margenPorcentaje': margenPorcentaje,
      // Resultados calculados, guardados también para no recalcular en listados
      'costoMaterial': costoMaterial,
      'costoElectrico': costoElectrico,
      'costoDesgaste': costoDesgaste,
      'costoFallos': costoFallos,
      'costoTotal': costoTotal,
      'precioVenta': precioVenta,
      'ganancia': ganancia,
    };
  }
}

// ==================== ORIGEN DE PEDIDO Y COMISIÓN LUCHIN ====================
class OrigenPedido {
  static const String senka = 'senka';
  static const String luchin = 'luchin';
}

/// Comisión de Luchin sobre la utilidad de los pedidos que él origina.
/// `monto` se calcula como `ganancia * (porcentaje / 100)` y se guarda ya
/// resuelto (mismo patrón que [CalculoCostos3D]) para no recalcular en listados.
class ComisionLuchin {
  /// Porcentaje default sugerido al cargar un pedido de origen Luchin.
  /// Editable por pedido individual desde el formulario.
  static const double porcentajeDefault = 30;

  final bool aplica;
  final double porcentaje; // %
  final double monto; // Bs, ya calculado sobre la ganancia del pedido

  const ComisionLuchin({
    required this.aplica,
    required this.porcentaje,
    required this.monto,
  });

  factory ComisionLuchin.calcular({
    required bool aplica,
    required double porcentaje,
    required double ganancia,
  }) {
    return ComisionLuchin(
      aplica: aplica,
      porcentaje: porcentaje,
      monto: aplica ? ganancia * (porcentaje / 100) : 0,
    );
  }

  factory ComisionLuchin.fromMap(Map<String, dynamic> data) {
    return ComisionLuchin(
      aplica: data['aplica'] ?? false,
      porcentaje: (data['porcentaje'] ?? 0).toDouble(),
      monto: (data['monto'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'aplica': aplica,
      'porcentaje': porcentaje,
      'monto': monto,
    };
  }
}

// ==================== PEDIDO ====================
/// Estados posibles. No todos los pedidos pasan por "enPintado":
/// eso depende de [requierePintado].
class EstadoPedido {
  static const String pendiente = 'Pendiente';
  static const String imprimiendo = 'Imprimiendo';
  static const String enPintado = 'En Pintado';
  static const String listo = 'Listo';
  static const String entregado = 'Entregado';

  /// Devuelve la secuencia de estados válida para un pedido según si
  /// requiere pintado o no.
  static List<String> flujoPara(bool requierePintado) {
    if (requierePintado) {
      return [pendiente, imprimiendo, enPintado, listo, entregado];
    }
    return [pendiente, imprimiendo, listo, entregado];
  }
}

class Pedido {
  final String id;
  final String clienteNombre;
  final String clienteTelefono;
  final String descripcionPieza;
  final List<String> fotos;
  final bool requierePintado;
  final List<String> coloresPedidos; // solo relevante si requierePintado
  final String estado;

  // Impresión (Luchin / Admin)
  final CalculoCostos3D? calculo;
  final DateTime? fechaEntregaImpresion; // estimada, la pone quien imprime
  final DateTime? fechaImpresionCompletada;

  // Pintado (Fifi) - solo si requierePintado
  final DateTime? fechaEntregaPintado; // estimada, la pone Fifi
  final DateTime? fechaPintadoCompletado;
  final String? notasPintado;

  final String creadoPorUsername; // quien registró el pedido (admin/luchin)
  final String? cotizacionOrigenId; // referencia opcional a la cotización web
  final DateTime fechaCreacion;

  final String origenPedido; // OrigenPedido.senka | OrigenPedido.luchin
  final ComisionLuchin? comisionLuchin; // solo relevante si origenPedido == luchin

  Pedido({
    required this.id,
    required this.clienteNombre,
    required this.clienteTelefono,
    required this.descripcionPieza,
    required this.fotos,
    required this.requierePintado,
    required this.coloresPedidos,
    required this.estado,
    this.calculo,
    this.fechaEntregaImpresion,
    this.fechaImpresionCompletada,
    this.fechaEntregaPintado,
    this.fechaPintadoCompletado,
    this.notasPintado,
    required this.creadoPorUsername,
    this.cotizacionOrigenId,
    required this.fechaCreacion,
    this.origenPedido = OrigenPedido.senka,
    this.comisionLuchin,
  });

  factory Pedido.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Pedido(
      id: doc.id,
      clienteNombre: data['clienteNombre'] ?? '',
      clienteTelefono: data['clienteTelefono'] ?? '',
      descripcionPieza: data['descripcionPieza'] ?? '',
      fotos: List<String>.from(data['fotos'] ?? []),
      requierePintado: data['requierePintado'] ?? false,
      coloresPedidos: List<String>.from(data['coloresPedidos'] ?? []),
      estado: data['estado'] ?? EstadoPedido.pendiente,
      calculo: data['calculo'] != null
          ? CalculoCostos3D.fromMap(Map<String, dynamic>.from(data['calculo']))
          : null,
      fechaEntregaImpresion: (data['fechaEntregaImpresion'] as Timestamp?)?.toDate(),
      fechaImpresionCompletada: (data['fechaImpresionCompletada'] as Timestamp?)?.toDate(),
      fechaEntregaPintado: (data['fechaEntregaPintado'] as Timestamp?)?.toDate(),
      fechaPintadoCompletado: (data['fechaPintadoCompletado'] as Timestamp?)?.toDate(),
      notasPintado: data['notasPintado'],
      creadoPorUsername: data['creadoPorUsername'] ?? '',
      cotizacionOrigenId: data['cotizacionOrigenId'],
      fechaCreacion: (data['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
      origenPedido: data['origenPedido'] ?? OrigenPedido.senka,
      comisionLuchin: data['comisionLuchin'] != null
          ? ComisionLuchin.fromMap(Map<String, dynamic>.from(data['comisionLuchin']))
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clienteNombre': clienteNombre,
      'clienteTelefono': clienteTelefono,
      'descripcionPieza': descripcionPieza,
      'fotos': fotos,
      'requierePintado': requierePintado,
      'coloresPedidos': coloresPedidos,
      'estado': estado,
      'calculo': calculo?.toMap(),
      'fechaEntregaImpresion':
          fechaEntregaImpresion != null ? Timestamp.fromDate(fechaEntregaImpresion!) : null,
      'fechaImpresionCompletada':
          fechaImpresionCompletada != null ? Timestamp.fromDate(fechaImpresionCompletada!) : null,
      'fechaEntregaPintado':
          fechaEntregaPintado != null ? Timestamp.fromDate(fechaEntregaPintado!) : null,
      'fechaPintadoCompletado':
          fechaPintadoCompletado != null ? Timestamp.fromDate(fechaPintadoCompletado!) : null,
      'notasPintado': notasPintado,
      'creadoPorUsername': creadoPorUsername,
      'cotizacionOrigenId': cotizacionOrigenId,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'origenPedido': origenPedido,
      'comisionLuchin': comisionLuchin?.toMap(),
    };
  }

  Pedido copyWith({
    String? estado,
    DateTime? fechaEntregaImpresion,
    DateTime? fechaImpresionCompletada,
    DateTime? fechaEntregaPintado,
    DateTime? fechaPintadoCompletado,
    String? notasPintado,
    String? origenPedido,
    ComisionLuchin? comisionLuchin,
  }) {
    return Pedido(
      id: id,
      clienteNombre: clienteNombre,
      clienteTelefono: clienteTelefono,
      descripcionPieza: descripcionPieza,
      fotos: fotos,
      requierePintado: requierePintado,
      coloresPedidos: coloresPedidos,
      estado: estado ?? this.estado,
      calculo: calculo,
      fechaEntregaImpresion: fechaEntregaImpresion ?? this.fechaEntregaImpresion,
      fechaImpresionCompletada: fechaImpresionCompletada ?? this.fechaImpresionCompletada,
      fechaEntregaPintado: fechaEntregaPintado ?? this.fechaEntregaPintado,
      fechaPintadoCompletado: fechaPintadoCompletado ?? this.fechaPintadoCompletado,
      notasPintado: notasPintado ?? this.notasPintado,
      creadoPorUsername: creadoPorUsername,
      cotizacionOrigenId: cotizacionOrigenId,
      fechaCreacion: fechaCreacion,
      origenPedido: origenPedido ?? this.origenPedido,
      comisionLuchin: comisionLuchin ?? this.comisionLuchin,
    );
  }
}

// ==================== MIEMBRO EQUIPO ====================
class MiembroEquipo {
  final String id;
  final String nombre;
  final String rol;
  final String especialidad;
  final String? fotoUrl;
  final String? instagramUrl;
  final String? linkedinUrl;

  MiembroEquipo({
    required this.id,
    required this.nombre,
    required this.rol,
    required this.especialidad,
    this.fotoUrl,
    this.instagramUrl,
    this.linkedinUrl,
  });

  factory MiembroEquipo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MiembroEquipo(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      rol: data['rol'] ?? '',
      especialidad: data['especialidad'] ?? '',
      fotoUrl: data['fotoUrl'],
      instagramUrl: data['instagramUrl'],
      linkedinUrl: data['linkedinUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'rol': rol,
      'especialidad': especialidad,
      'fotoUrl': fotoUrl,
      'instagramUrl': instagramUrl,
      'linkedinUrl': linkedinUrl,
    };
  }
}
