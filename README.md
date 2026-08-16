# Entre Flores · ERP

Sistema de gestão para floriculturas — começando pela Entre Flores (SJC).
MVP atual: login + cadastro de Insumos (leitura de QR Code de nota fiscal ou
manual). Site estático, sem build, pronto pra rodar em qualquer hospedagem
gratuita.

## Estrutura

```
entre-flores-erp/
├── index.html          → login / criação de conta
├── dashboard.html       → tela inicial pós-login, com os módulos
├── insumos.html          → módulo de Insumos (o único pronto por enquanto)
├── assets/
│   ├── css/style.css     → tokens de marca (cores, tipografia) + estilos
│   ├── js/
│   │   ├── config.js         → chaves do Supabase (preencher)
│   │   └── supabase-client.js → cliente + helpers de autenticação
│   └── img/logo.png      → logo Entre Flores (extraído do brandbook)
├── sql/schema.sql       → schema do banco (Supabase / Postgres)
└── README.md
```

## Stack

- **Frontend:** HTML/CSS/JS puro, sem framework nem build — só abrir e rodar.
- **Backend + banco + auth:** [Supabase](https://supabase.com) (tier gratuito).
- **Hospedagem:** qualquer uma que sirva arquivos estáticos —
  [Vercel](https://vercel.com) ou [Netlify](https://netlify.com), ambos com
  plano gratuito e deploy direto do GitHub.

## Setup (antes do primeiro deploy)

1. **Crie um projeto no Supabase** (gratuito, sem cartão): supabase.com → New Project.
2. **Rode o schema:** abra o SQL Editor do projeto e cole o conteúdo de
   `sql/schema.sql`. Isso cria a tabela `insumos` já com as regras de
   segurança (RLS) — cada usuário só vê os próprios dados.
3. **Pegue suas chaves:** em Project Settings → API, copie a *Project URL*
   e a *anon public key*.
4. **Preencha `assets/js/config.js`** com esses dois valores.
5. **Habilite login por e-mail/senha:** em Authentication → Providers, o
   Email já vem ativado por padrão — não precisa mexer em nada.

## Rodando localmente

Como é tudo estático, basta um servidor simples (não abra o `index.html`
direto como `file://`, porque o navegador bloqueia alguns recursos):

```bash
cd entre-flores-erp
python3 -m http.server 8080
# acesse http://localhost:8080
```

## Deploy

**Vercel (recomendado):**
1. Suba esta pasta pro GitHub.
2. Em vercel.com → New Project → importe o repositório.
3. Nenhuma configuração de build é necessária (é um site estático).
4. Deploy. Pronto — funciona em computador e celular.

## O que falta (próximos módulos)

- **Produtos:** montar buquês a partir dos insumos cadastrados, com
  precificação automática — tela já desenhada, falta implementar.
- **Financeiro:** taxas de maquininha, impostos.
- **Vendas:** integração com maquininha/gateway de pagamento.
- **Relatórios:** dashboard didático de margem e faturamento.
- **Leitura real da nota fiscal:** hoje o QR Code só identifica a chave de
  acesso da nota. Buscar os itens de fato exige uma function de backend
  que consulte a SEFAZ-SP ou um provedor como a Nuvem Fiscal — ainda não
  implementado.

## Sobre a identidade visual

As cores e a logo vêm do brandbook oficial da Entre Flores. A tipografia
de destaque do brandbook é uma serifada autoral (com ligaturas desenhadas
à mão) que não está disponível como fonte gratuita — usamos **Fraunces**
(Google Fonts) como substituta, por ser da mesma família estética
(serifa old-style, orgânica). Se um dia vocês tiverem os arquivos da fonte
original, é só trocar o `@font-face` em `assets/css/style.css`.
