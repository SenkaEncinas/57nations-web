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

## Personas y roles

- **Senka** (Admin): dueño, imprime en 3D él mismo, ve y edita todo (`admin.total`)
- **Luchin**: socio/diseñador 3D, NO imprime — solo cotiza con la calculadora y
  trae clientes propios (gana comisión sobre la utilidad de esos pedidos).
  Permisos: `pedidos.ver_todos`, `pedidos.crear`, `calculadora.usar`
- **Fifi Oyster**: pinta piezas 3D bajo pedido. Solo ve lo esencial de pedidos
  que requieren pintado (pieza, foto, colores, fecha límite — NUNCA cliente/precio).
  Permiso: `pedidos.ver_pintado`
- **Moe**: fue CLIENTA de un proyecto puntual (Cosechá), NO es colaboradora
  interna. No darle acceso al panel, ni cuenta interna, ni documento en `equipo`.

El equipo interno (Senka, Luchin, Fifi y futuros socios) edita su propio
currículum público desde el panel ("Mi Currículum", permiso
`equipo.editar_propio`) — ver sección "Equipo / currículums".

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
  nuevos el id del doc = username) y `biografia` (texto libre multilínea,
  sin límite — cada uno se presenta como quiere).
- Reglas de Firestore: lectura pública; create/update solo si
  `username` del documento == username del solicitante (o admin);
  delete solo admin. Ver bloque `equipo` en firestore.rules.
- La web pública muestra el equipo con `MiembroEquipoCard`
  (`lib/widgets/miembro_equipo_card.dart`): foto, rol, especialidad, bio
  truncada con "Ver más" expandible y links a redes. Se usa en Home y en
  Sobre Nosotros — no crear otra card de miembro.

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
    hover; `showCornerBrackets: true` solo en cards destacadas (no saturar).
  - `SectionHeader` — overline con línea de circuito + título + subtítulo;
    `compacto: true` dentro del panel.
  - `PageSection` — sección pública con fondo alternado (negro/surface),
    padding del sistema y contenido centrado a 1200px.
  - `StatusBadge` + `colorEstadoPedido()` + `FlujoPedidoStepper`
    (`status_badge.dart`) — estados de pedido centralizados; nunca duplicar
    el mapa de colores por pantalla.
  - `PageHero` — hero de páginas internas: overline, grid de circuito sutil
    (`CircuitGridPainter`, reutilizable en fondos) y acciones opcionales.
  - `ServicioScreenBase` (`lib/screens/servicios/servicio_screen_base.dart`) —
    plantilla única de las 5 páginas de servicio (hero + capacidades + CTA).
- **Glow siempre sutil y nunca en todo a la vez** (manual): solo en hover de
  elementos interactivos y en el precio destacado de la calculadora.
- **Nada de emojis como íconos de datos** en el panel: usar `Icons.*_outlined`
  (patrón `_InfoFila` en `pedidos_screen.dart`).
- **Navegación**: la Navbar resalta la ruta activa (compara
  `ModalRoute.settings.name`), el menú Servicios usa `MenuAnchor` anclado, y
  el menú mobile es un panel lateral deslizante (no bottom sheet).
- **Tipografía**: sigue la default de Flutter (no hay .ttf del manual todavía).
  Jerarquía por peso/tamaño/letter-spacing en `AppTheme._buildTextTheme`.
  Overlines siempre en MAYÚSCULAS con letterSpacing 2+.

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
- [ ] **Reemplazar `AppConfig.whatsappAdminNumero`** (sigue siendo el
      placeholder `59100000000`): TODOS los botones de WhatsApp apuntan a un
      número falso hasta que Senka pase el real
- [ ] Pantalla para que Admin cree usuarios sin ir a Firebase Console
- [ ] Validar/completar contenido real de las 5 páginas de servicios: ya usan
      `ServicioScreenBase` con capacidades derivadas de las descripciones del
      Home, falta que Senka confirme los textos definitivos
- [ ] Si el manual de marca nombra una tipografía oficial (sección 04),
      conseguir el .ttf, declararla en pubspec y usarla en AppTheme
- [ ] Arreglar `.github/workflows/firebase-hosting-pull-request.yml` (mismo
      fix que se hizo en `firebase-hosting-merge.yml`: agregar pasos de
      Flutter en vez de `npm ci && npm run build`)

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

## Comandos frecuentes

```powershell
flutter pub get
flutter run -d chrome
flutter build web --release
git add . && git commit -m "mensaje" && git push   # dispara deploy automático
```
