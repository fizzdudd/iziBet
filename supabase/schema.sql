-- iziBet: tablas y Row Level Security.
-- Pégalo en el SQL Editor de tu proyecto Supabase (SQL Editor -> New query -> Run).
-- Se puede correr más de una vez.

-- ─────────────────────────────────────────────────────────────
-- picks: los picks que sigue cada usuario (CRUD completo)
-- ─────────────────────────────────────────────────────────────
create table if not exists public.picks (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null default auth.uid()
                  references auth.users on delete cascade,
  partido_id    text not null,
  partido       text not null,
  liga          text not null,
  mercado       text not null,
  seleccion     text not null,
  prob          int  not null check (prob between 0 and 100),
  cuota         numeric(6,2) not null check (cuota >= 1.01),
  monto         numeric(12,0) check (monto > 0),
  nota          text check (char_length(nota) <= 200),
  estado        text not null default 'pendiente'
                  check (estado in ('pendiente', 'acierto', 'fallo')),
  fecha_partido timestamptz not null,
  created_at    timestamptz not null default now(),
  unique (user_id, partido_id, seleccion)
);

-- Sin RLS, cualquiera con la publishable key leería toda la tabla.
alter table public.picks enable row level security;

drop policy if exists "ver mis picks" on public.picks;
create policy "ver mis picks" on public.picks
  for select using (auth.uid() = user_id);

drop policy if exists "crear mis picks" on public.picks;
create policy "crear mis picks" on public.picks
  for insert with check (auth.uid() = user_id);

drop policy if exists "editar mis picks" on public.picks;
create policy "editar mis picks" on public.picks
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "borrar mis picks" on public.picks;
create policy "borrar mis picks" on public.picks
  for delete using (auth.uid() = user_id);

-- ─────────────────────────────────────────────────────────────
-- favoritos: ligas y equipos que sigue cada usuario
-- ─────────────────────────────────────────────────────────────
create table if not exists public.favoritos (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null default auth.uid()
               references auth.users on delete cascade,
  tipo       text not null check (tipo in ('liga', 'equipo')),
  clave      text not null,
  nombre     text not null,
  created_at timestamptz not null default now(),
  unique (user_id, tipo, clave)
);

alter table public.favoritos enable row level security;

drop policy if exists "ver mis favoritos" on public.favoritos;
create policy "ver mis favoritos" on public.favoritos
  for select using (auth.uid() = user_id);

drop policy if exists "agregar mis favoritos" on public.favoritos;
create policy "agregar mis favoritos" on public.favoritos
  for insert with check (auth.uid() = user_id);

drop policy if exists "borrar mis favoritos" on public.favoritos;
create policy "borrar mis favoritos" on public.favoritos
  for delete using (auth.uid() = user_id);
