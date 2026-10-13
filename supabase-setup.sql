-- Run this whole file once in Supabase: SQL Editor > New query > paste > Run.
-- Safe to run again: it only adds what is missing and refreshes the rules.

------------------------------------------------------------------
-- 1. People and roles
------------------------------------------------------------------
create table if not exists profiles(
  id uuid primary key references auth.users on delete cascade,
  full_name text,
  student_id text,
  role text not null default 'student' check (role in ('student','faculty')));
alter table profiles enable row level security;

create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into profiles(id, full_name, student_id)
  values (new.id, new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'student_id');
  return new;
end $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

create or replace function public.is_faculty() returns boolean
language sql security definer set search_path = public stable as $$
  select exists(select 1 from profiles where id = auth.uid() and role = 'faculty') $$;

drop policy if exists "read own profile" on profiles;
create policy "read own profile" on profiles for select to authenticated
  using (id = auth.uid() or is_faculty());

------------------------------------------------------------------
-- 2. Activities (the portfolio)
------------------------------------------------------------------
create table if not exists portfolio_records(
  id text not null,
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  title text not null check (char_length(title) between 3 and 80),
  category text not null check (category in ('Workshop','Competition','Hackathon','Volunteering','Club')),
  status text not null check (status in ('Planned','In Progress','Completed')),
  date date not null,
  hours numeric not null check (hours between 0 and 500),
  org text default '', outcome text default '', notes text default '',
  proof text default '' check (proof = '' or proof ~ '^https?://'),
  skills text default '',
  verify text not null default 'Unverified' check (verify in ('Unverified','Pending','Verified')),
  primary key (id, user_id));
alter table portfolio_records add column if not exists file_path text;  -- certificate in Storage
alter table portfolio_records add column if not exists file_name text;
alter table portfolio_records enable row level security;

drop policy if exists "read own or faculty" on portfolio_records;
drop policy if exists "insert own" on portfolio_records;
drop policy if exists "update own" on portfolio_records;
drop policy if exists "delete own" on portfolio_records;
drop policy if exists "faculty verifies" on portfolio_records;
create policy "read own or faculty" on portfolio_records for select to authenticated
  using (user_id = auth.uid() or is_faculty());
create policy "insert own" on portfolio_records for insert to authenticated
  with check (user_id = auth.uid() and verify in ('Unverified','Pending'));
create policy "update own" on portfolio_records for update to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid() and verify in ('Unverified','Pending'));
create policy "delete own" on portfolio_records for delete to authenticated
  using (user_id = auth.uid());
create policy "faculty verifies" on portfolio_records for update to authenticated
  using (is_faculty()) with check (is_faculty());

------------------------------------------------------------------
-- 3. Events and registration
------------------------------------------------------------------
create table if not exists events(
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(title) between 3 and 80),
  category text not null check (category in ('Workshop','Competition','Hackathon','Volunteering','Club')),
  date date not null,
  hours numeric not null check (hours > 0 and hours <= 24),
  org text default '',
  created_by uuid default auth.uid() references auth.users on delete set null);
alter table events enable row level security;
drop policy if exists "everyone reads events" on events;
drop policy if exists "faculty adds events" on events;
drop policy if exists "faculty deletes events" on events;
create policy "everyone reads events" on events for select to authenticated using (true);
create policy "faculty adds events" on events for insert to authenticated with check (is_faculty());
create policy "faculty deletes events" on events for delete to authenticated using (is_faculty());

create table if not exists event_regs(
  event_id uuid references events on delete cascade,
  user_id uuid default auth.uid() references auth.users on delete cascade,
  created_at timestamptz default now(),
  primary key (event_id, user_id));
alter table event_regs enable row level security;
drop policy if exists "read own regs or faculty" on event_regs;
drop policy if exists "register self" on event_regs;
drop policy if exists "unregister self" on event_regs;
create policy "read own regs or faculty" on event_regs for select to authenticated
  using (user_id = auth.uid() or is_faculty());
create policy "register self" on event_regs for insert to authenticated with check (user_id = auth.uid());
create policy "unregister self" on event_regs for delete to authenticated using (user_id = auth.uid());

------------------------------------------------------------------
-- 4. Certificate files (private bucket, 400 KB, PDF/PNG/JPG)
------------------------------------------------------------------
insert into storage.buckets(id, name, public, file_size_limit, allowed_mime_types)
values ('certificates', 'certificates', false, 409600, array['application/pdf','image/png','image/jpeg'])
on conflict (id) do nothing;

drop policy if exists "upload own certificates" on storage.objects;
drop policy if exists "read own or faculty certificates" on storage.objects;
drop policy if exists "delete own certificates" on storage.objects;
create policy "upload own certificates" on storage.objects for insert to authenticated
  with check (bucket_id = 'certificates' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "read own or faculty certificates" on storage.objects for select to authenticated
  using (bucket_id = 'certificates' and ((storage.foldername(name))[1] = auth.uid()::text or public.is_faculty()));
create policy "delete own certificates" on storage.objects for delete to authenticated
  using (bucket_id = 'certificates' and (storage.foldername(name))[1] = auth.uid()::text);

------------------------------------------------------------------
-- 5. Make someone faculty (run after they have registered):
-- update profiles set role = 'faculty' where student_id = 'FAC001';
------------------------------------------------------------------

-- Each student ID can only be registered once.
create unique index if not exists profiles_student_id_key
  on profiles (lower(student_id)) where student_id is not null and student_id <> '';

------------------------------------------------------------------
-- 6. Updates added later (safe to run on a new or an existing project)
------------------------------------------------------------------
-- Separate "role" field and up to 5 optional links per activity.
alter table portfolio_records add column if not exists role text default '';
alter table portfolio_records add column if not exists links jsonb not null default '[]'::jsonb;
alter table portfolio_records drop constraint if exists portfolio_links_array;
alter table portfolio_records add constraint portfolio_links_array
  check (jsonb_typeof(links) = 'array' and jsonb_array_length(links) <= 5);

-- Hackathon category (replaces the old category rules on tables that already exist).
alter table portfolio_records drop constraint if exists portfolio_records_category_check;
alter table portfolio_records add constraint portfolio_records_category_check
  check (category in ('Workshop','Competition','Hackathon','Volunteering','Club'));
alter table events drop constraint if exists events_category_check;
alter table events add constraint events_category_check
  check (category in ('Workshop','Competition','Hackathon','Volunteering','Club'));
