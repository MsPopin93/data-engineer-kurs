--1. Za sezonu 2024/25 prikazite igrače i uk. broj golova koje su postigli
--Prikazite samo igrače koji su postigli bar jedan gol
--DENSE_RANK() - rangirajte igrače prema uk. broj golova (desc)
--Igrači sa istim brojem golova treba a imaju isti rang


select
--m.season,
--me.team_id,
me.player_id,
count(me.event_id) as broj_golova,

dense_rank() OVER (PARTITION BY m.season ORDER BY count(me.event_id) DESC) as rnk

from matches m
inner JOIN match_events me on (m.match_id = me.match_id) and (me.team_id = m.home_team_id or me.team_id = m.away_team_id) and me.event_type in ('goal', 'penalty_goal')
where 1=1
and m.season = '2024/25'
Group by m.season, me.player_id
having broj_golova >= 1
order by broj_golova desc;


--2. Za sezonu 2024/25 prikazite 3 igrača sa najviše postignutih golova za svaki klub
--naziv kluba,
--ime i prezime igrača
--broj golova
--ROW_NUMBER() odredjuje redosled igrača unutar svakog kluba DESC

select
--m.season,
me.team_id,
t.team_name,
me.player_id,
p.first_name,
p.last_name,
count(me.event_id) as broj_golova,

row_number() OVER (PARTITION BY me.team_id ORDER BY count(me.event_id) DESC) as rn

from matches m
inner JOIN match_events me on (m.match_id = me.match_id) and (me.team_id = m.home_team_id or me.team_id = m.away_team_id) and me.event_type in ('goal', 'penalty_goal')
inner JOIN players p on p.player_id = me.player_id
inner JOIN teams t on t.team_id = me.team_id
where 1=1
--and me.team_id = 4
and m.season = '2024/25'
Group by 
me.team_id, 
t.team_name,
me.player_id,
p.first_name,
p.last_name
qualify rn <= 3
order by me.team_id, broj_golova desc;


--3. Za sezonu 2024/25 prikazite SVE utakmice svakog kluba
--Broj golova koje je klub postigao
--broj golova koje je postigao u svojoj prethodnoj utakmici (LAG - prethodni)
--Razlika - broj golova na tekućoj - broj golova na prethodnoj utakmici
--RESULT - sort po nazivu kluba i datumu utakmice

WITH SVE AS (
select
m.season,
m.kickoff_ts,
m.match_id,
m.home_team_id as team_id,
t.team_name,
m.home_goals as goals_for

from matches m
left join teams t on t.team_id = m.home_team_id
where 1=1
and m.season = '2024/25'

UNION ALL

select
m.season,
m.kickoff_ts,
m.match_id,
m.away_team_id as team_id,
t.team_name,
m.away_goals as goals_for

from matches m
left join teams t on t.team_id = m.away_team_id
where 1=1
and m.season = '2024/25'


)

SELECT 
SVE.*,
row_number() over (partition by sve.team_id order by sve.kickoff_ts) as rn,
lag(sve.goals_for) over (partition by sve.team_id order by sve.kickoff_ts) as goals_for_previous_game,
(sve.goals_for - coalesce(goals_for_previous_game,0)) as diff
FROM SVE

ORDER BY sve.team_name, SVE.kickoff_ts

