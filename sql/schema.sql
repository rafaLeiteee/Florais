-- ============================================================
-- Entre Flores · ERP — schema inicial (Supabase / Postgres)
-- Rode isto no SQL Editor do painel do Supabase.
-- ============================================================

create table if not exists public.insumos (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  nome        text not null,
  unidade     text not null check (unidade in ('haste','metro','unidade','kg','folha','maço')),
  preco       numeric(10,2) not null check (preco >= 0),
  fornecedor  text,
  origem      text default 'manual' check (origem in ('manual','qr')),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- Cada usuário só enxerga e mexe nos próprios insumos
alter table public.insumos enable row level security;

create policy "Usuário vê os próprios insumos"
  on public.insumos for select
  using (auth.uid() = user_id);

create policy "Usuário insere os próprios insumos"
  on public.insumos for insert
  with check (auth.uid() = user_id);

create policy "Usuário edita os próprios insumos"
  on public.insumos for update
  using (auth.uid() = user_id);

create policy "Usuário apaga os próprios insumos"
  on public.insumos for delete
  using (auth.uid() = user_id);

-- Mantém updated_at em dia
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger insumos_set_updated_at
  before update on public.insumos
  for each row execute function public.set_updated_at();
