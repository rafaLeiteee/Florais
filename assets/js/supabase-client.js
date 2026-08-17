// ============================================================
// Cliente Supabase compartilhado + helpers de autenticação
// Depende de: config.js (window.SUPABASE_CONFIG) e do SDK
// carregado via CDN em cada página:
//   <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
// ============================================================

const supabaseClient = window.supabase.createClient(
  window.SUPABASE_CONFIG.url,
  window.SUPABASE_CONFIG.anonKey
);

/**
 * Garante que existe uma sessão ativa. Se não houver, redireciona
 * para a tela de login. Use no topo de toda página protegida:
 *   const session = await requireAuth();
 */
async function requireAuth(){
  const { data: { session } } = await supabaseClient.auth.getSession();
  if(!session){
    window.location.href = 'index.html';
    return null;
  }
  return session;
}

async function logout(){
  await supabaseClient.auth.signOut();
  window.location.href = 'index.html';
}
