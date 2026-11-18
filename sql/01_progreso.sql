-- 01_progreso.sql
-- Progreso de lecciones por usuario (campo "datos" de la especificación).
-- Una fila = una lección completada por un usuario. Desmarcar = borrar la fila.

create table if not exists public.progreso (
  usuario_id    uuid        not null default auth.uid() references auth.users (id) on delete cascade,
  leccion       smallint    not null check (leccion between 1 and 3),
  completada_en timestamptz not null default now(),
  primary key (usuario_id, leccion)
);

-- RLS obligatorio: cada usuario solo ve y modifica sus propias filas.
alter table public.progreso enable row level security;

drop policy if exists "progreso_select_dueno" on public.progreso;
create policy "progreso_select_dueno" on public.progreso
  for select to authenticated
  using (auth.uid() = usuario_id);

drop policy if exists "progreso_insert_dueno" on public.progreso;
create policy "progreso_insert_dueno" on public.progreso
  for insert to authenticated
  with check (auth.uid() = usuario_id);

drop policy if exists "progreso_delete_dueno" on public.progreso;
create policy "progreso_delete_dueno" on public.progreso
  for delete to authenticated
  using (auth.uid() = usuario_id);

-- Permisos de tabla para usuarios con sesión (RLS sigue filtrando por dueño).
grant select, insert, delete on public.progreso to authenticated;
