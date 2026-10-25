
--4.1. Koliko redova ima spoj matches i player match stats za sezonu 2024/25? Objasnite.
select 
m.season ,
count(*)
from matches m
left join player_match_stats ps on m.match_id=ps.match_id 
where m.season = '2024/25'

group by m.season;

--matches ima 380 redova za seoznu 2024/25
--left join sa player match stats 15.200
--u player match stats se jedan match id javlja više puta i zato je svejedno da li je left ili inner join

--4.2. Koliko puta je igrač u istoj sezoni igrao za dva različita kluba?

--broj igrača unutar utakmice

select 
ps.player_id,
count(distinct ps.team_id) as broj_klubova
from matches m
left join player_match_stats ps on m.match_id=ps.match_id 
where m.season = '2024/25' 

group by
ps.player_id

having broj_klubova > 1;

------------------provera rezultata---------------------------
/*
select 
m.season ,
m.match_id,
ps.team_id,
ps.player_id
from matches m
left join player_match_stats ps on m.match_id=ps.match_id 
where m.season = '2024/25'
and ps.player_id = 171

group by
m.season ,
m.match_id,
ps.team_id,
ps.player_id;
*/

-- 3. Koliko utakmica ima više kartona od prosečne utakmice? Bez kartona računajte sa 0.

with cards_per_match as (

select 
m.match_id,
sum(case when e.event_type in ('yellow_card', 'second_yellow', 'red_card') then 1 else 0 end) as broj_kartona

from matches m
left join match_events e on m.match_id = e.match_id
where 1=1
group by m.match_id
)


select count(match_id) 
from cards_per_match
where broj_kartona > (select avg(broj_kartona) from cards_per_match);

--4. Koliko igrača je odigralo više od 10 utakmica u sezoni 2024/25?

select 
ps.player_id,
count(m.match_id) as broj_utakmica
from player_match_stats ps
inner join matches m on m.match_id = ps.match_id and m.season = '2024/25'
where 1=1
and minutes_played > 0
group by ps.player_id
having broj_utakmica > 10;

-- 5. Prikažite sve klubove koji su igrali u sezoni 2024/25, bilo kao domaćini ili kao gosti. Koristite UNION, a zatim izmenite upit
--tako da koristi UNION ALL. Objasnite razliku u broju redova koji dobijate.

SELECT
t.team_id,
t.team_name
from matches m 
left join teams t on m.home_team_id = t.team_id
where m.season = '2024/25'

UNION

SELECT
t.team_id,
t.team_name
from matches m 
left join teams t on m.away_team_id = t.team_id
where m.season = '2024/25';

--isti tim moze da se pojavi i kao home team i kao away team i s obzirom da UNION ALL zadrzava sve redove iz oba selekta, isti tim se moze pojaviti više puta u rezultatu
--union - uklanja duplikate i vraća jedinstvenu listu timova

---------------------UNION ALL izmena---------------------
SELECT
t.team_id,
t.team_name
from matches m 
left join teams t on m.home_team_id = t.team_id
where m.season = '2024/25'

UNION ALL

SELECT
t.team_id,
t.team_name
from matches m 
left join teams t on m.away_team_id = t.team_id
where m.season = '2024/25'
