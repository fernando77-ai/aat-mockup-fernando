-- 01_progreso.sql
-- Assignment 2: progreso de lecciones por usuario (FinCopa).
-- Corre en el editor SQL de Supabase ANTES de subir el index.html a main.

create table if not exists public.progreso (
  usuario_id    uuid        not null default auth.uid() references auth.users(id) on delete cascade,
  leccion       smallint    not null check (leccion between 1 and 3),
  completada_en timestamptz not null default now(),
  primary key (usuario_id, leccion)
);

alter table public.progreso enable row level security;

-- Politicas por dueno. Usan (select auth.uid()) para que Postgres calcule el
-- valor una vez por consulta y no una vez por fila (decision 5 del README).
drop policy if exists "progreso_select_dueno" on public.progreso;
drop policy if exists "progreso_insert_dueno" on public.progreso;
drop policy if exists "progreso_delete_dueno" on public.progreso;

create policy "progreso_select_dueno" on public.progreso
  for select to authenticated using ((select auth.uid()) = usuario_id);
create policy "progreso_insert_dueno" on public.progreso
  for insert to authenticated with check ((select auth.uid()) = usuario_id);
create policy "progreso_delete_dueno" on public.progreso
  for delete to authenticated using ((select auth.uid()) = usuario_id);

grant select, insert, delete on public.progreso to authenticated;
