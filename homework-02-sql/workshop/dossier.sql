--Изаберите један клуб и анализирајте његову сезону 2024/25. Сваки упит почните истим кораком, тако да
--за други клуб мењате само име:

--1. Сезона у бројевима: утакмице, победе, нерешене, порази, дати и примљени голови, бодови.
WITH club AS (
SELECT team_id FROM teams WHERE team_name = 'Newbury Forest'
),
sezona as (

SELECT 
club.team_id,

m.match_id, ---utakmice
CASE WHEN m.home_team_id = club.team_id THEN m.home_goals ELSE m.away_goals END AS goals_for, --dati golovi
CASE WHEN m.home_team_id = club.team_id THEN m.away_goals ELSE m.home_goals END AS goals_against --primljeni golovi


FROM matches m
INNER JOIN club on m.home_team_id = club.team_id  or  m.away_team_id = club.team_id 
WHERE 1=1
and m.season = '2024/25'

)

SELECT 
team_id,
count(match_id) as broj_utakmica,
sum(CASE WHEN goals_for > goals_against THEN 1 ELSE 0 END) AS broj_pobeda,
sum(CASE WHEN goals_for = goals_against THEN 1 ELSE 0 END) AS broj_neresenih_utakmica,
sum(CASE WHEN goals_for < goals_against THEN 1 ELSE 0 END) AS broj_poraza,
sum(goals_for) broj_datih_golova,
sum(goals_against) broj_primljenih_golova,

sum(
    CASE 
    WHEN goals_for > goals_against THEN 3 
    WHEN goals_for = goals_against THEN 1
    WHEN goals_for < goals_against THEN 0
    ELSE 0 
    END) AS broj_bodova

FROM sezona
GROUP BY team_id;
----------------------------------------------------------------------------------------------------------------------------------------------
--2. Код куће и у гостима: исти бројеви, одвојено за домаће и гостујуће утакмице.
WITH club AS (
SELECT team_id FROM teams WHERE team_name = 'Newbury Forest'
),
sezona as (

SELECT 
club.team_id,

m.match_id, ---utakmice
CASE WHEN m.home_team_id = club.team_id THEN m.home_goals ELSE m.away_goals END AS goals_for, --dati golovi
CASE WHEN m.home_team_id = club.team_id THEN m.away_goals ELSE m.home_goals END AS goals_against, --primljeni golovi

CASE WHEN m.home_team_id = club.team_id THEN 'domaci' ELSE 'gostujuce' END AS utakmice 
--tačka 2. dodato

FROM matches m
INNER JOIN club on m.home_team_id = club.team_id  or  m.away_team_id = club.team_id 
WHERE 1=1
and m.season = '2024/25'

)
SELECT 
team_id,
utakmice,
count(match_id) as broj_utakmica,
sum(CASE WHEN goals_for > goals_against THEN 1 ELSE 0 END) AS broj_pobeda,
sum(CASE WHEN goals_for = goals_against THEN 1 ELSE 0 END) AS broj_neresenih_utakmica,
sum(CASE WHEN goals_for < goals_against THEN 1 ELSE 0 END) AS broj_poraza,
sum(goals_for) broj_datih_golova,
sum(goals_against) broj_primljenih_golova,

sum(
    CASE 
    WHEN goals_for > goals_against THEN 3 
    WHEN goals_for = goals_against THEN 1
    WHEN goals_for < goals_against THEN 0
    ELSE 0 
    END) AS broj_bodova

FROM sezona
GROUP BY team_id, utakmice;
----------------------------------------------------------------------------------------------------------------------------------------------
--3. 3 najbolja stelca kluba
--najbolji asistent

WITH club AS (
SELECT team_id FROM teams WHERE team_name = 'Newbury Forest'
)
--a) najbolji strelci kluba
SELECT
me.player_id,
p.first_name,
p.last_name,
--me.related_player_id,
sum(case when me.event_type IN ('goal', 'penalty_goal') then 1 else 0 end) as broj_golova
from matches m
INNER JOIN club ON club.team_id = m.home_team_id or club.team_id = m.away_team_id
INNER JOIN match_events me ON  me.match_id = m.match_id and club.team_id = me.team_id
INNER JOIN players p ON  p.player_id = me.player_id
WHERE m.season = '2024/25'
GROUP BY
me.player_id,
p.first_name,
p.last_name
ORDER BY broj_golova desc
LIMIT 3;

--b) najbolji asistent
WITH club AS (
SELECT team_id FROM teams WHERE team_name = 'Newbury Forest'
)

SELECT
me.related_player_id,
p.first_name,
p.last_name,

count(me.event_id) as broj_asistencija
from matches m
INNER JOIN club ON club.team_id = m.home_team_id or club.team_id = m.away_team_id
INNER JOIN match_events me ON  me.match_id = m.match_id and me.event_type = 'goal' and club.team_id = me.team_id
INNER JOIN players p ON  p.player_id = me.related_player_id
WHERE m.season = '2024/25'
GROUP BY
me.related_player_id,
p.first_name,
p.last_name
ORDER BY broj_asistencija desc
LIMIT 1;
----------------------------------------------------------------------------------------------------------------------------------------------
--4. Disciplina: Kartoni kluba po utakmici u poredjenu sa prosekom lige po timu po utakmici
--broj kartona Newbury Foresta po utakmici,
--prosečan broj kartona po timu po utakmici u celoj ligi (svi timovi, sve utakmice sezone).
WITH club AS (
SELECT team_id FROM teams WHERE team_name = 'Newbury Forest'
),
utakmice as (
SELECT
m.match_id,
me.team_id,
sum(case when me.event_type IN ('yellow_card', 'second_yellow','red_card') then 1 else 0 end) as broj_kartica
from matches m
LEFT JOIN match_events me ON  me.match_id = m.match_id
WHERE m.season = '2024/25'
GROUP BY
m.match_id,
me.team_id
ORDER BY m.match_id, me.team_id, broj_kartica desc
),

kartoni_kluba as (
--a) broj_kartona mog tima
SELECT
m.match_id,
sum(case when me.event_type IN ('yellow_card', 'second_yellow','red_card') then 1 else 0 end) as broj_kartica
from matches m
INNER JOIN club ON club.team_id = m.home_team_id or club.team_id = m.away_team_id
LEFT JOIN match_events me ON  me.match_id = m.match_id and club.team_id = me.team_id
WHERE m.season = '2024/25'
GROUP BY
m.match_id
ORDER BY broj_kartica desc
),

prosek_lige as (
--prosecan broj kartona po timu po utakmici
SELECT AVG(BROJ_KARTICA) AS prosek_kartica_liga
FROM UTAKMICE
WHERE team_id is not null
)

SELECT
AVG(k.broj_kartica) as prosek_kartica_kluba,
p.prosek_kartica_liga
FROM kartoni_kluba k
CROSS JOIN prosek_lige p
Group by p.prosek_kartica_liga;

----------------------------------------------------------------------------------------------------------------------------------------------
--5. Treneri: Ko je vodio klub u sezoni 24/25  i sa koliko bodova po utakmice

WITH club AS (
SELECT team_id FROM teams WHERE team_name = 'Newbury Forest'
),

utakmice as (
SELECT
club.team_id,
m.match_id,
case when club.team_id = m.home_team_id then m.home_goals else m.away_goals end as goals_for,
case when club.team_id = m.home_team_id then m.away_goals else m.home_goals end as goals_against
from matches m
INNER JOIN club ON club.team_id = m.home_team_id or club.team_id = m.away_team_id

WHERE 1=1
and m.season = '2024/25'

)

SELECT
manager_name as trener_sezone,
avg(broj_poena) as prosek_poena,
count(match_id) as broj_utakmica

from (
SELECT
ms.manager_name,
m.match_id,
case 
when goals_for > goals_against then 3
when goals_for = goals_against then 1
when goals_for < goals_against then 0
else 0
end as broj_poena

from matches m
INNER JOIN club ON club.team_id = m.home_team_id or club.team_id = m.away_team_id
INNER JOIN manager_spells ms ON club.team_id = ms.team_id
INNER join utakmice ON m.match_id = utakmice.match_id and (utakmice.team_id = m.home_team_id or utakmice.team_id = m.away_team_id)


WHERE 1=1
and m.season = '2024/25'
and  m.kickoff_ts between ms.start_date and coalesce(ms.end_date, '9999-12-31')
)
group BY
manager_name;


----------------------------------------------------------------------------------------------------------------------------------------------
--6. Najveća pobeda i najtezi poraz
WITH club AS (
SELECT team_id FROM teams WHERE team_name = 'Newbury Forest'
),

utakmice as (
    SELECT
    m.match_id,
    club.team_id,
    CASE WHEN m.home_team_id=club.team_id  THEN m.home_goals ELSE m.away_goals END AS goals_for,
    CASE WHEN m.home_team_id=club.team_id  THEN m.away_goals ELSE m.home_goals END AS goals_against,
    CASE WHEN m.home_team_id=club.team_id  THEN m.away_team_id ELSE m.home_team_id END AS played_against

    FROM matches m
    INNER JOIN club ON m.home_team_id=club.team_id OR m.away_team_id=club.team_id
    WHERE season = '2024/25' AND club.team_id is not NULL

),

najveca_pobeda as (
SELECT 
match_id,
team_id,
played_against,
(goals_for - goals_against) as najveca_pobeda
FROM utakmice

ORDER BY najveca_pobeda DESC
LIMIT 1

),

najtezi_poraz as (
--najtezi_poraz
SELECT 
match_id,
team_id,
played_against,
(goals_against - goals_for) as najtezi_poraz
FROM utakmice

ORDER BY najtezi_poraz DESC
LIMIT 1
)

SELECT 
club.team_id,
t1.team_name,
najveca_pobeda.najveca_pobeda,
najveca_pobeda.played_against,
t2.team_name as protivnik_najveca_pobeda,
najtezi_poraz.najtezi_poraz,
najtezi_poraz.played_against,
t3.team_name as protivnik_najtezi_poraz

 from club
 LEFT join najveca_pobeda ON najveca_pobeda.team_id = club.team_id
 LEFT join najtezi_poraz ON najtezi_poraz.team_id = club.team_id

  LEFT join teams t1 ON t1.team_id = club.team_id
  LEFT join teams t2 ON t2.team_id = najveca_pobeda.played_against
  LEFT join teams t3 ON t3.team_id = najtezi_poraz.played_against ;

  ----------------------------------------------------------------------------------------------------------------------------------------------
--7. Prosečna poseta i popunjenost (odnos posete i kapaciteta) na domaćim utakmicama,
--Koliko utakmica nema podataka o poseti
WITH club AS (
SELECT team_id FROM teams WHERE team_name = 'Newbury Forest'
)

SELECT
--m.home_team_id,
avg(m.attendance) as prosecna_poseta_domacih_utakmica,
Round(avg(m.attendance/s.capacity) *100.0) as prosecna_popunjenost_domacih_utakmica,
SUM(case when m.attendance is null then 1 else 0 end) as broj_utakmica_bez_podataka_o_poseti
FROM matches m 

INNER JOIN club ON m.home_team_id = club.team_id
INNER JOIN stadiums s ON s.stadium_id = m.stadium_id

WHERE m.season = '2024/25'

--BONUS: najzanimljiviji nalaz kod ovog kluba u sezoni 24/25 je da je osvojo više bodova u gostima, nego kod kuće (isti broj odigranih utakmica), što je neuobičajeno jer bi logika bila da većina kluba koristi prednosti domaćeg terena.
