# PROMPT_LOG — Assignment 2: Progreso de lecciones por usuario

Proyecto: FinCopa · Repo: https://github.com/fernando77-ai/aat-mockup-fernando · Deploy: https://aat-mockup-fernando.vercel.app

## 1. Especificación (3 campos)

**Qué hace.** Sección "Lecciones" con 3 lecciones fijas en HTML (1. Qué es la tasa de Banxico, 2. Por qué la Fed te afecta en México, 3. Inflación y tu dinero). Con sesión iniciada, cada lección tiene un botón "Marcar como completada" / "Desmarcar" y arriba aparece "Llevas X de 3 lecciones". Sin sesión, invita a iniciar sesión.

**Qué datos necesita.** Tabla nueva `public.progreso` en Supabase: `usuario_id` (uuid, referencia a auth.users, default `auth.uid()`), `leccion` (smallint entre 1 y 3), `completada_en` (timestamptz). Llave primaria (usuario_id, leccion). RLS activado con 3 políticas por dueño (select, insert, delete). Solo se usa la clave pública (anon) en el frontend. El SQL está en `sql/01_progreso.sql`.

**Cómo se sabrá que funciona.** El usuario A completa la lección 2, cierra sesión, vuelve a entrar y ve "Llevas 1 de 3" con la lección 2 marcada. El usuario B entra y ve "Llevas 0 de 3". Recargar la página conserva el conteo. Registro, login, recarga y cierre de sesión siguen funcionando.

Origen: la propuso Claude Code. Fernando la aceptó y siguió con ella (2026-11-17).

## 2. Decisiones de construcción

**2026-11-17 · Aceptar · campo "qué datos necesita".** Claude Code propuso la tabla `progreso` con RLS por dueño. Se aceptó tal cual. Razón (Fernando): la tabla se mantuvo porque en la validación todo funcionó correctamente.

**2026-11-17 · Revisar · campo "qué datos necesita".** Orden de entrega: correr el SQL en Supabase primero y subir el código a `main` después, para que el sitio nunca llame a una tabla que no existe. El SQL se corrió desde el editor de Supabase y se verificó con una consulta: la tabla `progreso` con RLS en `true` y 3 políticas (DELETE, INSERT, SELECT, solo `authenticated`).

**2026-11-17 · Revisar · (entrega).** Claude Code hizo 2 commits locales (`9b71558`, `35047fd`), pero el push a `main` falló con 403 por falta de permiso de escritura. Decisión: no reintentar y subir los archivos a mano a GitHub. Los commits locales no quedaron en el historial del repo.

**2026-11-17 · Rechazar/Revisar · campo "qué hace".** Al revisar el `index.html` de Claude Code, se comprobó en un navegador que los formularios de registro y login no se ocultaban al iniciar sesión (el CSS `display: grid` anulaba el atributo `hidden`; el defecto también existía antes). Se agregó la regla `[hidden] { display: none !important; }`. Con ella, la prueba en navegador da `display: none` para los formularios.

**2026-11-17 · Revisar · (entrega).** La subida inicial quedó con el nombre `index.html.html`, así que Vercel seguía sirviendo la versión anterior. Se borró el `index.html` viejo y se renombró `index.html.html` a `index.html` (2 commits). Después se confirmó en el sitio en vivo: sección `#lecciones` con 3 tarjetas y el texto "Inicia sesión en «Tu cuenta» para guardar tu avance".



## 3. Validación (Paso 3)

Fecha: 2026-11-17 · Sitio en vivo: https://aat-mockup-fernando.vercel.app · Usuario A: jf777silva+prueba1@gmail.com

### Caso A: el avance sobrevive al cerrar sesión

**Input exacto:**
1. Iniciar sesión como A en el sitio en vivo.
2. En la sección Lecciones, pulsar "Marcar como completada" en la lección 2.
3. Pulsar "Cerrar sesión" y volver a iniciar sesión como A.

**Output real:** captura de pantalla tras volver a entrar. Texto en pantalla: "Llevas 1 de 3 lecciones". La lección 2 muestra "✓ Completada" y el botón "Desmarcar". Las lecciones 1 y 3 muestran el botón "Marcar como completada".

**Veredicto: Aceptar.** El avance se guardó en Supabase y no solo en la pantalla, porque sobrevivió al cierre de sesión. Coincide con el campo "cómo se sabrá que funciona" de la especificación.

### Caso B: marcar las 3 lecciones

**Input exacto:** con A en sesión, pulsar "Marcar como completada" en las lecciones 1 y 3.

**Output real:** captura de pantalla. Texto: "Llevas 3 de 3 lecciones". Las 3 tarjetas muestran "✓ Completada" y el botón "Desmarcar".

**Veredicto: Aceptar.** El conteo se actualiza al marcar.

### Caso C: otro usuario no ve el avance de A

**Input exacto:** en una ventana de incógnito, iniciar sesión con un usuario B distinto de A y mirar la sección Lecciones.

**Output real:** Fernando confirmó el 2026-11-17 que, al entrar con otro usuario existente y con su contraseña correcta, la página mostró "Llevas 0 de 3 lecciones" y ninguna lección marcada, aunque A tenía 3 completadas. (Resultado reportado por Fernando, sin captura.)

**Veredicto: Aceptar.** Con RLS cada usuario ve solo su propio avance.

## 4. Uso de IA

- **Claude Code** propuso la especificación y escribió el `index.html` y el SQL.
- **Claude (asistente de chat)** revisó el código, corrió el SQL en el Supabase de Fernando desde su Chrome, hizo los commits de corrección en GitHub y ayudó a redactar esta bitácora, siempre con su autorización.
- Las decisiones de aceptar, revisar y rechazar las tomó Fernando.
- Contraseñas e inicios de sesión los escribió Fernando; la IA no las ve ni las usa.
