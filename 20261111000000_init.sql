-- Controle de faltas: estrutura inicial
-- Semestres arquivados ficam só para leitura; nada é apagado automaticamente.

create table semesters (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id),
  name text not null,                       -- ex.: 2026.2
  starts_on date,
  ends_on date,
  status text not null default 'active' check (status in ('active', 'archived')),
  passed boolean,                           -- resultado ao concluir o semestre
  closed_at timestamptz,
  created_at timestamptz not null default now()
);

-- só um semestre ativo por usuário
create unique index one_active_semester on semesters (user_id) where status = 'active';

create table subjects (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id),
  semester_id uuid not null references semesters(id) on delete restrict,
  name text not null,
  weekday smallint not null check (weekday between 0 and 5),  -- 0 = segunda
  position smallint not null default 0,
  created_at timestamptz not null default now()
);
create index subjects_semester_idx on subjects (semester_id);

create table absences (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id),
  subject_id uuid not null references subjects(id) on delete restrict,
  date date not null,
  classes smallint not null check (classes in (2, 4)),        -- 4 = dia todo, 2 = meio dia
  half smallint not null default 0 check (half in (0, 1, 2)), -- 1 = antes, 2 = depois do intervalo
  created_at timestamptz not null default now()
);
create index absences_subject_idx on absences (subject_id);

-- segurança: cada pessoa só enxerga e altera o que é dela
alter table semesters enable row level security;
alter table subjects enable row level security;
alter table absences enable row level security;

create policy "semesters: dono" on semesters
  for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

-- leitura sempre liberada para o dono, inclusive semestres arquivados
create policy "subjects: ler" on subjects
  for select to authenticated
  using (user_id = (select auth.uid()));

-- escrita só enquanto o semestre estiver ativo
create policy "subjects: escrever" on subjects
  for all to authenticated
  using (
    user_id = (select auth.uid())
    and exists (select 1 from semesters s where s.id = semester_id and s.status = 'active')
  )
  with check (
    user_id = (select auth.uid())
    and exists (select 1 from semesters s where s.id = semester_id and s.status = 'active')
  );

create policy "absences: ler" on absences
  for select to authenticated
  using (user_id = (select auth.uid()));

create policy "absences: escrever" on absences
  for all to authenticated
  using (
    user_id = (select auth.uid())
    and exists (
      select 1 from subjects b join semesters s on s.id = b.semester_id
      where b.id = subject_id and s.status = 'active'
    )
  )
  with check (
    user_id = (select auth.uid())
    and exists (
      select 1 from subjects b join semesters s on s.id = b.semester_id
      where b.id = subject_id and s.status = 'active'
    )
  );
