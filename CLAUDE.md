# 57 Nations Web — Contexto del proyecto

Este archivo lo lee Claude Code automáticamente al iniciar sesión en esta carpeta.
Resume todas las decisiones tomadas hasta ahora para no perder contexto.

## Qué es esto

Sitio web de **57 Nations**, empresa de Senka en Santa Cruz, Bolivia. Ofrece 5
servicios: Bots de WhatsApp/sistemas, Apps Flutter, Arduino/ESP32, Impresión 3D,
Entrenamiento de basketball. Construido en **Flutter Web + Firebase** (Firestore +
Auth), 100% en el plan gratuito (Spark).

Proyecto Firebase real: `nations-2b049`
Hosting: `https://nations-2b049.web.app` (despliegue automático vía GitHub Actions
en cada push a `main` — ver `.github/workflows/firebase-hosting-merge.yml`)

**URLs limpias, sin `#`** (agosto 2026): `main.dart` llama a `usePathUrlStrategy()`
(paquete `flutter_web_plugins`, ya en pubspec.yaml). Todas las rutas son del tipo
`nations-2b049.web.app/catalogo-3d`, NO `nations-2b049.web.app/#/catalogo-3d`.
Esto es necesario porque hay links que se comparten fuera del sitio (WhatsApp,
NFC — ver sección "Producto: llaveros NFC"). Depende del rewrite `"**" ->
"/index.html"` que ya existe en `firebase.json`; si algún día se saca ese
rewrite, romper hard-refresh en cualquier ruta que no sea `/`.

## Personas y roles

- **Senka** (Admin): dueño, imprime en 3D él mismo, ve y edita todo (`admin.total`)
- **Luchin**: socio/diseñador 3D, NO imprime — solo cotiza con la calculadora y
  trae clientes propios (gana comisión sobre la utilidad de esos pedidos).
  Permisos: `pedidos.ver_todos`, `pedidos.crear`, `calculadora.usar`
- **Fifi Oyster**: pinta piezas 3D bajo pedido. Solo ve lo esencial de pedidos
  que requieren pintado (pieza, foto, colores, fecha límite — NUNCA cliente/precio).
  Permiso: `pedidos.ver_pintado`. Excepción explícita y deliberada: SÍ puede
  tener `cotizaciones.generar` (herramienta de PDF, ver sección "Panel
  interno") — Senka pidió abrirla a cualquier cuenta interna porque no
  toca Firestore ni el flujo de pedidos; no es una filtración del dato de
  pedidos, es una herramienta aparte para que cada quien cotice lo suyo.
- **Moe**: fue CLIENTA de un proyecto puntual (Cosechá), NO es colaboradora
  interna. No darle acceso al panel, ni cuenta interna, ni documento en `equipo`.

El equipo interno (Senka, Luchin, Fifi y futuros socios) edita su propio
currículum público desde el panel ("Mi Currículum", permiso
`equipo.editar_propio`) — ver sección "Equipo / currículums".

## Producto: llaveros NFC (nuevo, agosto 2026)

Senka empezó a vender **llaveros con chip NFC** — un producto físico nuevo,
por fuera de los 5 servicios "oficiales" del sitio (Bots, Apps, Arduino, 3D,
Entrenamiento). Al acercar el llavero a un celular, el chip abre un link.

- **URL exacta para programar en cada chip NFC**:
  `https://nations-2b049.web.app/gracias`
  (funciona limpia, sin `#`, gracias a `usePathUrlStrategy()` — ver más arriba).
- Esa URL abre `lib/screens/gracias_screen.dart` (ruta `AppRoutes.gracias`):
  agradece la compra y empuja tráfico al resto del sitio con 3 CTAs
  (Catálogo 3D, Portfolio, Cotización) — la idea explícita de Senka es que
  cada venta física también sume una visita al sitio.
- **A propósito NO está en la Navbar** — se llega solo por el link directo
  del chip (mismo criterio que el login del panel, que tampoco está en
  la Navbar pública).
- **Lo que NO existe todavía** (por si se pide a futuro, no inventar sin
  confirmar con Senka primero):
  - No hay carrito ni registro de venta en Firestore — es una página
    estática, no sabe quién compró qué ni cuándo.
  - No hay forma de distinguir "vino de un llavero NFC" vs. "entró directo
    a /gracias" (no hay query param ni analytics conectado).
  - Si en el futuro hay más productos físicos con su propio link (otro
    diseño de llavero, un sticker NFC, etc.), el patrón a repetir es el
    mismo: nueva ruta + pantalla simple con agradecimiento + CTAs cruzadas
    a Catálogo/Portfolio/Cotización. No hace falta una tabla de "productos"
    en Firestore para esto salvo que Senka pida trackear ventas de verdad.

## Sistema de permisos (escalable)

En vez de hardcodear roles, cada usuario en Firestore (`usuarios/{username}`)
tiene un array `permisos: string[]`. Agregar un socio/servicio nuevo = agregar
permisos en Firestore, sin tocar código. Ver enum de permisos documentado en
`lib/models/models.dart` (clase `Usuario`).

Login: usuario/contraseña (NO email visible). Por detrás se mapea a
Firebase Auth como `{username}@57nations.internal`. Ver `lib/services/auth_service.dart`.

## Flujo de pedidos (impresión 3D)

```
Pendiente → Imprimiendo → [En Pintado, solo si aplica] → Listo → Entregado
```
- No todos los pedidos requieren pintado (`Pedido.requierePintado: bool`)
- Cada etapa la actualiza quien corresponde, con su propia fecha estimada
- Pedidos NUNCA los crea el cliente directo — el cliente cotiza (formulario
  público → Firestore + WhatsApp pre-armado a Senka), Senka habla con él, y
  Senka o Luchin cargan el pedido real desde el panel

**Ya implementado**: `origenPedido` ("senka"|"luchin") y `comisionLuchin`
existen en el modelo `Pedido` (`lib/models/models.dart`, clases `OrigenPedido`
y `ComisionLuchin`) y se usan en `crear_pedido_screen.dart` y
`pedidos_screen.dart`. El default de comisión hoy es la constante
`ComisionLuchin.porcentajeDefault` (30%) — queda pendiente moverlo a
`configuracion/general` en Firestore si se quiere editable sin deploy.

## Fotos: Cloudinary (NO Firebase Storage)

Las fotos (pedidos, proyectos del portfolio, perfiles de equipo) se suben a
**Cloudinary** con un upload preset **unsigned** — Firebase Storage exigiría
plan Blaze y el proyecto vive en Spark. Patrón:

- `lib/services/cloudinary_service.dart`: POST multipart al endpoint de
  upload de Cloudinary, devuelve `secure_url`. Cloud name y preset viven SOLO
  en ese archivo (un preset unsigned no expone secretos, pero no repetirlos
  por el código ni documentarlos acá).
- **Optimización al mostrar**: SIEMPRE envolver la URL con
  `CloudinaryService.optimizar(url, ancho: N)` en los `Image.network` —
  inserta `w_N,c_limit,q_auto,f_auto` en la URL y Cloudinary sirve la imagen
  redimensionada/comprimida. Anchos de referencia: thumbnails 200, cards
  600, detalle 800-1000, lightbox 1600. Si la URL no es de Cloudinary la
  devuelve intacta, así que es seguro usarla en todo.
- `lib/widgets/selector_fotos.dart` (`SelectorFotos`): widget único de subida
  (file_picker con `withData: true` para web). Modo múltiple (default) o
  `unaSola: true` para fotos de perfil. Muestra thumbnails, progreso,
  eliminar y reintento; entrega `List<String>` de URLs vía `onChanged`.
- En Firestore solo se guardan las URLs resultantes (campos `fotos`,
  `imagenes`, `fotoUrl` siguen siendo strings — el modelo no cambió).
- Usado en: crear_pedido_screen, portfolio_admin_screen (ahora un proyecto
  puede tener VARIAS fotos) y mi_curriculum_screen. NUNCA volver a pedir
  "URL de imagen" a mano en un formulario.

## Equipo / currículums (colección `equipo`)

- Cada socio edita SU PROPIO documento de `equipo` desde el panel:
  `lib/screens/panel/mi_curriculum_screen.dart` (permiso
  `equipo.editar_propio`; admin.total también lo tiene implícito).
- `MiembroEquipo` tiene `username` (enlaza con la cuenta de login; para docs
  nuevos el id del doc = username), `biografia` (texto libre multilínea,
  sin límite — cada uno se presenta como quiere) y `experiencia`
  (List<ExperienciaItem>: título + descripción opcional, items dinámicos
  sin límite, editables en "Mi Currículum" y mostrados como lista tipo
  currículum en el perfil público debajo de la biografía).
- Reglas de Firestore: lectura pública; create/update solo si
  `username` del documento == username del solicitante (o admin);
  delete solo admin. Ver bloque `equipo` en firestore.rules.
- La web pública muestra el equipo con `MiembroEquipoCard`
  (`lib/widgets/miembro_equipo_card.dart`), estilo "selección de personaje":
  foto GRANDE, nombre, rol y descripción corta (especialidad; si está vacía,
  biografía truncada a ~70 chars; si ambas vacías, "Equipo 57 Nations").
  Toda la card navega al perfil público. Se usa en Home y Sobre Nosotros —
  no crear otra card de miembro.
- **Perfil público de miembro**: `lib/screens/equipo/perfil_equipo_screen.dart`,
  ruta `AppRoutes.perfilEquipo` ('/equipo-perfil') con el id del doc como
  argumento (mismo patrón que proyecto-detalle). Muestra foto grande, rol,
  especialidad, redes, biografía completa (el "currículum") y CTA
  "Hablar con [nombre]" → WhatsApp al número de admin mencionando a la
  persona. Biografía vacía → card "está preparando su presentación" con CTA,
  nunca sección vacía. Servicio: `obtenerMiembroEquipo(id)`.
- **Orden del equipo**: `ordenarEquipoConAdminAlCentro()` + `esMiembroAdmin()`
  (en miembro_equipo_card.dart). Senka (rol 'admin' o username 'senka') va
  SIEMPRE al centro de la fila, calculado como `largo ~/ 2` sobre la lista
  real (nunca un índice hardcodeado); en mobile (1 columna) va primero.
  Su card lleva `destacada: true` (brackets de circuito).

## Panel interno — secciones clave

- **Dashboard** (`lib/screens/panel/dashboard_screen.dart`): SOLO admin.total,
  primera sección del menú. Calcula en tiempo real desde Firestore: ranking
  de servicios más cotizados ("qué pide más la gente"), pedidos pendientes,
  cotizaciones sin responder, facturación estimada del mes (suma de
  `calculo.precioVenta` de pedidos del mes) y comisión acumulada de Luchin
  con toggle este mes / histórico.
- **Catálogo 3D admin** (`lib/screens/panel/catalogo3d_admin_screen.dart`):
  permiso `catalogo3d.administrar` (Luchin y Admin). CRUD completo de
  `impresiones3d` con TODAS las piezas (usa `obtenerTodasImpresiones3D()`,
  sin filtro de disponible). Las reglas de Firestore restringen la escritura
  de `impresiones3d` a ese permiso (función genérica `tienePermiso()` en
  firestore.rules).
- **Botón flotante de WhatsApp** (`lib/widgets/whatsapp_flotante.dart`):
  presente en TODAS las pantallas públicas vía `floatingActionButton`, nunca
  en el panel. Es EL punto de contacto genérico — no agregar más botones de
  "escribinos por WhatsApp" genéricos en pantallas públicas (los específicos
  como "Cotizar esta pieza" o "Hablar con [nombre]" sí se mantienen).
- **Generar Cotización** (`lib/screens/panel/cotizacion_pdf_screen.dart`,
  permiso `cotizaciones.generar`): arma una cotización profesional en PDF
  para cualquier trabajo (bots, apps, Arduino, 3D, entrenamiento, pintado).
  **NO usa Firestore para nada** — es intencional: el PDF descargado ES el
  registro de la cotización, así el precio que ya vio el cliente no puede
  cambiar por accidente después (si hace falta corregir algo, se genera un
  PDF nuevo). Por eso este permiso no depende de `pedidos.crear` ni de
  ningún otro — es independiente, y se asigna a mano por usuario. Al salir
  de la sección el formulario se pierde solo (el widget se destruye), no
  hay que "limpiar" nada.
  - Tiene una sección embebida "Usar Calculadora 3D" (misma fórmula que
    `CalculoCostos3D` en `models.dart`) que agrega un ítem precargado con
    el precio calculado — ese precio queda como texto editable en la tabla
    de ítems por si hay que ajustarlo antes de descargar.
  - `lib/services/pdf_cotizacion_service.dart` arma el documento con el
    paquete `pdf` (fuente Helvetica estándar — soporta tildes/ñ sin
    depender de bajar una fuente por red al exportar); `lib/screens/panel/
    cotizacion_pdf_screen.dart` usa `PdfPreview` del paquete `printing`
    para la vista previa en vivo (se regenera solo al tipear) y para
    imprimir/descargar. Ambos paquetes funcionan en Flutter Web.

## Calculadora de costos 3D

Fórmula exacta (no cambiar sin confirmar con Senka), en Bolivianos:
```
costoMaterial   = (peso_gramos/1000) * precioFilamento_Bs_kg
costoElectrico  = (potencia_W/1000) * tiempoHoras * precioKwh
subtotal        = costoMaterial + costoElectrico
costoDesgaste   = subtotal * (desgaste%/100)
conDesgaste     = subtotal + costoDesgaste
costoFallos     = conDesgaste * (fallos%/100)
costoTotal      = conDesgaste + costoFallos
precioVenta     = costoTotal * (1 + margen%/100)
```
Implementada en `lib/models/models.dart` (clase `CalculoCostos3D`) y usada en
`lib/screens/panel/calculadora_screen.dart`.

## Catálogo 3D — importante

`impresiones3d.disponible` significa **"tenemos el archivo, se puede imprimir
bajo pedido"** — NO es stock físico. No hay piezas prefabricadas guardadas.
Los modelos vienen de 3 fuentes (campo interno `origenModelo`, el cliente no
lo ve): diseño propio de Luchin, comprado en otra página, o archivo que quedó
de un pedido anterior.

## Carrito del Catálogo 3D (agosto 2026)

El cliente puede agregar varias piezas al carrito (color + cantidad cada
una) y mandar todo junto por WhatsApp, en vez de cotizar pieza por pieza.
Todo vive en `lib/screens/catalogo/catalogo_3d_screen.dart`:

- **Carrito en memoria** (`_ItemCarrito`, dentro de `_Catalogo3dScreenState`):
  no se guarda entre visitas — mismo criterio "sin cuentas" del resto del
  sitio. Botón flotante con badge de cantidad, arriba del de WhatsApp
  (`Scaffold.floatingActionButton` es un `Column` con los dos).
- **Colores: lista GLOBAL, no por pieza** (cambio respecto a versiones
  anteriores — antes `Impresion3D.coloresDisponibles` se cargaba a mano,
  repetida, en cada pieza). Ahora vive en Firestore
  `configuracion/colores3d` (campo `lista: string[]`), editable desde una
  sección nueva arriba del listado en `catalogo3d_admin_screen.dart`
  (`_ColoresGlobalesSection`, permiso `catalogo3d.administrar`). Lectura
  pública (el catálogo sin login la necesita), escritura solo admin del
  catálogo — ver bloque `configuracion` en `firestore.rules`.
- **Checkout** (`_CarritoDialog`): al mandar el pedido, (1) se guarda un
  registro en `pedidosCarrito3d` (Firestore, `create: if true`, es
  inmutable — solo un log, nunca se edita) y (2) se abre WhatsApp con el
  pedido itemizado (pieza, color, cantidad, subtotal, total), directo al
  número de Admin — mismo patrón que `WhatsAppHelper` ya usaba para
  cotizaciones. El registro de Firestore es lo único que alimenta el
  Dashboard; NO reemplaza al `Pedido` real que Admin/Luchin cargan a mano
  después de hablar con el cliente.
- **Dashboard**: sección "Piezas del catálogo 3D más pedidas"
  (`dashboard_screen.dart`, `_rankingPiezas`) — suma cantidades de
  `pedidosCarrito3d.items` agrupadas por nombre de pieza, mismo widget
  visual (`_FilaRanking`) que el ranking de servicios cotizados.

## Manual de marca (seguir estrictamente)

Colores oficiales (`lib/theme/app_colors.dart`):
- Negro profundo `#000000`, Violeta oscuro `#26215C`, Violeta principal `#7F77DD`
- Blanco `#FFFFFF`, Cian tech `#00FFFF`, Gris secundario `#B8B8C8`
- Base SIEMPRE negro + violeta + blanco. Colores de categoría (verde IoT, cian
  software, naranja gaming, rosa arte) son acentos, nunca dominan.

Sistema gráfico: marcos con esquinas rectas (no redondeadas tipo pill), glow
violeta sutil (nunca excesivo), líneas de circuito finas en esquinas (ver
`lib/widgets/tech_corner_decoration.dart`), tipografía limpia sin cursivas.

Logos ya extraídos en `assets/logos/`:
- `logo_57nations.png` — rectangular, para Navbar/Footer
- `logo_57_cuadrado.png` — cuadrado, para favicon/ícono de app

## Dirección visual: minimalista (agosto 2026 — CRITERIO VIGENTE)

El rediseño de julio 2026 (sección siguiente) quedó demasiado "tech
maximalista/gamer": muchos badges/chips, glows constantes, varios colores
de categoría compitiendo a la vez. Se corrigió hacia minimalismo — **la
paleta de `app_colors.dart` NO cambió**, cambió cuánto y cómo se usa:

- **Un solo acento de color por pantalla/sección**, nunca varios
  compitiendo. Los colores de categoría (`botColor`, `flutterColor`,
  `arduinoColor`, `impresion3dColor`, `entrenamientoColor`) se reservan
  para usos PEQUEÑOS y puntuales (el tinte de un ícono, por ejemplo en
  `ServiceCard`), nunca para el chrome completo de una card (borde, sombra,
  fondo) cuando hay varias cards de distinta categoría visibles juntas —
  ahí todas comparten un único acento (violeta, el primario del sitio).
  Una página de un solo servicio (`ServicioScreenBase` + `colorAcento`) sí
  puede usar su color de categoría como acento único de esa página entera,
  porque ahí no compite con nada más.
- **`TechCornerDecoration` (las líneas en L de las esquinas) SOLO en el
  Hero del Home** — en ningún otro lugar del sitio. Antes estaba también en
  `PageHero` (o sea, en la cabecera de TODAS las páginas internas) y en el
  banner de cierre del Home; se sacó de los dos.
- **`TechCard.showCornerBrackets`**: ya no se usa en ningún lado del sitio
  (se sacó de las 5 páginas de servicio, Contacto, Cotización, Home,
  Dashboard, Calculadora y Login). El prop sigue existiendo en el widget
  por compatibilidad, pero no pasar `showCornerBrackets: true` en código
  nuevo — quedó reservado conceptualmente para nada, es dead code a propósito
  (más fácil de reactivar que de recrear si algún día hace falta).
- **Tipografía: Inter** (paquete `google_fonts`, `GoogleFonts.interTextTheme()`
  envolviendo el `TextTheme` de `AppTheme._buildTextTheme()`). Geométrica,
  muy legible, sin la personalidad "tech gamer" que tenía la fuente default
  de Flutter en cuerpos grandes. Se carga desde Google Fonts (no hay .ttf
  bundleado) — es el mismo patrón que usa cualquier sitio web con Google
  Fonts, funciona igual en Firebase Hosting. Si el manual de marca define
  una tipografía oficial más adelante, reemplazar acá.
- **`PageHero` ya no tiene grid de circuito de fondo** (`CircuitGridPainter`
  sigue existiendo como clase, pero `PageHero` no la instancia más) — solo
  un glow radial sutil (alpha 0.12) en el acento de la página.
- **Botones: un solo estilo primario (violeta sólido, el default del
  tema) y un solo estilo secundario (outline, el default del tema)** en
  todo el sitio. Nunca overrides ad hoc de color (ej. el CTA "COTIZAR
  PROYECTO" del Home tenía un tercer estilo cian-sólido suelto — se sacó,
  ahora usa el `ElevatedButton` default).
- **Sombras/glows sutiles y puntuales**, no decoración ambiental constante:
  blur ~14, alpha ~0.12-0.14 como estándar (antes blur 20, alpha 0.22).
- **Copy accesible**: las descripciones de servicios (Home y páginas de
  servicio) están escritas para alguien sin conocimiento técnico — frases
  cortas, ejemplos cotidianos en vez de jerga. Si hay que nombrar algo
  técnico, se explica en la misma frase con un ejemplo (ej. Arduino/ESP32:
  "conectamos objetos a internet para que los controles desde tu celular").
- **Equipo (`EquipoCarrusel`/`MiembroEquipoCard`) explícitamente excluido**
  de este cambio — su estructura e interacción (carrusel tipo song-select,
  card central grande) se mantienen tal cual; solo se le bajó la sombra al
  mismo estándar sutil del resto.
- **Estado del rollout**: COMPLETO (agosto 2026) en todo el sitio público y
  el panel — Home, las 5 páginas de servicio, Portfolio, detalle de
  proyecto, Catálogo 3D (público y admin), Contacto, Cotización, Sobre
  Nosotros, perfil de equipo, y el panel entero (Dashboard, Pedidos,
  Pintado, Cotizaciones, Login, Calculadora, Mi Currículum). Auditado con
  grep sitewide (sin `showCornerBrackets: true`, sin sombras con alpha
  >0.14 salvo dos usos puntuales legítimos: el fill de un bullet chico en
  el perfil de equipo, y el `selectedColor` de los chips del theme, que no
  son "glow" sino intensidad de relleno de un estado seleccionado).

## Sistema de diseño UI (rediseño julio 2026 — seguir SIEMPRE)

Rediseño completo del sitio público + panel aplicando el manual de marca.
Reglas establecidas; cualquier pantalla nueva debe respetarlas:

- **Esquinas recortadas, no redondeadas**: el theme global usa
  `BeveledRectangleBorder` (chaflán) en botones, cards, chips, diálogos,
  snackbars, etc. Para formas custom usar `AppTheme.cutCorner()`
  (`lib/theme/app_theme.dart`). Excepción: los inputs usan `OutlineInputBorder`
  con radio 2 (el framework exige `InputBorder`), que se ve prácticamente recto.
- **Escala de espaciado** en `lib/theme/app_spacing.dart` (`AppSpacing`):
  4/8/12/16/24/32/48/64/96. NUNCA valores sueltos tipo 17 o 23.
  `AppSpacing.horizontal(context)`/`.vertical(context)` = padding estándar de
  página; `AppSpacing.panel(context)` = padding del área de trabajo del panel;
  `maxContentWidth = 1200` centra el contenido en monitores anchos.
- **Breakpoints SOLO vía `Responsive`** (`lib/utils/responsive.dart`):
  mobile <800, tablet 800-1200, desktop >=1200, e `isCompact` (<900) para el
  panel interno. Helper `Responsive.valor(context, mobile:…, tablet:…, desktop:…)`.
  Prohibido comparar `MediaQuery...width` contra números sueltos en pantallas.
- **Widgets compartidos** en `lib/widgets/` (exportados por `widgets.dart`):
  - `TechCard` — card estándar: esquinas recortadas + glow violeta sutil al
    hover; `showCornerBrackets` en retiro, ver "Dirección visual: minimalista".
  - `SectionHeader` — overline con línea de circuito + título + subtítulo;
    `compacto: true` dentro del panel.
  - `PageSection` — sección pública con fondo alternado (negro/surface),
    padding del sistema y contenido centrado a 1200px.
  - `StatusBadge` + `colorEstadoPedido()` + `FlujoPedidoStepper`
    (`status_badge.dart`) — estados de pedido centralizados; nunca duplicar
    el mapa de colores por pantalla.
  - `PageHero` — hero de páginas internas: overline + acciones opcionales;
    sin grid de fondo (ver "Dirección visual: minimalista").
    `CircuitGridPainter` sigue existiendo para usos chicos y puntuales
    (placeholders de foto en `ProyectoCard`/`MiembroEquipoCard`).
  - `ServicioScreenBase` (`lib/screens/servicios/servicio_screen_base.dart`) —
    plantilla única de las 5 páginas de servicio (hero + capacidades + CTA).
- **Glow siempre sutil y nunca en todo a la vez** (manual): solo en hover de
  elementos interactivos, el precio destacado de la calculadora y el glow
  radial del banner de cierre del Home.
- **Animaciones de entrada al scroll**: `AparecerAlScroll`
  (`lib/widgets/aparecer_al_scroll.dart`, usa flutter_animate +
  visibility_detector): fade-in + slide-up de 350ms, se dispara UNA sola vez
  cuando la sección entra al viewport. Usado en las secciones del Home
  (Servicios, Portfolio, Equipo, banner de cierre). NUNCA en el Hero ni en
  contenido above-the-fold, y siempre sutil (nada de rebotes ni escalas).
- **Home**: el Hero cubre TODA la pantalla al entrar (minHeight = alto de
  viewport menos navbar, contenido centrado verticalmente). Ver sección
  dedicada "Dirección visual definitiva del Hero (agosto 2026)" más abajo —
  **la nota vieja de "logo grande como protagonista" quedó superada**, ya
  no aplica.
  El equipo se muestra con `EquipoCarrusel`
  (`lib/widgets/equipo_carrusel.dart`): carrusel tipo song-select de Pump It
  Up — card central grande y seleccionada, vecinas chicas y atenuadas,
  flechas con rotación infinita, indicador de posición, click al centro →
  perfil público. Senka (admin) es SIEMPRE el seleccionado inicial (vía
  `esMiembroAdmin`, nunca índice fijo). Las cards son verticales (foto
  retrato 3:4 vía `MiembroEquipoCard.aspectRatioFoto`, todas idénticas);
  Sobre Nosotros usa las mismas cards en grilla con
  `ordenarEquipoConAdminAlCentro()`. Las secciones se separan con `_TransicionSeccion`
  (franja de gradiente vertical) para que el cambio de fondo no sea un
  corte seco;
  la alternancia de fondos es negro → surface → negro → negro (el Hero y
  el banner de cierre son negro plano con `TechBackground`, ya no
  gradiente). El preview de Portfolio muestra los 3
  proyectos más recientes con `ProyectoCard` (widget compartido con la
  página de Portfolio — no duplicar cards de proyecto); sin proyectos cae
  a un estado vacío elegante con CTA. Los servicios ya NO son una grilla de
  cards — ver sección dedicada abajo.
- **Nada de emojis como íconos de datos** en el panel: usar `Icons.*_outlined`
  (patrón `_InfoFila` en `pedidos_screen.dart`).
- **Navegación**: la Navbar resalta la ruta activa (compara
  `ModalRoute.settings.name`), el menú Servicios usa `MenuAnchor` anclado, y
  el menú mobile es un panel lateral deslizante (no bottom sheet).
- **Tipografía**: sigue la default de Flutter (no hay .ttf del manual todavía).
  Jerarquía por peso/tamaño/letter-spacing en `AppTheme._buildTextTheme`.
  Overlines siempre en MAYÚSCULAS con letterSpacing 2+.

## Dirección visual definitiva del Hero (agosto 2026)

Segundo pase sobre el Hero del Home (el primero fue el rediseño de julio
2026 con el logo grande; ese quedó superado). Concepto aprobado por Senka:
**la tipografía es la protagonista, no el logo**. Reglas:

- **Copy del Hero (fijo, no placeholder)**: cuatro líneas en bloque,
  "OTROS" y "DISEÑAN." en gris tenue (`AppColors.textDim`, lo esperable) y
  "NOSOTROS" y "CONSTRUIMOS." en blanco pleno (`AppColors.textLight`, lo
  que ofrece 57 Nations) — el contraste de color hace el argumento sin
  necesitar más texto. Implementado con un solo `RichText`/`TextSpan` en
  `_HeroSection` (`lib/screens/home_screen.dart`). Tamaño responsive vía
  `Responsive` (no los breakpoints literales que se hayan mencionado en
  algún chat — siempre los de `lib/utils/responsive.dart`): mobile 42,
  tablet 64, desktop 92. El logo YA NO aparece en el Hero.
- **Fondo del Hero = foto real, no `TechBackground`** (agosto 2026, v3):
  `assets/images/hero_bg.jpg` (imagen generada por IA: placa/chip ESP32,
  cubo isométrico wireframe, código — Senka la trajo hecha). La carpeta
  `assets/images/` ya está declarada en `pubspec.yaml` (glob de carpeta),
  así que un archivo nuevo ahí no necesita ningún cambio de config, con
  ESE nombre exacto. Si el archivo no existe, `Image.asset` cae a
  `errorBuilder` y muestra `TechBackground` en su lugar — la pantalla
  nunca se rompe por la ausencia del archivo.
  Encima de la foto va un degradé horizontal (`AppColors.background`,
  transparente a la izquierda → alpha ~0.8 a la derecha) porque el texto
  del Hero se movió al lado DERECHO (`crossAxisAlignment.end` +
  `textAlign.right` en todo el bloque) — el lado izquierdo/centro de la
  foto es el más "ocupado" visualmente (chip, circuito, watermark "57")
  y no debía competir con el texto. `TechBackground` YA NO se usa en el
  Hero, solo sigue en el banner de cierre (`_CotizarBanner`,
  `opacidad: 0.4`) porque para ese no hay foto.
- **`TechBackground`** (`lib/widgets/tech_background.dart`, exportado por
  `widgets.dart`) — widget de fondo técnico reutilizable, `CustomPainter`
  con capas vectoriales fijas (nada de random/partículas animadas):
  grid tipo blueprint cada 80px, watermark "57" gigante (~260px, weight
  900), glow radial violeta y, SOLO cuando el ancho real del canvas es
  >= 900px, un clúster técnico alineado a la derecha (chip ESP32, cubo
  isométrico wireframe, arcos de wifi, snippets de código monospace y
  trazas de PCB conectándolos) — en mobile/tablet angosto ese clúster se
  omite para no chocar con el texto, queda solo grid + watermark + glow.
  Recibe un parámetro `opacidad` (1.0 default). Se usa DOS veces: en el
  Hero (`opacidad` default) y en el banner de cierre `_CotizarBanner`
  (`opacidad: 0.4`) — es el único lenguaje de fondo técnico del sitio,
  ya no hay `AppColors.primaryGradient` en ninguno de los dos. Si se
  necesita en un tercer lugar, reutilizar este widget, no crear otro.
- **Servicios sin cards**: `_ServiciosSection` ya no es una grilla de
  `ServiceCard` (ese widget se BORRÓ, `lib/widgets/service_card.dart` no
  existe más) — es una lista numerada minimalista (`_ServicioFila`, mismo
  archivo `home_screen.dart`): número (01-05) + título + descripción de
  una sola línea (≤ 8 palabras) + flecha, separados por una regla fina
  violeta al 18% de opacidad, con hover que resalta el número/título en
  violeta y desliza la flecha. Si se agrega un sexto servicio, solo hace
  falta sumar una tupla a `_ServiciosSection._servicios`.
- **Ajustes visuales cascada a widgets compartidos** (mismo criterio: un
  solo acento, sin gradientes de fondo salvo `TechBackground`):
  - `NavBar` (`lib/widgets/navbar.dart`): fondo negro, separador inferior
    violeta al 25% de opacidad (antes `AppColors.border`), hover de los
    links pasa a blanco sin línea animada (antes cian con subrayado), y
    el botón "CONTACTO" (desktop y el del panel mobile) pasa de
    `ElevatedButton` sólido a `OutlinedButton` cian — ya no hay un botón
    violeta sólido en la navbar.
  - `ProyectoCard` (`lib/widgets/proyecto_card.dart`) y
    `MiembroEquipoCard` (`lib/widgets/miembro_equipo_card.dart`): fondo
    `AppColors.background` (negro puro, antes `surfaceElevated`) y borde
    violeta con opacidad animada 30% → 80% al hover (antes color sólido
    `border`/`violetaPrincipal`). `ProyectoCard` además: la foto ahora
    tiene zoom sutil (`AnimatedScale` a 1.02) al hover, igual que ya
    tenía `MiembroEquipoCard`. Ambos widgets son compartidos — este
    cambio de color se ve también en la página de Portfolio completa y
    en Sobre Nosotros (disclosed, no accidental). La estructura y toda
    la interacción (click, `EquipoCarrusel`, filtros de Portfolio) NO
    cambiaron.
- **Animación de entrada del Hero**: `flutter_animate` directo (fade +
  slideY, delays escalonados 0/120/260/400ms), NO `AparecerAlScroll` — el
  Hero es above-the-fold y se anima una vez al cargar la página, nunca al
  hacer scroll (`AparecerAlScroll` sigue siendo solo para las secciones
  de abajo, sin cambios ahí).

## Estado actual (qué falta)

- [x] Agregar `origenPedido` y `comisionLuchin` al modelo `Pedido` + pantallas
- [x] Aplicar la estética de marca a TODO el sitio público y el panel
      (rediseño completo julio 2026 — ver sección "Sistema de diseño UI")
- [x] Subida real de fotos — resuelto con Cloudinary (ver sección "Fotos"),
      Storage/Blaze ya no hace falta
- [x] Detalle de proyecto del Portfolio: implementado con galería multi-foto,
      lightbox, tecnologías y contenido detallado
- [x] Botón "VER" del Catálogo 3D: abre modal de detalle de pieza con specs y
      botón "Cotizar esta pieza" por WhatsApp
- [x] Currículums editables por cada socio ("Mi Currículum" en el panel) y
      sección Equipo del Home mostrando datos reales
- [x] `AppConfig.whatsappAdminNumero` ya tiene el número real de Senka —
      cotizaciones y botones de contacto llegan a su chat
- [x] Admin puede eliminar cotizaciones desde el panel (permiso
      `cotizaciones.eliminar`, implícito en admin.total; reglas de Firestore
      también restringen el delete a admin)
- [ ] Pantalla para que Admin cree usuarios sin ir a Firebase Console
- [x] Dirección visual minimalista aplicada a TODO el sitio (agosto 2026 —
      ver sección "Dirección visual: minimalista") + tipografía Inter
- [x] Copy de las 5 páginas de servicio y del Home reescrito en lenguaje
      simple, sin jerga sin explicar (Bots, Flutter, Arduino/ESP32,
      Impresión 3D, Entrenamiento) — sigue siendo la redacción de Claude,
      falta que Senka la lea y confirme que es precisa
- [ ] Si el manual de marca nombra una tipografía oficial (sección 04),
      reemplazar Inter por esa fuente en `AppTheme`
- [ ] Arreglar `.github/workflows/firebase-hosting-pull-request.yml` (mismo
      fix que se hizo en `firebase-hosting-merge.yml`: agregar pasos de
      Flutter en vez de `npm ci && npm run build`)
- [x] Service worker: usuarios que ya visitaron el sitio quedaban
      atascados en versiones viejas — resuelto con `hosting.headers` en
      `firebase.json` (ver "Gotchas ya resueltos")
- [x] Manejo de errores honesto en las 13 pantallas que leen Firestore
      (`mensajeErrorCarga`, ver sección dedicada) — distingue permisos,
      índice faltante y red real en vez del genérico "revisá tu conexión"
- [ ] **Crear los 3 índices compuestos de Firestore** que hacen falta
      (ver sección "Índices compuestos de Firestore — pendientes de
      crear" con los links exactos) — sin esto, Catálogo 3D y el panel
      de Fifi pueden mostrar "Falta configurar un índice"
- [x] URLs limpias sin `#` (`usePathUrlStrategy()`) + página
      `/gracias` para el link de los llaveros NFC (ver sección "Producto:
      llaveros NFC")
- [x] Segundo rediseño del Hero del Home: tipografía protagonista en vez
      del logo, `TechBackground` como fondo técnico reutilizable (Hero +
      banner de cierre), servicios sin cards (lista numerada), NavBar y
      `ProyectoCard`/`MiembroEquipoCard` recoloreados a juego (agosto
      2026 — ver sección "Dirección visual definitiva del Hero")
- [x] Foto real de fondo del Hero (`assets/images/hero_bg.jpg`) en vez de
      `TechBackground`, texto movido al lado derecho — ver sección
      "Dirección visual definitiva del Hero"
- [x] Carrito del Catálogo 3D (agregar varias piezas, color + cantidad,
      un solo WhatsApp con todo) + colores globales editables desde el
      panel + ranking "piezas más pedidas" en el Dashboard — ver sección
      "Carrito del Catálogo 3D"

## Manejo de errores de Firestore

`lib/utils/firestore_errors.dart` (`mensajeErrorCarga(error, queCargaba:)`)
está conectado en las 13 pantallas que leen de Firestore (Catálogo 3D
público y admin, Portfolio, detalle de proyecto, Sobre Nosotros, Home
(equipo), perfil de equipo, Dashboard, Pedidos, Pintado, Cotizaciones,
Portfolio admin, Mi Currículum). Distingue `permission-denied` /
`failed-precondition` (índice faltante) / red real, en vez del genérico
"revisá tu conexión" que ocultaba la causa real. En modo debug loguea el
error completo con `debugPrint` (para `failed-precondition` eso incluye el
link exacto de Firebase para crear el índice). `login_screen.dart` NO usa
este helper a propósito — su error es de autenticación, no de lectura.

## Índices compuestos de Firestore — pendientes de crear

Estas queries necesitan un índice compuesto (Firestore lo exige cuando se
combina un `where` de igualdad con `orderBy` sobre un campo distinto). Sin
el índice, la pantalla correspondiente muestra "Falta configurar un índice"
(gracias al manejo de errores de arriba, ya no dice "revisá tu conexión").
Crear en Firebase Console → Firestore Database → Índices → Composite:

1. **`obtenerImpresiones3D()`** (catálogo público) — colección
   `impresiones3d`: `disponible` Ascending + `fechaCreacion` Descending.
   Link directo (ya confirmado, trae los campos precargados):
   https://console.firebase.google.com/v1/r/project/nations-2b049/firestore/indexes?create_composite=ClNwcm9qZWN0cy9uYXRpb25zLTJiMDQ5L2RhdGFiYXNlcy8oZGVmYXVsdCkvY29sbGVjdGlvbkdyb3Vwcy9pbXByZXNpb25lczNkL2luZGV4ZXMvXxABGg4KCmRpc3BvbmlibGUQARoRCg1mZWNoYUNyZWFjaW9uEAIaDAoIX19uYW1lX18QAg
2. **`obtenerImpresiones3DPorCategoria()`** — colección `impresiones3d`:
   `categoria` Ascending + `disponible` Ascending + `fechaCreacion`
   Descending. Link directo:
   https://console.firebase.google.com/v1/r/project/nations-2b049/firestore/indexes?create_composite=ClNwcm9qZWN0cy9uYXRpb25zLTJiMDQ5L2RhdGFiYXNlcy8oZGVmYXVsdCkvY29sbGVjdGlvbkdyb3Vwcy9pbXByZXNpb25lczNkL2luZGV4ZXMvXxABGg0KCWNhdGVnb3JpYRABGg4KCmRpc3BvbmlibGUQARoRCg1mZWNoYUNyZWFjaW9uEAIaDAoIX19uYW1lX18QAg
3. **`obtenerPedidosParaPintado()`** (panel de Fifi) — colección `pedidos`:
   `requierePintado` Ascending + `estado` Ascending + `fechaCreacion`
   Descending. Sin link directo probado (esa colección exige login, no se
   pudo disparar el error sin credenciales) — crear a mano con esos 3
   campos en ese orden, o esperar a que Fifi entre a "Pendientes de
   Pintar" y usar el link que Firestore tire ahí en la consola del
   navegador.

**No confirmado si Senka ya los creó** — si algún día una de estas 3
pantallas vuelve a fallar, empezar por acá antes de re-investigar desde
cero.

## Gotchas ya resueltos (no repetir)

- Las versiones de Firebase en pubspec.yaml deben ser recientes — versiones
  viejas (`firebase_auth: ^4.15.0` de fines de 2023) rompen con SDKs nuevos
  de Flutter (error `PromiseJsImpl not found`). Usar `flutter pub upgrade`
  si hay dudas, no solo `pub get`.
- Los assets nuevos (imágenes) requieren **restart completo** de
  `flutter run`, un hot reload no alcanza.
- El logo extraído del PDF del manual de marca tenía fondo negro sólido, no
  transparencia real — se resolvió con croma key (remover negro por color),
  no con máscara alpha del PDF (esa venía vacía/inútil).
- **Usuarios que ya visitaron el sitio quedaban atascados en versiones
  viejas** (necesitaban desregistrar el service worker a mano para ver
  cambios nuevos). Causa raíz: `firebase.json` no tenía `headers`, así que
  Firebase Hosting cacheaba `index.html`/`flutter_bootstrap.js`/
  `flutter_service_worker.js` por default. El service worker que genera
  `flutter build web` sirve esos archivos en modo "cache-first" una vez
  que ya los tiene guardados — si el navegador nunca vuelve a pedirlos
  frescos al servidor (porque el CDN los cachea), el service worker viejo
  nunca se entera de que hay una versión nueva, y sigue sirviendo la app
  vieja indefinidamente sin ningún error visible. Se resolvió agregando
  `hosting.headers` en `firebase.json`: `Cache-Control: no-cache` por
  default en TODO (`**`), con una excepción de cache largo/inmutable solo
  para `canvaskit/`, `assets/` e `icons/` (esos son seguros de cachear
  fuerte porque el propio `flutter_service_worker.js` los versiona por
  hash de contenido y los vuelve a bajar solo si cambiaron). **No sacar
  este bloque de `headers` ni reemplazarlo por algo más permisivo** — es
  lo que garantiza que un usuario que ya visitó el sitio reciba la versión
  nueva en su siguiente recarga, sin acción manual de su parte.

## Comandos frecuentes

```powershell
flutter pub get
flutter run -d chrome
flutter build web --release
git add . && git commit -m "mensaje" && git push   # dispara deploy automático
```
