--2.2.1. Sve utakmice čiji naslov sadrzi reč 'goal' bez obzira na mala i velika slova (ILIKE komanda)

SELECT 
match_id,
match_report

FROM bootcamp.northern_star.matches_flat
WHERE 1=1
AND match_report ILIKE '%goal%';

--2.2.2. Kolona refree_name - da sadrzi ime sudije ako postoji, a tekst 'Unknown' ako nedostaje podatak, top 20
--coalesce zato što vraća prvu vrednost koja nije null

SELECT 
match_id,
match_report,
home_team,
away_team,
referee_id,
coalesce(referee_name, 'Unknown') as referee_name

FROM bootcamp.northern_star.matches_flat
WHERE 1=1
LIMIT 20;

--2.2.3. Utakmice čiji je naslov duzi od 40 znakova. Naslov i broj znakova u njemu
--lenght za broj znakova
SELECT 
match_id,
match_report,
len(match_report) as broj_znakova_u_naslovu


FROM bootcamp.northern_star.matches_flat
WHERE 1=1
AND len(match_report) > 40
ORDER BY len(match_report);

--2.2.4. Utakmice u periodu 1-15 januar 2025

SELECT 
match_id,
match_report,
kickoff_ts

FROM bootcamp.northern_star.matches_flat
WHERE 1=1
AND kickoff_ts >= '2025-01-01' AND kickoff_ts < '2025-01-16'
ORDER BY kickoff_ts DESC;

--2.2.5. Utakmice odigrane petkom, prikazite datum i dan u nedelji za svaku od njih

SELECT COUNT(*) FROM (
SELECT 
kickoff_ts,
date(kickoff_ts) as match_date,
date_format(kickoff_ts, 'EEEE') as weekday_name
 FROM bootcamp.northern_star.matches_flat 
 WHERE 1=1
 )
 WHERE weekday_name = 'Friday';

 --2.2.6. Utakmice SEOZNE '2024/25' I GLEDAOCI IZMEDJU 20.000 I 35.000

SELECT COUNT(*) FROM (
SELECT
match_id,
match_report,
home_team,
away_team,
attendance

FROM bootcamp.northern_star.matches_flat
WHERE 1=1
AND season = '2024/25'
AND attendance BETWEEN 20000 AND 35000
);


 --2.2.7. Strelce prvog gola čije ime počinje na 'A' ili sadrzi crticu. Lista samo različitih imena

SELECT DISTINCT(first_goal_scorer)

FROM bootcamp.northern_star.matches_flat
WHERE 1=1
AND first_goal_scorer LIKE "A%"
OR first_goal_scorer LIKE "%-%";

 --2.2.8. Utakmice SEOZNE '2024/25' I počele izmedju 18 i 21h, uklj obe granice. Prikazite vrem početka i nazive timova


SELECT
kickoff_ts,
hour(kickoff_ts) as kickoff_hour,
match_id,
match_report,
home_team,
away_team

FROM bootcamp.northern_star.matches_flat
WHERE 1=1
AND season = '2024/25'
AND hour(kickoff_ts) >= 18 and hour(kickoff_ts) <= 21;

 --2.2.9. Utakmice u martu, aprilu ili maju 2025. godine
 --Naslov sadrzi win

SELECT COUNT(*) FROM (
SELECT
kickoff_ts,
date_format(kickoff_ts, 'MMMM') as month_name,
year(kickoff_ts) as year,
match_id,
match_report,
home_team,
away_team

FROM bootcamp.northern_star.matches_flat
WHERE 1=1
AND date_format(kickoff_ts, 'MMMM')  IN ('March', 'April', 'May')
AND year(kickoff_ts) = 2025
AND match_report ILIKE '%win%'
);





