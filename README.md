# Minhas faltas

Site de controle de faltas (Psicologia, Santa Marcelina), com tema gótico.
Banco de dados e login: Supabase. Hospedagem: Vercel.

## Estrutura

- `index.html`: o site inteiro (sem etapa de build).
- `supabase/migrations/`: histórico das mudanças no banco, em SQL. Toda mudança futura entra como um arquivo novo aqui.

## Como funciona o histórico

- Os dados (semestres, matérias, faltas) ficam no Supabase e só crescem. Publicar uma versão nova do site não mexe neles.
- "Concluir semestre" arquiva o semestre. Nada é apagado, e um semestre arquivado fica só para leitura.
- "Exportar backup" baixa um arquivo JSON com tudo. Vale guardar um por semestre.

## Publicar

1. Crie um repositório **privado** no GitHub e envie estes arquivos.
2. No Vercel: Add New → Project → importe o repositório. Framework Preset: **Other**. Deixe build e output em branco. Deploy.
3. A cada commit na branch principal o Vercel publica de novo. Pull requests ganham um link de prévia.

## Cuidados

- No Supabase, em Authentication, deixe desligado o cadastro de novos usuários. Só existe o login criado manualmente.
- A chave que está no `index.html` é a pública (anon). Ela pode ficar no código porque as regras de segurança (RLS) protegem os dados. **Nunca** coloque a chave `service_role` ou a senha do banco no repositório.
- Projetos do plano gratuito do Supabase são pausados após cerca de uma semana sem atividade. Usar o site toda semana evita isso.
