-- ============================================================
-- Florais ERP — schema único (Supabase / Postgres)
-- Rode isto de uma vez só no SQL Editor do Supabase.
-- Já reflete o estado final: insumos com perda, produtos com
-- preço 100% dinâmico (sem snapshot) e frete por distância.
-- ============================================================

-- Função auxiliar: mantém updated_at em dia em qualquer tabela
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;


-- ============================================================
-- INSUMOS
-- ============================================================
create table if not exists public.insumos (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  nome text not null,
  unidade text not null,
  preco numeric(10,2) not null check (preco >= 0),
  fornecedor text,
  perda numeric(5,2) not null default 0 check (perda >= 0 and perda <= 100),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.insumos enable row level security;

create policy "Usuário vê os próprios insumos"
  on public.insumos for select using (auth.uid() = user_id);
create policy "Usuário insere os próprios insumos"
  on public.insumos for insert with check (auth.uid() = user_id);
create policy "Usuário edita os próprios insumos"
  on public.insumos for update using (auth.uid() = user_id);
create policy "Usuário apaga os próprios insumos"
  on public.insumos for delete using (auth.uid() = user_id);

create trigger insumos_set_updated_at
  before update on public.insumos
  for each row execute function public.set_updated_at();


-- ============================================================
-- CONFIGURAÇÃO FINANCEIRA (uma linha por usuário — não há tela
-- separada de "Financeiro", fica tudo dentro de Produtos)
-- ============================================================
create table if not exists public.config_financeiro (
  user_id uuid primary key references auth.users(id) on delete cascade,
  taxa_maquininha numeric(5,2) not null default 0 check (taxa_maquininha >= 0 and taxa_maquininha < 100),
  impostos numeric(5,2) not null default 0 check (impostos >= 0 and impostos < 100),
  updated_at timestamptz not null default now()
);

alter table public.config_financeiro enable row level security;

create policy "Usuário vê a própria config"
  on public.config_financeiro for select using (auth.uid() = user_id);
create policy "Usuário cria a própria config"
  on public.config_financeiro for insert with check (auth.uid() = user_id);
create policy "Usuário edita a própria config"
  on public.config_financeiro for update using (auth.uid() = user_id);

create trigger config_financeiro_set_updated_at
  before update on public.config_financeiro
  for each row execute function public.set_updated_at();


-- ============================================================
-- PRODUTOS (buquês/arranjos) — sem preço armazenado: é sempre
-- recalculado a partir dos insumos e da config atuais
-- ============================================================
create table if not exists public.produtos (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  nome text not null,
  margem_contribuicao numeric(5,2) not null default 0 check (margem_contribuicao >= 0 and margem_contribuicao < 100),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.produtos enable row level security;

create policy "Usuário vê os próprios produtos"
  on public.produtos for select using (auth.uid() = user_id);
create policy "Usuário insere os próprios produtos"
  on public.produtos for insert with check (auth.uid() = user_id);
create policy "Usuário edita os próprios produtos"
  on public.produtos for update using (auth.uid() = user_id);
create policy "Usuário apaga os próprios produtos"
  on public.produtos for delete using (auth.uid() = user_id);

create trigger produtos_set_updated_at
  before update on public.produtos
  for each row execute function public.set_updated_at();


-- ============================================================
-- ITENS DE PRODUTO — só insumo + quantidade; preço e perda vêm
-- sempre ao vivo da tabela insumos (sem snapshot congelado).
-- Se o insumo for excluído, o item some junto (cascade).
-- ============================================================
create table if not exists public.produto_itens (
  id uuid primary key default gen_random_uuid(),
  produto_id uuid not null references public.produtos(id) on delete cascade,
  insumo_id uuid not null references public.insumos(id) on delete cascade,
  quantidade numeric(10,2) not null check (quantidade > 0)
);

alter table public.produto_itens enable row level security;

create policy "Usuário vê itens dos próprios produtos"
  on public.produto_itens for select
  using (exists (select 1 from public.produtos p where p.id [p.id] = produto_id and p.user_id = auth.uid()));
create policy "Usuário insere itens nos próprios produtos"
  on public.produto_itens for insert
  with check (exists (select 1 from public.produtos p where p.id [p.id] = produto_id and p.user_id = auth.uid()));
create policy "Usuário apaga itens dos próprios produtos"
  on public.produto_itens for delete
  using (exists (select 1 from public.produtos p where p.id [p.id] = produto_id and p.user_id = auth.uid()));
