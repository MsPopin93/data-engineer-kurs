-- 2.1.1 kapacited stadiona minus poseta
--TOP 5 UTAKMICA sa najvise praznih mesta
-- prvim trima je zajedičko stadium - National stadium sa kapacitetom od 80.000 mesta koje treba popuniti



select 
match_id,
stadium_name,
stadium_city,
stadium_capacity,
attendance,
stadium_capacity - attendance as empty_seats
FROM bootcamp.northern_star.matches_flat
order by empty_seats desc
LIMIT 5;

-- 2.1.2 Različite sudije je sudilo domaće utakmice kluba Riverton Athletic? 

select count(*) from (
select
distinct (referee_name)
FROM bootcamp.northern_star.matches_flat
WHERE home_team='Riverton Athletic'
);


-- 2.1.3 Broj utakmica u kojima je gost vodio na poluvremenu, a domaćin na kraju pobedio?

select count(*) from (
select 
match_id,
home_team,
away_team,

home_goals_ht,
away_goals_ht,
home_goals,
away_goals

FROM bootcamp.northern_star.matches_flat
where 1=1
and away_goals_ht > home_goals_ht --gost je vodio na poluvremenu
and away_goals <= home_goals --gost nije vodio na poluvremenu

Order by away_team
);

-- 2.1.4 U kojoj utakmici je palo najviše golova u drugom poluvremenu?
--najviše golova u drugom poluvremenu je palo u utakmici 2083 Northport United vs Newbury Forest
--Igrao -  Northport United vs Newbury Forest
--Rezultat na poluvremenu - 1 gol
--Rezultat na kraju - Total Goals 9 (odnosno 6:3)

select 
match_id,
home_team,
away_team,

home_goals_ht,
away_goals_ht,
home_goals,
away_goals,

home_goals_ht + away_goals_ht as goals_ht,
home_goals + away_goals as total_goals,
total_goals - goals_ht as goals_second_time,
status,
match_report
FROM bootcamp.northern_star.matches_flat
where 1=1
Order by goals_second_time desc
limit 1;

-- 2.1.5 Utakmice sezone 23/24 po snegu
select count(*) from (
SELECT 
match_id,
weather
FROM bootcamp.northern_star.matches_flat
where 1=1
AND season='2023/24'
AND (weather='fog' or weather='snow')
);

-- 2.1.6 Sve utakmice derbija izmedju Northport United i Northport City, sortirane po datumu, ko je pobedio?

SELECT 
match_id,
kickoff_ts,
home_team,
away_team,
home_goals,
away_goals,


CASE
WHEN home_goals > away_goals THEN home_team
WHEN away_goals > home_goals THEN away_team
ELSE 'nereseno'
END AS winner

FROM bootcamp.northern_star.matches_flat
WHERE 1=1
AND (home_team ='Northport United' AND away_team ='Northport City')
OR (home_team ='Northport City' AND away_team ='Northport United')

ORDER BY kickoff_ts DESC;

-- 2.1.7 Prve 3 utakmice sezone 24/25 po vremenu početka... Koja je druga, a koja treća?
--Pošto 2. i 3. imaju isti dan i satnicu, gledala bih match_id, ili redni broj utakmice kao unique identifikator
SELECT 
match_id,
kickoff_ts,
original_kickoff_ts,
home_team,
away_team,
home_goals,
away_goals

FROM bootcamp.northern_star.matches_flat
WHERE 1=1
AND season='2024/25'
ORDER BY match_id, kickoff_ts ASC
limit 3;


-- 2.1.8 Sve utakmice u kojima je prvi gol dao Sean O'Neill?

select count(*) from (
SELECT 
*

FROM bootcamp.northern_star.matches_flat
WHERE 1=1
AND first_goal_scorer = "Sean O'Neill"
)
