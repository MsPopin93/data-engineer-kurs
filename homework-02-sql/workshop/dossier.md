# Досије клуба: Newbury Forest (Сезона 2024/25)

## 1. Сезона у бројевима

42 бода из 38 утакмица - није катастрофа, али са 18 пораза се јасно види да је Newbury Forest целу сезону провео гледајући иза леђа за опстанак.

- **Одигране утакмице:** 38
- **Победе:** 11
- **Нерешене:** 9
- **Порази:** 18
- **Дати голови:** 47
- **Примљени голови:** 68
- **Освојени бодови:** 42

```sql
WITH club AS (
    SELECT team_id FROM teams WHERE team_name = 'Newbury Forest'
),
sezona AS (
    SELECT
        club.team_id,
        m.match_id,
        CASE WHEN m.home_team_id = club.team_id THEN m.home_goals ELSE m.away_goals END AS goals_for,
        CASE WHEN m.home_team_id = club.team_id THEN m.away_goals ELSE m.home_goals END AS goals_against
    FROM matches m
    INNER JOIN club ON m.home_team_id = club.team_id OR m.away_team_id = club.team_id
    WHERE m.season = '2024/25'
)
SELECT
    COUNT(*) AS played,
    SUM(CASE WHEN goals_for > goals_against THEN 1 ELSE 0 END) AS wins,
    SUM(CASE WHEN goals_for = goals_against THEN 1 ELSE 0 END) AS draws,
    SUM(CASE WHEN goals_for < goals_against THEN 1 ELSE 0 END) AS losses,
    SUM(goals_for) AS goals_for,
    SUM(goals_against) AS goals_against,
    SUM(CASE WHEN goals_for > goals_against THEN 3 WHEN goals_for = goals_against THEN 1 ELSE 0 END) AS points
FROM sezona;
```

## 2. Код куће и у гостима

Овде ме је бројка изненадила - 25 бодова у гостима наспрам само 17 код куће. Обично очекујеш обрнуто, али код овог клуба терен очигледно није био предност.

- **Код куће (19 утакмица):** 4 победе, 5 нерешених, 10 пораза (Гол разлика 22:32, Бодови 17)
- **У гостима (19 утакмица):** 7 победа, 4 нерешене, 8 пораза (Гол разлика 25:36, Бодови 25)

```sql
WITH club AS (
    SELECT team_id FROM teams WHERE team_name = 'Newbury Forest'
),
sezona AS (
    SELECT
        club.team_id,
        m.match_id,
        CASE WHEN m.home_team_id = club.team_id THEN m.home_goals ELSE m.away_goals END AS goals_for,
        CASE WHEN m.home_team_id = club.team_id THEN m.away_goals ELSE m.home_goals END AS goals_against,
        CASE WHEN m.home_team_id = club.team_id THEN 'domaci' ELSE 'gostujuce' END AS utakmice
    FROM matches m
    INNER JOIN club ON m.home_team_id = club.team_id OR m.away_team_id = club.team_id
    WHERE m.season = '2024/25'
)
SELECT
    utakmice,
    COUNT(*) AS played,
    SUM(CASE WHEN goals_for > goals_against THEN 1 ELSE 0 END) AS wins,
    SUM(CASE WHEN goals_for = goals_against THEN 1 ELSE 0 END) AS draws,
    SUM(CASE WHEN goals_for < goals_against THEN 1 ELSE 0 END) AS losses,
    SUM(goals_for) AS goals_for,
    SUM(goals_against) AS goals_against,
    SUM(CASE WHEN goals_for > goals_against THEN 3 WHEN goals_for = goals_against THEN 1 ELSE 0 END) AS points
FROM sezona
GROUP BY utakmice;
```

## 3. Стрелци

Занимљиво је што се у топ 5 нашла два Carter-а (Harry и Reece, нису у сродству - проверила сам да нису исти играч). Аутоголови нису урачунати у број голова играча (стандардна фудбалска конвенција), али пенал голови јесу.

- **Harry Carter:** 6 голова
- **Théo Laurent:** 5 голова
- **Reece Carter:** 4 гола
- **Најбољи асистент:** Reece Carter (6 асистенција)

```sql
-- Топ стрелци (аутогол се не рачуна, пенал гол се рачуна)
WITH club AS (
    SELECT team_id FROM teams WHERE team_name = 'Newbury Forest'
),
golovi AS (
    SELECT me.player_id, COUNT(*) AS broj_golova
    FROM matches m
    INNER JOIN club ON m.home_team_id = club.team_id OR m.away_team_id = club.team_id
    INNER JOIN match_events me ON me.match_id = m.match_id
    WHERE m.season = '2024/25'
      AND me.team_id = club.team_id
      AND me.event_type IN ('goal', 'penalty_goal')
    GROUP BY me.player_id
)
SELECT p.first_name, p.last_name, g.broj_golova
FROM golovi g
JOIN players p ON p.player_id = g.player_id
ORDER BY g.broj_golova DESC
LIMIT 3;

-- Најбољи асистент (related_player_id на голу/пенал голу = асистенција)
WITH club AS (
    SELECT team_id FROM teams WHERE team_name = 'Newbury Forest'
),
asist AS (
    SELECT me.related_player_id AS player_id, COUNT(*) AS broj_asistencija
    FROM matches m
    INNER JOIN club ON m.home_team_id = club.team_id OR m.away_team_id = club.team_id
    INNER JOIN match_events me ON me.match_id = m.match_id
    WHERE m.season = '2024/25'
      AND me.team_id = club.team_id
      AND me.event_type IN ('goal', 'penalty_goal')
      AND me.related_player_id IS NOT NULL
    GROUP BY me.related_player_id
)
SELECT p.first_name, p.last_name, a.broj_asistencija
FROM asist a
JOIN players p ON p.player_id = a.player_id
ORDER BY a.broj_asistencija DESC
LIMIT 1;
```

## 4. Дисциплина

1.79 наспрам 1.74 - практично исто као просек лиге, није тим који се нарочито истиче у било ком смислу. 2 искључења у целој сезони (црвени картоони + други жути) није ништа драматично.

- **Картони клуба по утакмици:** 1.79
- **Просек лиге:** 1.74 картона по тиму по утакмици
- **Искључења у сезони:** 2 (црвени картони + други жути картон)

```sql
-- Просек лиге: картони по (утакмица, тим) за цео лигашки календар
WITH utakmice AS (
    SELECT m.match_id, m.home_team_id AS team_id,
        SUM(CASE WHEN me.team_id = m.home_team_id
                  AND me.event_type IN ('yellow_card','second_yellow','red_card')
             THEN 1 ELSE 0 END) AS broj_kartica
    FROM matches m
    LEFT JOIN match_events me ON me.match_id = m.match_id
    WHERE m.season = '2024/25'
    GROUP BY m.match_id, m.home_team_id
    UNION ALL
    SELECT m.match_id, m.away_team_id AS team_id,
        SUM(CASE WHEN me.team_id = m.away_team_id
                  AND me.event_type IN ('yellow_card','second_yellow','red_card')
             THEN 1 ELSE 0 END) AS broj_kartica
    FROM matches m
    LEFT JOIN match_events me ON me.match_id = m.match_id
    WHERE m.season = '2024/25'
    GROUP BY m.match_id, m.away_team_id
)
SELECT AVG(broj_kartica) AS prosek_lige FROM utakmice;

-- Картони клуба по утакмици + искључења (црвени картон или други жути)
WITH club AS (
    SELECT team_id FROM teams WHERE team_name = 'Newbury Forest'
),
kartoni_kluba AS (
    SELECT m.match_id,
        SUM(CASE WHEN me.event_type IN ('yellow_card','second_yellow','red_card')
             THEN 1 ELSE 0 END) AS broj_kartica,
        SUM(CASE WHEN me.event_type = 'red_card' THEN 1 ELSE 0 END) AS crveni,
        SUM(CASE WHEN me.event_type = 'second_yellow' THEN 1 ELSE 0 END) AS drugi_zuti
    FROM matches m
    INNER JOIN club ON m.home_team_id = club.team_id OR m.away_team_id = club.team_id
    LEFT JOIN match_events me ON me.match_id = m.match_id AND me.team_id = club.team_id
    WHERE m.season = '2024/25'
    GROUP BY m.match_id
)
SELECT
    AVG(broj_kartica) AS prosek_kluba,
    SUM(crveni) + SUM(drugi_zuti) AS iskljucenja
FROM kartoni_kluba;
```

## 5. Тренери

Испало ме је да сам очекивала смену тренера након 18 пораза, али Gary Neville је водио тим баш све 38 утакмица - управа му је очигледно дала пуно поверење.

- **Gary Neville (јун 2024 – ...):** 38 утакмица, 1.11 бод по мечу

```sql
WITH club AS (
    SELECT team_id FROM teams WHERE team_name = 'Newbury Forest'
),
sezona AS (
    SELECT m.match_id, m.kickoff_ts,
        CASE WHEN m.home_team_id = club.team_id THEN m.home_goals ELSE m.away_goals END AS goals_for,
        CASE WHEN m.home_team_id = club.team_id THEN m.away_goals ELSE m.home_goals END AS goals_against
    FROM matches m
    INNER JOIN club ON m.home_team_id = club.team_id OR m.away_team_id = club.team_id
    WHERE m.season = '2024/25'
),
bodovi AS (
    SELECT match_id, kickoff_ts,
        CASE WHEN goals_for > goals_against THEN 3
             WHEN goals_for = goals_against THEN 1
             ELSE 0 END AS poeni
    FROM sezona
)
SELECT
    ms.manager_name, ms.start_date, ms.end_date,
    COUNT(b.match_id) AS broj_utakmica,
    AVG(b.poeni) AS bodovi_po_mecu
FROM manager_spells ms
JOIN club ON ms.team_id = club.team_id
JOIN bodovi b
    ON b.kickoff_ts BETWEEN ms.start_date AND COALESCE(ms.end_date, '9999-12-31')
GROUP BY ms.manager_name, ms.start_date, ms.end_date
ORDER BY ms.start_date;
```

## 6. Највећа победа и најтежи пораз

- **Највећа победа:** Lakeside Rangers 1:3 Newbury Forest (убедљива победа у гостима)
- **Најтежи пораз:** Elmsworth Wanderers 6:2 Newbury Forest (тежак пораз у гостима)

```sql
WITH club AS (
    SELECT team_id FROM teams WHERE team_name = 'Newbury Forest'
),
utakmice AS (
    SELECT m.match_id,
        CASE WHEN m.home_team_id = club.team_id THEN m.home_goals ELSE m.away_goals END AS goals_for,
        CASE WHEN m.home_team_id = club.team_id THEN m.away_goals ELSE m.home_goals END AS goals_against,
        CASE WHEN m.home_team_id = club.team_id THEN m.away_team_id ELSE m.home_team_id END AS played_against,
        CASE WHEN m.home_team_id = club.team_id THEN 'domaci' ELSE 'gostujuce' END AS mesto
    FROM matches m
    INNER JOIN club ON m.home_team_id = club.team_id OR m.away_team_id = club.team_id
    WHERE m.season = '2024/25'
),
najveca_pobeda AS (
    SELECT * FROM utakmice ORDER BY (goals_for - goals_against) DESC LIMIT 1
),
najtezi_poraz AS (
    SELECT * FROM utakmice ORDER BY (goals_against - goals_for) DESC LIMIT 1
)
SELECT
    'najveca_pobeda' AS tip, np.goals_for, np.goals_against, t.team_name AS protivnik
FROM najveca_pobeda np
JOIN teams t ON t.team_id = np.played_against
UNION ALL
SELECT
    'najtezi_poraz' AS tip, tp.goals_for, tp.goals_against, t.team_name AS protivnik
FROM najtezi_poraz tp
JOIN teams t ON t.team_id = tp.played_against;
```

## 7. Публика

87% попуњености стадиона упркос 18 пораза делује као да навијачи нису много бринули о резултатима - стадион је и дале био прилично пун.

- **Просечна посета:** 13.923 гледалаца
- **Попуњеност стадиона:** 87% (капацитет 16.000)
- **Утакмице без податка:** 0

```sql
WITH club AS (
    SELECT team_id FROM teams WHERE team_name = 'Newbury Forest'
)
SELECT
    AVG(m.attendance) AS prosek_posete,
    AVG(CAST(m.attendance AS FLOAT) / s.capacity) * 100.0 AS popunjenost_pct,
    SUM(CASE WHEN m.attendance IS NULL THEN 1 ELSE 0 END) AS bez_podatka
FROM matches m
INNER JOIN club ON m.home_team_id = club.team_id
JOIN stadiums s ON s.stadium_id = m.stadium_id
WHERE m.season = '2024/25';
```
