--3.1. za svaku sezonu prikazite:
-- uk broj utakmica
-- uk broj postignutih golova
-- prosecan broj golova po utakmici
SELECT
season,
count(match_id) as broj_utakmica,
sum(home_goals + away_goals) as total_goals,
avg(home_goals + away_goals) as avg_goals_per_match
from bootcamp.northern_star.matches_flat

GROUP by season
order by season asc;

--3.2. za svaku stadion prikazite:
-- najmanja poseta
-- najveća poseta
-- prosecna zabelezena poseta
-- broj utakmica za koje je poseta poznata
SELECT
stadium_name,
min(attendance) as min_att,
max(attendance) as max_att,
avg(attendance) as avg_att,
count(attendance) as broj_utakmica_za_koje_je_poseta_poznata
from bootcamp.northern_star.matches_flat

GROUP by stadium_name
order by stadium_name asc;

--3.3. Sudije:
-- najmanja 10 utakmica
-- najmanje 20 zutih kartona

-- ime sudije
-- broj utakmica
-- uk broj zutih kartona
SELECT
referee_name,
count(match_id) as total_match,
sum(home_yellow_cards+away_yellow_cards) as total_yellow_cards
from bootcamp.northern_star.matches_flat

GROUP by referee_name
HAVING total_match >= 10 and total_yellow_cards >= 20
order by total_yellow_cards asc;

--3.4. podelite Utakmice na uk broj golova po kategorijama:
-- bez golova (0)
-- Malo golova (1 i 2)
-- Mnogo golova (3 ili više)

-- Broj utakmica po kategoriji 
-- Najveći broj golova na utakmici u toj kategoriji


SELECT

--home_goals + away_goals as total_goals,
CASE
WHEN (home_goals + away_goals) = 0 THEN 'bez golova (0)' 
WHEN (home_goals + away_goals)  > 0 and (home_goals + away_goals) < 3  THEN 'Malo golova (1 i 2)' 
ELSE 'Mnogo golova (3 ili više)'
END AS Goal_Category,

count(match_id) as broj_utakmica,
max(home_goals + away_goals)  as max_number_of_goals

from bootcamp.northern_star.matches_flat
WHERE home_goals IS NOT NULL AND away_goals IS NOT NULL

GROUP BY 
CASE
WHEN (home_goals + away_goals) = 0 THEN 'bez golova (0)' 
WHEN (home_goals + away_goals)  > 0 and (home_goals + away_goals) < 3  THEN 'Malo golova (1 i 2)' 
ELSE 'Mnogo golova (3 ili više)'
END;


--3.5. Za svaki klub prikazi:_______________________________________________________________________________________________________
-- broj utakmica kao domaćin
-- Broj pobeda kod kuće
-- Broj poraza kod kuće

-- Samo klubovi koji su kod kuće odigrali najmanje 10 utakmica

SELECT
home_team,
count(match_id) as broj_utakmica,
--sum(home_goals + away_goals) as total_goals,

SUM(CASE WHEN (home_goals > away_goals) THEN 1 ELSE 0 END) broj_pobeda_kod_kuce,

SUM(CASE WHEN (home_goals < away_goals) THEN 1 ELSE 0 END) broj_poraza_kod_kuce


from bootcamp.northern_star.matches_flat
WHERE home_goals IS NOT NULL AND away_goals IS NOT NULL
group by home_team
HAVING broj_utakmica >= 10
ORDER BY broj_utakmica desc;


--3.6. Prikazati za sudiju:
--uk broj utakmica
--broj utakmica u kojima je pokazao bar 1 crveni karton
--% utakmica u odnosu na sve njegove utakmice (tj u kojima je sudio)
SELECT 
S.referee_name,
S.broj_utakmica,
S.broj_utakmica_crveni_karton,
(S.broj_utakmica_crveni_karton / S.broj_utakmica) * 100.0 as procenat
 FROM (

SELECT
referee_name,
count(match_id) as broj_utakmica,

sum(CASE WHEN (home_red_cards + away_red_cards) > 0 THEN 1 ELSE 0 END) broj_utakmica_crveni_karton


from bootcamp.northern_star.matches_flat
group by referee_name

ORDER BY broj_utakmica_crveni_karton DESC
) S ;

--3.7. Za svaku sezonu prikazati
--broj pobeda domaćina
--broj nerešenih utakmica
--broj pobeda gostiju
--% utakmica koje su nerešene


SELECT 
s.season,
s.broj_utakmica,
s.broj_pobeda_domacina,
s.broj_neresenih_utakmica,
s.broj_pobeda_gostiju,
(s.broj_neresenih_utakmica / s.broj_utakmica) * 100.0 as procenat_neresenih_utakmica

 FROM (
SELECT
season,
count(match_id) as broj_utakmica,
--sum(home_goals + away_goals) as total_goals,

SUM(CASE WHEN (home_goals > away_goals) THEN 1 ELSE 0 END) broj_pobeda_domacina,
SUM(CASE WHEN (home_goals = away_goals) THEN 1 ELSE 0 END) broj_neresenih_utakmica,
SUM(CASE WHEN (home_goals < away_goals) THEN 1 ELSE 0 END) broj_pobeda_gostiju


from bootcamp.northern_star.matches_flat
WHERE home_goals IS NOT NULL AND away_goals IS NOT NULL
group by season
--HAVING broj_utakmica >= 10
ORDER BY season desc
)s;

