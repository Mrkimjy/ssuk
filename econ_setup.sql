-- econ ranking setup (safe to run again)
create table if not exists public.econ_ranks (
  pid text primary key,
  secret text not null,
  nick text not null,
  chr text not null default 'tiger',
  fit text not null default 'base',
  level int not null default 1,
  total_xp int not null default 0,
  week_key text not null default '',
  week_xp int not null default 0,
  mapae int not null default 0,
  stamps int not null default 0,
  updated_at timestamptz not null default now()
);

alter table public.econ_ranks enable row level security;

create or replace view public.econ_ranks_public as
  select pid, nick, chr, fit, level, total_xp, week_key, week_xp, mapae, stamps, updated_at
  from public.econ_ranks;

grant select on public.econ_ranks_public to anon;

create or replace function public.econ_put(
  p_pid text, p_secret text, p_nick text, p_chr text, p_fit text,
  p_level int, p_total_xp int, p_week_key text, p_week_xp int, p_mapae int, p_stamps int)
returns void
language sql
security definer
set search_path = public
as 'insert into econ_ranks(pid,secret,nick,chr,fit,level,total_xp,week_key,week_xp,mapae,stamps,updated_at)
    values (p_pid,p_secret,left(p_nick,10),p_chr,p_fit,p_level,p_total_xp,p_week_key,p_week_xp,p_mapae,p_stamps,now())
    on conflict (pid) do update set nick=excluded.nick, chr=excluded.chr, fit=excluded.fit, level=excluded.level,
      total_xp=excluded.total_xp, week_key=excluded.week_key, week_xp=excluded.week_xp,
      mapae=excluded.mapae, stamps=excluded.stamps, updated_at=now()
    where econ_ranks.secret = p_secret';

create or replace function public.econ_del(p_pid text, p_secret text)
returns void
language sql
security definer
set search_path = public
as 'delete from econ_ranks where pid = p_pid and secret = p_secret';

grant execute on function public.econ_put(text,text,text,text,text,int,int,text,int,int,int) to anon;
grant execute on function public.econ_del(text,text) to anon;
