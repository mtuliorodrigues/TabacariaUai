# Código organizado

Esta pasta concentra os módulos de domínio da próxima evolução do ERP. A entrada Next/Vinext permanece em app/, como exigido pelo framework, e o build estático publicado permanece isolado em dist/.

- entrypoint/: inicialização e composição da aplicação.
- pages/: telas e fluxos do ERP.
- components/: componentes compartilhados.
- services/auth/: sessão, login e autorização por cargo.
- services/supabase/: cliente e operações Supabase.
- data/: repositórios e acesso a dados.
- types/: contratos e modelos de domínio.
- utils/: funções utilitárias.
