--1. Prosek datih golova u poslednjih 5 utakmica, uz izričit okvir prozora
--Koja je najveca vrednost?
--Računajte samo kada prozor zaista ima 5 utakmica

--Zelim da izdvojim timove koji su odigrali bar 5 utakmica (tj. da ispadne onaj jedan tim sa null utakmica)
WITH Timovi AS (
SELECT 
tm.team_id,
count(tm.match_id) as total_number_of_games_played
FROM team_matches tm

WHERE 1=1
GROUP by 
tm.team_id
HAVING total_number_of_games_played >= 5
)


SELECT 
tm.season,
tm.match_id,
tm.kickoff_ts,
tm.team_id,
tm.goals_for,

row_number() over (
    partition by tm.team_id order by tm.kickoff_ts, tm.match_id
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
) as games_played, -- koliko je ukupno utakmica odigrao

avg(goals_for) over (
    partition by tm.team_id order by tm.kickoff_ts, tm.match_id
    ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
) as avg_goals_for_last_5,

count(goals_for) over (
    partition by tm.team_id order by tm.kickoff_ts, tm.match_id
    ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
) as count_goals_for_last_5

FROM team_matches tm
WHERE 1=1
--and tm.team_id = 8
and tm.team_id in (select team_id from timovi)
QUALIFY count_goals_for_last_5 = 5  -- da ne gledamo one redove gde utakmica nije imala prethodnu

ORDER BY avg_goals_for_last_5 DESC
LIMIT 1;

--2. tEKUĆI ZBIR DATIH GOLOVA SVAKOG KLUBA U SEZONI 2024/25
--Ko je prvi stigao do 50 golova i kada?

--prvo izračunavam running goals
WITH running_goals AS (
SELECT
tm.season,
tm.match_id,
tm.kickoff_ts,
tm.team_id,
tm.goals_for,
sum(tm.goals_for) over (partition by tm.season, tm.team_id order by tm.kickoff_ts
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
) as running_goals
FROM team_matches tm
WHERE 1=1
and tm.season = '2024/25'
QUALIFY running_goals >= 50
--hoću da filtriram na samo one koji su prvi stigli do 50 poena
--AND tm.team_id = 1
)


SELECT
rg.match_id,
rg.kickoff_ts,
rg.team_id,
t.team_name,
rg.running_goals,

row_number() over ( order by rg.kickoff_ts) as rn

FROM running_goals rg
LEFT join teams t on t.team_id = rg.team_id
WHERE 1=1
Qualify rn = 1
ORDER BY rg.kickoff_ts;


--3. Za svaku domaću utakmicu izračunajte:
--promenu posećenosti u odnosu na prethodnu domaću utakmicu - istog kluba u istoj sezoni
--Najveći pad i zašto?

--previous_attendance is not null - isključujem sve one slučajeve gde nismo imali podatak o prethodnoj utakmici
--najveći izazov su slučajevi u attendance koji imaju null, ili čak 0 - verovatno greška u podacima!?

WITH posecenost as (
SELECT
m.season,
m.match_id,
m.kickoff_ts,
m.home_team_id,
m.attendance,
lag(m.attendance) over (partition by m.season,m.home_team_id order by m.kickoff_ts) as previous_attendance

FROM matches m
WHERE 1=1
and m.status = 'played'
QUALIFY previous_attendance is not null
--isključujem sve one slučajeve gde nismo imali podatak o prethodnoj utakmici

--and m.home_team_id = 1
--and m.season = '2024/25'
)

SELECT 
p.*,
round((100 * try_divide(p.attendance - p.previous_attendance, p.previous_attendance)),2) as pct
 FROM posecenost p
WHERE p.attendance IS NOT NULL
 AND p.previous_attendance > 0
 AND p.attendance > 0
ORDER BY round((100 * try_divide(p.attendance - p.previous_attendance, p.previous_attendance)),2) asc
LIMIT 1;

/* ovaj uslov je morao biti dodat:
 
  AND p.attendance > 0
  jer je izbaciovao utakmicu 1237 kod koje je previous attndance 0? a isključeni su slučajevi gde privious utakmica nije postojala

  AND p.previous_attendance > 0
  jer je izbacivao utakmicu 1220 kod koje je attendance 0, što cenim da je malo moguće u realnosti? Jer bi to bio pad od 100%

  ako isključim ove outliere dobijem utakmicu 2033 i pad od 45%
