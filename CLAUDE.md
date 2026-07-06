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

**Pendiente de implementar**: `origenPedido` ("senka"|"luchin") y
`comisionLuchin` (porcentaje configurable, default en `configuracion/general`
en Firestore, editable por pedido) — el modelo `Pedido` en
`lib/models/models.dart` todavía NO tiene estos campos, hay que agregarlos.

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

## Estado actual (qué falta)

- [ ] Agregar `origenPedido` y `comisionLuchin` al modelo `Pedido` + pantallas
- [ ] Terminar de aplicar la estética de marca al resto del sitio público
      (Servicios, Portfolio, Contacto, Sobre Nosotros — el Home/Navbar/Footer
      ya están al día)
- [ ] Subida real de fotos a Storage (hoy es URL manual, Storage requiere
      plan Blaze — evaluar si vale la pena o seguir con URLs)
- [ ] Pantalla para que Admin cree usuarios sin ir a Firebase Console
- [ ] Completar contenido real de las 5 páginas de servicios (hoy son stubs)
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
