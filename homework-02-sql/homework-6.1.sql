--1. Kreiranje dimenzije igrača

--nisam mogla da koristim matches_flat jer ne sadrzi imena igrača
create or replace table dim_player as
 select distinct
 p.player_id,
 p.first_name,
 p.last_name,
 p.position,
 p.nationality
 from bootcamp.northern_star.players p;

 select count(*) from dim_player;
 --novokreirana tabela ima 681 red

  --select count(*) from bootcamp.northern_star.players p;

  --2. Kreirajte dim_date
  create or replace table dim_date as 
  select 
  cast(date_format(d, 'yyyyMMdd') as int) as date_key,
  d as full_date,
  date_format(d, 'EEEE') as weekday_name,
  dayofweek(d) in (1,7) as is_weekend,
  case 
  when month(d) >= 7 then concat(year(d), '/', substring(cast(year(d) + 1 as string), 3, 2))
  else concat(year(d)-1, '/', substring(cast(year(d) as string),3,2))
  end as season
  from (select explode(sequence(date'2023-07-01', date'2025-06-30', interval 1 day)) as d);

   select * from dim_date;

   --fact_player_match = player_match_stats i matches

create or replace table fact_player_match as
     select 
     m.match_id,
     cast(date_format(m.kickoff_ts, 'yyyyMMdd') as int) as date_key,
     ps.player_id,
     ps.team_id,
     ps.minutes_played,
     ps.shots,
     ps.passes,
     ps.rating

       from bootcamp.northern_star.matches m
       left join bootcamp.northern_star.player_match_stats ps on m.match_id = ps.match_id and (m.home_team_id = ps.team_id or m.away_team_id = ps.team_id)

where 1=1
and m.status = 'played';

select count(*) from fact_player_match;
--Ova tabela ima 30.400 redova i predstavlja jednu utakmicu razlistanu sa 40 redova za svakog igrača

--3. Prosečna ocena igrača po poziciji
select fpm.* from fact_player_match fpm;

select
fpm.player_id,
dp.position,
round(avg(fpm.rating),2) as prosecna_ocena_po_poziciji
from dim_date dd
left join fact_player_match fpm on fpm.date_key = dd.date_key
left join dim_player dp on dp.player_id = fpm.player_id
where 1=1
and dd.season = '2024/25'
group by
fpm.player_id,
dp.position;
--šta raditi kod igrača kod kojih je prosecna ocena NaN?

--4. Dodavanje broja golova u činjeničnu tabelu?

--golovi koje je svaki igrač postigao na odredjenoj utakmici - match_events


alter table fact_player_match add columns (
    broj_golova int
);

--update i set nije dozvolio databricks, zato je morao merge

MERGE INTO fact_player_match fpm
USING (
select

fpm.match_id,
fpm.player_id,
fpm.team_id,
count(me.event_id) as broj_golova
 from fact_player_match fpm
left join bootcamp.northern_star.match_events me 
on fpm.match_id = me.match_id 
and fpm.team_id = me.team_id 
and fpm.player_id = me.player_id 
and me.event_type in ('goal', 'penalty_goal')
where 1=1
--and fpm.match_id = 1001
Group by
fpm.match_id,
fpm.player_id,
fpm.team_id

) src
ON 1=1
and fpm.match_id = src.match_id 
and fpm.team_id = src.team_id 
and fpm.player_id = src.player_id
WHEN MATCHED THEN UPDATE SET broj_golova = src.broj_golova;

--select * from fact_player_match where match_id = 1001
