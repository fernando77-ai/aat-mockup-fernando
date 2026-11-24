# FinCopa — tu CFO personal con IA

Aplicación web de FinCopa, proyecto del curso Applied Algorithmic Thinking. Explica en español simple qué hacen la Fed y Banxico y qué significa para el bolsillo de cada persona. Cada usuario tiene su cuenta y guarda su avance en 3 lecciones.

- App desplegada: https://aat-mockup-fernando.vercel.app
- Repositorio: https://github.com/fernando77-ai/aat-mockup-fernando
- Bitácora de prompts del Assignment 2: [PROMPT_LOG.md](PROMPT_LOG.md)

## Qué hace hoy

- **Registro e inicio de sesión** con correo y contraseña (Supabase Auth). El nombre se guarda en la tabla `perfiles`.
- **Lecciones con progreso por usuario.** Con sesión iniciada, el usuario marca y desmarca 3 lecciones y ve "Llevas X de 3 lecciones". El avance se guarda en la tabla `progreso` y cada usuario solo ve el suyo.

## Cómo está armada

- Un solo `index.html` (HTML, CSS y JavaScript sin framework ni paso de compilación).
- Supabase: Auth y las tablas `perfiles` y `progreso`, ambas con RLS (seguridad por fila) por dueño. El SQL de `progreso` está en `sql/01_progreso.sql`.
- Despliegue: GitHub (`main`) → Vercel, que vuelve a desplegar solo con cada push.
- Seguridad: el navegador usa solo la clave pública (anon) de Supabase, que es pública por diseño. Lo que protege los datos es RLS. La clave `service_role` nunca se usa en el código.

## Decisiones de diseño vs. sugerencias del IS

IS = sistema inteligente (Claude Code y el asistente de chat).

### 1. Especificación «Progreso de lecciones por usuario» — Acepté

- **Qué propuso el IS:** Claude Code propuso la función del Assignment 2: una sección "Lecciones" con 3 lecciones fijas, botones "Marcar como completada" / "Desmarcar", el texto "Llevas X de 3 lecciones", y una tabla nueva `public.progreso` (`usuario_id`, `leccion` entre 1 y 3, `completada_en`) con llave primaria (`usuario_id`, `leccion`) y 3 políticas RLS por dueño (select, insert, delete).
- **Qué decidí:** aceptarla tal cual.
- **Por qué:** el criterio de éxito (el usuario A ve "1 de 3" y el usuario B ve "0 de 3") solo se cumple si el avance se guarda por usuario en la base de datos y no en el navegador. La llave primaria impide registrar dos veces la misma lección, y RLS hace que la base rechace leer o escribir filas de otro usuario aunque alguien manipule el JavaScript. Además usa solo Auth, que ya existía, sin sumar una API externa.

### 2. Código de Claude Code que no ocultaba los formularios — Revisé

- **Qué propuso el IS:** Claude Code escribió el `index.html` de las lecciones, y el JavaScript ocultaba los formularios de registro e inicio de sesión con el atributo `hidden` cuando hay sesión.
- **Qué decidí:** revisar. Acepté el código pero agregué una línea de CSS: `[hidden] { display: none !important; }`.
- **Por qué:** antes de subirlo, el archivo se abrió en un navegador y los formularios seguían visibles después de iniciar sesión. El contenedor tiene `display: grid` en el CSS de la página, y eso anula el estilo por defecto del atributo `hidden`. Con la regla nueva, el estilo calculado de los formularios pasa a `display: none`. La IA de código no lo señaló, y el defecto ya estaba en la versión anterior del login. La revisión del archivo la hizo el asistente de chat a petición mía; yo aprobé el cambio.

### 3. Orden de entrega: primero el SQL, después el código — Acepté

- **Qué propuso el IS:** el asistente de chat sugirió correr el SQL de `progreso` en Supabase antes de subir el código a `main`.
- **Qué decidí:** aceptar. El SQL se corrió y se verificó con una consulta (tabla con RLS activado y 3 políticas) y solo después se subió el `index.html`.
- **Por qué:** Vercel despliega con cada push a `main`. Si el código se hubiera subido primero, el sitio en vivo habría llamado a una tabla que todavía no existía y cualquier usuario con sesión habría visto el error "No se pudo leer tu progreso".

### 4. Qué clave de Supabase va en el navegador (seguridad) — Acepté

- **Qué propuso el IS:** el asistente de chat indicó que en el `index.html` solo debe ir la clave pública (anon / publishable) de Supabase, y que los datos se protegen con RLS en cada tabla. La clave `service_role` no se usa en ninguna parte del código.
- **Qué decidí:** aceptar. En el repo solo aparece la clave anon, y las tablas `perfiles` y `progreso` tienen RLS activado.
- **Por qué:** el repositorio es público y cualquier visitante puede ver el código fuente de la página, así que todo lo que esté en `index.html` es público. La clave anon solo puede hacer lo que permiten las políticas RLS (cada usuario, solo sus filas). `service_role` se salta RLS: si estuviera en el código, cualquiera podría leer y borrar todas las tablas.

## Qué pasa si crece o alguien la usa de forma indebida

- **Datos de otros usuarios:** protegidos por RLS en la base de datos, no por el JavaScript de la página. Alguien que modifique el código en su navegador sigue sin poder leer ni escribir filas ajenas.
- **Crecimiento:** `progreso` tiene como máximo 3 filas por usuario y su llave primaria empieza por `usuario_id`, así que consultar el avance de un usuario no recorre toda la tabla. El proyecto de Supabase está en el plan gratuito; si crece, ese plan es el primer límite.
- **Cuentas falsas:** la confirmación de correo está desactivada para poder probar rápido, así que alguien podría registrar muchas cuentas con correos inventados. Hoy el freno son los límites por defecto de Supabase Auth. Antes de abrirla al público habría que activar la confirmación de correo.
- **Pendiente de mejorar:** las políticas de `progreso` usan `auth.uid()` directamente; las de `perfiles` usan `(select auth.uid())`, que Supabase recomienda para que el valor se calcule una vez por consulta y no una vez por fila. Con pocos datos no se nota, y es el cambio que haría primero si la tabla crece.

## Mensajes de commit genéricos y la decisión detrás

Los commits anteriores al 17 de noviembre de 2026 se dejan como están. Desde esa fecha los mensajes describen la decisión. Estos son los genéricos que importan:

- **Create prueba-webhook.txt** (`f9c4665`): archivo de prueba para el ejercicio de webhooks. Al hacer push, GitHub envió el evento a la URL de prueba y recibió respuesta 200. No es parte del producto.
- **Rename index.html.html to index.html** (`428b958`): el archivo con las lecciones se subió con doble extensión, así que Vercel seguía mostrando la versión anterior. Junto con `5b00dfa` (que borra el `index.html` viejo), corrige el nombre para que el despliegue refleje la versión final.
- **Add files via upload** y **Update index.html** (septiembre): primeras versiones del mockup del Assignment 1.
