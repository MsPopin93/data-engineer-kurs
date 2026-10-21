-------------------------OSNOVNI NIVO-------------------------

--1. Naziv svakog kluba i naziv stadiona na kojem igra domaće utakmice

SELECT 
t.team_name,
s.stadium_name
FROM teams t
LEFT JOIN stadiums s ON s.stadium_id=t.stadium_id;
--samo 1 tim nema svoj stadion --Harbor City FC

--2. Ime i prezime igrača i naziv kluba za koji je igrao u seozni 2024/25. Ukloni duplikate
--JOIN klubovi koji su igrali u sezoni 24/25
--igrači u tim klubovima


SELECT DISTINCT
ps.player_id,
p.first_name,
p.last_name,
ps.team_id,
t.team_name
--ps.match_id
 FROM player_match_stats ps
JOIN matches m ON m.match_id=ps.match_id AND m.season='2024/25'
JOIN teams t ON t.team_id=ps.team_id
JOIN players p ON p.player_id=ps.player_id

 ORDER BY ps.player_id DESC;


--3. Datum odigravanja utakmice, naziv stadiona i broj gledalaca za sve utakmice u sezoni 24/25

--3.1. datum odigravanja utakmice i naziv stadiona za sve utakmice u sezoni 24/25
SELECT
date(kickoff_ts) as DATUM_UTAKMICE,
s.stadium_name
FROM matches m
LEFT JOIN stadiums s ON s.stadium_id=m.stadium_id
WHERE m.season='2024/25'
ORDER BY m.kickoff_ts desc;

--3.2. datum odigravanja utakmice i naziv stadiona za sve utakmice u sezoni 24/25 i broj gledalaca za sve utakmice u sezoni 24/25
SELECT
--date(kickoff_ts) as DATUM_UTAKMICE,
s.stadium_name,
sum(m.attendance) as BROJ_GLEDALACA_ZA_SEZONU
FROM matches m
LEFT JOIN stadiums s ON s.stadium_id=m.stadium_id
WHERE m.season='2024/25'
GROUP BY s.stadium_name
ORDER BY s.stadium_name desc;

-------------------------SREDNJI NIVO-------------------------
--4.Prikažite sve utakmice za koje nije evidentiran broj gledalaca. Prikažite datum, domaći klub i gostujući klub.

SELECT
date(kickoff_ts) as DATUM_UTAKMICE,
t1.team_name as DOMACI_KLUB,
t2.team_name as GOSTUJUCI_KLUB
FROM matches m
JOIN teams t1 ON m.home_team_id = t1.team_id
JOIN teams t2 ON m.away_team_id = t2.team_id
WHERE m.attendance IS NULL
ORDER BY DATUM_UTAKMICE desc;

--5.Pronađite stadione na kojima nije odigrana ni jedna utakmica u sezoni 2024/25.
select 
s.stadium_name,
m.match_id
from stadiums s
left join matches m on s.stadium_id=m.stadium_id 
and m.season='2024/25' --ovo je da join-ujem samo sa skupom utakmica iz 24/25
where m.match_id is null;

--6.Za svaki klub izračunajte ukupan broj žutih kartona koje su:
--dobili njegovi igrači u sezoni 2024/25. Rezultat sortirajte opadajuće prema broju kartona.

SELECT
t.team_name,
count(me.event_id) as broj_zutih_kartona
FROM teams t
LEFT JOIN matches m ON (m.home_team_id=t.team_id or m.away_team_id=t.team_id) and m.season='2024/25'
LEFT JOIN match_events me ON me.match_id=m.match_id and me.event_type ILIKE '%yellow%' AND me.team_id=t.team_id
--paziii na team_id da ne bi duplo obračunavao zute kartone
--WHERE t.team_name='Fairhaven Town'
GROUP BY t.team_name
ORDER BY broj_zutih_kartona DESC;

--SELECT DISTINCT me.event_type FROM match_events me

-------------------------NAPREDNI NIVO-------------------------

-- 7.Pronađite pet igrača sa najvećim brojem asistencija u sezoni 2024/25. 
--Prikažite ime igrača i broj asistencija.
--related_player_id - to je asistencija

SELECT 

e.related_player_id,
p2.first_name first_name_assistent,
p2.last_name last_name_assistent,
--e.event_type
count(e.event_id) as broj_asistencija

from match_events e
LEFT JOIN players p2 on p2.player_id=e.related_player_id
JOIN matches m ON m.match_id=e.match_id AND m.season='2024/25'

WHERE 1=1
and e.related_player_id is not null --moze se dati go i bez asistencije
and e.event_type IN ('goal', 'penalty_goal')

GROUP BY
related_player_id,
first_name_assistent,
last_name_assistent

ORDER BY broj_asistencija DESC
LIMIT 5;

-- 8. Pronađite tri igrača sa najvećim ukupnim brojem odigranih minuta u 
--ne zaboraviiiii sezoni 2024/25. 
-- Prikažite ime igrača (players), klub (teams) i ukupan broj minuta.
--Transferi usred sezone????


SELECT 
ps.player_id,
p1.first_name first_name,
p1.last_name last_name,
ps.team_id,
t.team_name,
sum(ps.minutes_played) as total_minutes_played

 FROM player_match_stats ps
JOIN matches m ON m.match_id=ps.match_id AND m.season='2024/25'
LEFT JOIN players p1 on p1.player_id=ps.player_id
LEFT JOIN teams t on t.team_id=ps.team_id

 GROUP BY
ps.player_id,
ps.team_id,
first_name,
last_name,
team_name

ORDER BY total_minutes_played DESC
LIMIT 3;

--9.3.Za svaku sezonu prikažite:
-- broj isključenja po klubovima.

--Računajte događaje:
-- red_card
-- second_yellow. 

--Uključite samo klubove koji su imali najmanje jedno isključenje.

SELECT 
me.team_id,
t.team_name,
m.season,
count(me.event_id) as `broj_isključenja`
FROM match_events me
INNER JOIN matches m ON m.match_id=me.match_id
INNER JOIN teams t ON t.team_id=me.team_id
WHERE me.event_type IN ('red_card', 'second_yellow') 

GROUP BY 
me.team_id,
t.team_name,
m.season

HAVING `broj_isključenja` > 0

ORDER BY m.season,`broj_isključenja` DESC;


