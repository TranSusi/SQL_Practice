--Inter SQL= Intermediate SQL( Cont) from Datacamp
#Datasets:
#Curriculumn:
--#Case When
--#Subquerries
--#Correlated/Nested Querries & Common tables
--#Window Function

#Learning targets:



-- Basic CASE statements

-- (1)
SELECT
	team_api_id,
	team_long_name
FROM teams_germany
WHERE team_long_name IN ( 'FC Schalke 04' , 'FC Bayern Munich');

-- (2)
SELECT 
	CASE WHEN hometeam_id = 10189 THEN 'FC Schalke 04'
        WHEN hometeam_id = 9823 THEN 'FC Bayern Munich'
         ELSE 'Other' END AS home_team,
	COUNT(id) AS total_matches
FROM matches_germany
GROUP BY home_team;

--  CASE statements comparing column values

-- (1)
SELECT date,
	CASE WHEN home_goal > away_goal THEN 'Home win!'
         WHEN home_goal < away_goal THEN 'Home loss :(' 
         ELSE 'Tie' END AS outcome
FROM matches_spain;

-- (2)
SELECT 
	m.date,
	t.team_long_name AS opponent, 
	CASE WHEN m.home_goal > away_goal THEN 'Home win!'
         WHEN m.home_goal < away_goal THEN 'Home loss :('
         ELSE 'Tie' END AS outcome
FROM matches_spain AS m
LEFT JOIN teams_spain AS t
ON m.awayteam_id = t.team_api_id;

-- (3)
SELECT 
	m.date,
	t.team_long_name AS opponent,
	CASE WHEN m.home_goal > m.away_goal THEN 'Barcelona win!'
         WHEN m.home_goal < m.away_goal THEN 'Barcelona loss :(' 
         ELSE 'Tie' END AS outcome 
FROM matches_spain AS m
LEFT JOIN teams_spain AS t 
ON m.awayteam_id = t.team_api_id
WHERE m.hometeam_id = 8634; 

--  CASE statements comparing two column values part 2
SELECT  
	m.date,
	t.team_long_name AS opponent,
	CASE WHEN m.home_goal < m.away_goal THEN 'Barcelona win!'
         WHEN m.home_goal > m.away_goal THEN 'Barcelona loss :(' 
         ELSE 'Tie' END AS outcome
FROM matches_spain AS m
LEFT JOIN teams_spain AS t 
ON m.hometeam_id = t.team_api_id
WHERE m.awayteam_id = 8634;

--  In CASE of rivalry

-- (1)
SELECT 
	date,
	CASE WHEN hometeam_id = 8634 THEN 'FC Barcelona' 
        ELSE 'Real Madrid CF' END AS home,
	CASE WHEN awayteam_id = 8634 THEN 'FC Barcelona' 
        ELSE 'Real Madrid CF' END AS away
FROM matches_spain
WHERE (awayteam_id = 8634 OR hometeam_id = 8634)
      AND (awayteam_id = 8633 OR hometeam_id = 8633);

-- (2)
SELECT 
	date,
	CASE WHEN hometeam_id = 8634 THEN 'FC Barcelona' 
         ELSE 'Real Madrid CF' END AS home,
	CASE WHEN awayteam_id = 8634 THEN 'FC Barcelona' 
         ELSE 'Real Madrid CF' END AS away,
	CASE WHEN home_goal > away_goal AND hometeam_id = 8634 THEN 'Barcelona win!'
         WHEN home_goal > away_goal AND hometeam_id = 8633 THEN 'Real Madrid win!'
         WHEN home_goal < away_goal AND awayteam_id = 8634 THEN 'Barcelona win!'
         WHEN home_goal < away_goal AND awayteam_id = 8633 THEN 'Real Madrid win!'
         ELSE 'Tie!' END AS outcome
FROM matches_spain
WHERE (awayteam_id = 8634 OR hometeam_id = 8634)
      AND (awayteam_id = 8633 OR hometeam_id = 8633);

--------------------------------------------------------------------------
--PART2: SUBQUERRIES
---  Filtering your CASE statement

-- (1)
SELECT
	team_long_name,
	team_api_id
FROM teams_italy
WHERE team_long_name = 'Bologna';

-- (2)
SELECT 
	season,
	date,
	CASE WHEN hometeam_id = 9857  AND home_goal > away_goal THEN 'Bologna Win'
		WHEN awayteam_id = 9857 AND away_goal > home_goal THEN 'Bologna Win' 
		END AS outcome
FROM matches_italy;

-- (3)
SELECT 
	season,
    date,
	home_goal,
	away_goal
FROM matches_italy
WHERE 
	CASE WHEN hometeam_id = 9857 AND home_goal > away_goal THEN 'Bologna Win'
	     WHEN awayteam_id = 9857 AND away_goal > home_goal THEN 'Bologna Win' 
		END IS NOT NULL;

--  COUNT using CASE WHEN

-- (1)
SELECT 
	c.name AS country,
	COUNT(CASE WHEN m.season = '2012/2013' 
        	THEN m.id ELSE NULL END) AS matches_2012_2013
FROM country AS c
LEFT JOIN match AS m
ON c.id = m.country_id
GROUP BY c.name;

-- (2)
SELECT 
	c.name AS country,
	COUNT(CASE WHEN m.season = '2012/2013' THEN m.id END) AS matches_2012_2013,
	COUNT(CASE WHEN m.season = '2013/2014' THEN m.id END) AS matches_2013_2014,
	COUNT(CASE WHEN m.season = '2014/2015' THEN m.id END) AS matches_2014_2015
FROM country AS c
LEFT JOIN match AS m
ON c.id = m.country_id
GROUP BY c.name;

--  COUNT and CASE WHEN with multiple conditions
SELECT 
	c.name AS country,
	SUM(CASE WHEN m.season = '2012/2013' AND m.home_goal > m.away_goal 
        THEN 1 ELSE 0 END) AS matches_2012_2013,
 	SUM(CASE WHEN m.season = '2013/2014' AND m.home_goal > m.away_goal
        THEN 1 ELSE 0 END) AS matches_2013_2014,
	SUM(CASE WHEN m.season = '2014/2015' AND m.home_goal > m.away_goal
        THEN 1 ELSE 0 END) AS matches_2014_2015
FROM country AS c
LEFT JOIN match AS m
ON c.id = m.country_id
GROUP BY c.name;

--  Calculating percent with CASE and AVG

SELECT 
    c.name AS country,
	    COUNT(CASE WHEN m.home_goal > m.away_goal THEN m.id 
        END) AS home_wins,
		COUNT(CASE WHEN m.home_goal < m.away_goal THEN m.id 
        END) AS away_wins,
		COUNT(CASE WHEN m.home_goal = m.away_goal THEN m.id 
        END) AS ties
FROM country AS c
LEFT JOIN matches AS m
ON c.id = m.country_id
GROUP BY country;

-- (2)
SELECT 
	c.name AS country,
	AVG(CASE WHEN m.season= '2013/2014' AND m.home_goal = m.away_goal THEN 1
			WHEN m.season='2013/2014' AND m.home_goal != m.away_goal THEN 0
			END) AS ties_2013_2014,
	AVG(CASE WHEN m.season='2014/2015' AND m.home_goal = m.away_goal THEN 1
			WHEN m.season='2014/2015' AND m.home_goal != m.away_goal THEN 0
			END) AS ties_2014_2015
FROM country AS c
LEFT JOIN matches AS m
ON c.id = m.country_id
GROUP BY country;

-- (3)
SELECT 
	c.name AS country,
	ROUND(AVG(CASE WHEN m.season='2013/2014' AND m.home_goal = m.away_goal THEN 1
			 WHEN m.season='2013/2014' AND m.home_goal != m.away_goal THEN 0
			 END),2) AS pct_ties_2013_2014,
	ROUND(AVG(CASE WHEN m.season='2014/2015' AND m.home_goal = m.away_goal THEN 1
			 WHEN m.season='2014/2015' AND m.home_goal != m.away_goal THEN 0
			 END),2) AS pct_ties_2014_2015
FROM country AS c
LEFT JOIN matches AS m
ON c.id = m.country_id
GROUP BY country;

--  Filtering using scalar subqueries

--  (1)
SELECT 
	3 * AVG(home_goal + away_goal)
FROM matches_2013_2014;

--  (2)
SELECT 
    date,
	home_goal,
	away_goal
FROM  matches_2013_2014
WHERE (home_goal + away_goal) > 
       (SELECT 3 * AVG(home_goal + away_goal)
        FROM matches_2013_2014); 

--  Filtering using a subquery with a list
SELECT 
	team_long_name,
	team_short_name
FROM team 
WHERE team_api_id NOT IN
     (SELECT DISTINCT hometeam_ID  FROM match);

--  Filtering with more complex subquery conditions
SELECT
	team_long_name,
	team_short_name
FROM team
WHERE team_api_id IN
	  (SELECT hometeam_id 
       FROM match
       WHERE home_goal >= 8);

--  Joining Subqueries in FROM

--  (1)
SELECT 
	country_id, 
    id 
FROM match
WHERE (home_goal + away_goal) >= 10;

--  (2)
SELECT
    c.name AS country_name,
    COUNT(sub.id) AS matches
FROM country AS c
INNER JOIN (SELECT country_id, id 
            FROM match
            WHERE (home_goal + away_goal) >= 10 ) AS sub
ON c.id = sub.country_id
GROUP BY country_name;

--  Building on Subqueries in FROM
SELECT
    country,
    date,
    home_goal,
    away_goal
FROM 
	(SELECT c.name AS country, 
     	    m.date, 
     		m.home_goal, 
     		m.away_goal,
           (	m.home_goal + m.away_goal) AS total_goals
    FROM match AS m
    LEFT JOIN country AS c
    ON m.country_id = c.id) AS subq
WHERE total_goals >= 10;

--  Add a subquery to the SELECT clause
SELECT 
	l.name AS league,
    ROUND(AVG(m.home_goal + m.away_goal), 2) AS avg_goals,
    (SELECT ROUND(AVG(home_goal + away_goal), 2) 
     FROM match
     WHERE season = '2013/2014') AS overall_avg
FROM league AS l
LEFT JOIN match AS m
ON l.country_id = m.country_id
WHERE m.season = '2013/2014'
GROUP BY l.name;

--  Subqueries in Select for Calculations
SELECT
	l.name AS league,
	ROUND(AVG(m.home_goal + m.away_goal),2) AS avg_goals,
	ROUND(AVG(m.home_goal + m.away_goal) - 
		(SELECT AVG(home_goal + away_goal)
		 FROM match 
         WHERE season = '2013/2014'),2) AS diff
FROM league AS l
LEFT JOIN match AS m
ON l.country_id = m.country_id
WHERE m.season = '2013/2014'
GROUP BY l.name;

--  ALL the Subqueries EVERYWHERE 
SELECT 
	m.stage,
    ROUND(AVG(m.home_goal + m.away_goal),2) AS avg_goals,
    ROUND((SELECT AVG(home_goal + away_goal) 
           FROM match 
           WHERE season = '2012/2013'),2) AS overall
FROM match AS m
WHERE m.season = '2012/2013'
GROUP BY m.stage;

--  Add a subquery in FROM
SELECT 
	s.stage,
	ROUND(s.avg_goals,2) AS avg_goals
FROM 
	(SELECT
		 stage,
         AVG(home_goal + away_goal) AS avg_goals
	 FROM match
	 WHERE season = '2012/2013'
	 GROUP BY stage) AS s
WHERE 
	s.avg_goals > (SELECT AVG(home_goal + away_goal) 
                    FROM match WHERE season = '2012/2013');

--  Add a subquery in SELECT
SELECT 
	s.stage,
    ROUND(s.avg_goals,2) AS avg_goal,
    (SELECT AVG(home_goal + away_goal) FROM match WHERE season = '2012/2013') AS overall_avg
FROM 
	(SELECT
		 stage,
         AVG(home_goal + away_goal) AS avg_goals
	 FROM match
	 WHERE season = '2012/2013'
	 GROUP BY stage) AS s
WHERE 
	s.avg_goals > (SELECT AVG(home_goal + away_goal) 
                    FROM match WHERE season = '2012/2013');

----------------------------------------------------------------------------

--PART 3: CORRELATED/NESTED querrie& Common Table Expression
-- Basic Correlated Subqueries
SELECT 
	main.country_id,
    main.date,
    main.home_goal, 
    main.away_goal
FROM match AS main
WHERE 
	(home_goal + away_goal) > 
        (SELECT AVG((sub.home_goal + sub.away_goal) * 3)
         FROM match AS sub
         -- Join the main query to the subquery in WHERE
         WHERE main.country_id = sub.country_id);

-- Correlated subquery with multiple conditions
SELECT 
	main.country_id,
    main.date,
    main.home_goal,
    main.away_goal
FROM match AS main
WHERE 
	(home_goal + away_goal) = 
        (SELECT MAX(sub.home_goal + sub.away_goal)
         FROM match AS sub
         WHERE main.country_id = sub.country_id
               AND main.season = sub.season);

-- Nested simple subqueries
SELECT 
	-- Select the season and max goals scored in a match
	season,
    MAX(home_goal + away_goal) AS max_goals,
    -- Select the overall max goals scored in a match
   (SELECT MAX(home_goal + away_goal) FROM match) AS overall_max_goals,
    -- Select the max number of goals scored in any match in July
   (SELECT MAX(home_goal + away_goal) 
        FROM match
        WHERE id IN (
              SELECT id FROM match WHERE EXTRACT(MONTH FROM date) = 07)) AS july_max_goals
FROM match
GROUP BY season;

-- Nest a subquery in FROM

-- (1)
SELECT
	country_id,
    season,
	id
FROM match
WHERE home_goal >= 5 OR away_goal >= 5;

-- (2)
SELECT
    country_id,
    season,
    COUNT(id) AS matches
FROM (  SELECT
    	country_id,
    	season,
    	id
	FROM match
	WHERE home_goal >= 5 OR away_goal >= 5) AS subquery
GROUP BY country_id, season;

-- (3)
--What's the average number of matches per season where a team scored 5 or more goals? 
--How does this differ by country?
SELECT
	c.name AS country,
	AVG(c.id) AS avg_seasonal_high_scores
FROM country AS c
-- Left join outer_s to country
LEFT JOIN (
  SELECT country_id, season,
         COUNT(id) AS matches
  FROM (
    SELECT country_id, season, id
	FROM match
	WHERE home_goal >= 5 OR away_goal >= 5) AS inner_s
  GROUP BY country_id, season) AS outer_s
ON c.id = outer_s.country_id
GROUP BY country;

-- Clean up with CTEs
--Require:show countries and the number of matches in each country with more than 10 total goals.
--Analysis: show countries=> select country_id
----------number of matches in each country: count(home_goal+away_goal) ( join country_id in table:match)
----------more than 10 total goals: WHERE home_goal+away_goal> 10
--> put this sub query to a CTE

--Step 1: Make CTE:WITH..AS( SELECT FROM WHERE home_goal+away_goal> 10)
--Step 2: Make main query: SELECT naem, COUNT(sub.id) INNER JOIN match and leauge.


WITH match_list AS (
    SELECT 
  		country_id, 
  		id 
    FROM match
    WHERE (home_goal + away_goal) >= 10)
SELECT
    l.name AS league,
    COUNT(match_list.id) AS matches
FROM league AS l
LEFT JOIN match_list ON l.id =  match_list.country_id
GROUP BY l.name;

-- Organizing with CTEs
WITH match_list AS 
    (   SELECT 
  		l.name AS league, 
     	m.date, 
  		m.home_goal, 
  		m.away_goal,
       (m.home_goal + m.away_goal) AS total_goals
    FROM match AS m
    LEFT JOIN league as l ON m.country_id = l.id)
SELECT league, date, home_goal, away_goal
FROM match_list
WHERE total_goals >= 10;

-- Nested subqueries
WITH match_list AS ( SELECT 
            		  country_id, 
            	      (home_goal + away_goal) AS goals
                      FROM match
                      WHERE id IN
                         ( SELECT id
                         FROM match
                         WHERE season = '2013/2014' AND EXTRACT(MONTH FROM date) = 08) 
                        )
--EXTRACT() function retrieves a field such as a year, month, and day from a date/time value.
--(EXTRACT..FROM...): extract something from something
SELECT
	l.name,
    AVG(match_list.goals)
FROM league AS l
LEFT JOIN match_list ON l.id = match_list.country_id
GROUP BY l.name;

-- Get team names with a subquery

-- (1)
----Require: How do you get both the home and away team names 
--into one final query result?
SELECT 
	m.id, 
    t.team_long_name AS hometeam
FROM match AS m
LEFT JOIN team as t
ON m.hometeam_id = t.team_api_id;

-- (2)
SELECT
	m.date,
    hometeam, 
    awayteam,
    m.home_goal,
    m.away_goal
FROM match AS m
LEFT JOIN 
( SELECT match.id, team.team_long_name AS hometeam
  FROM match
  LEFT JOIN team
  ON match.hometeam_id = team.team_api_id) AS home

ON home.id = m.id
LEFT JOIN 
( SELECT match.id, team.team_long_name AS awayteam
  FROM match
  LEFT JOIN team
  -- Get the away team ID in the subquery
  ON match.awayteam_id = team.team_api_id) AS away
ON away.id = m.id;

-- Get team names with correlated subqueries

-- (1)
SELECT
    m.date,
   (SELECT team_long_name
    FROM team AS t
    WHERE t.team_api_id = m.hometeam_id) AS hometeam
FROM match AS m;

-- (2)
SELECT
    m.date,
   
    (SELECT team_long_name
     FROM team AS t
     WHERE t.team_api_id = m.hometeam_id) AS hometeam,
   
    (SELECT team_long_name
     FROM team AS t
     WHERE t.team_api_id = m.awayteam_id) AS awayteam,
    
     m.home_goal,
    
     m.away_goal

FROM match AS m;

-- Get team names with CTEs 10

-- (1)
SELECT 
    m.id, 
    t.team_long_name AS hometeam
FROM match AS m
LEFT JOIN team AS t 
ON m.hometeam_id = t.team_api_id; 

-- (2)
WITH home AS (
	SELECT m.id, t.team_long_name AS hometeam
	FROM match AS m
	LEFT JOIN team AS t 
	ON m.hometeam_id = t.team_api_id)
SELECT *
FROM home;

-- (3)
----How do you get both the home and away team names into one final query result?
WITH home AS 
(  SELECT m.id, m.date, 
  		 t.team_long_name AS hometeam, m.home_goal
  FROM match AS m
  LEFT JOIN team AS t 
  ON m.hometeam_id = t.team_api_id),
away AS (
  SELECT m.id, m.date, 
  		 t.team_long_name AS awayteam, m.away_goal
  FROM match AS m
  LEFT JOIN team AS t 
  ON m.awayteam_id = t.team_api_id)
SELECT 
	home.date,
    home.hometeam,
    away.awayteam,
    home.home_goal,
    away.away_goal
FROM home
INNER JOIN away
ON home.id = away.id;
-------------------------------------------------------------------
--PART 3: WINDOWS FUNCTIONs
-- The match is OVER
----Require: average number of goals scored overall
SELECT 
	m.id, 
    c.name AS country, 
    m.season,
	m.home_goal,
	m.away_goal,
	AVG(m.home_goal + m.away_goal) OVER() AS overall_avg --include the aggregate average in each row
FROM match AS m
LEFT JOIN country AS c ON m.country_id = c.id;


-- What's OVER here?
SELECT 
	l.name AS league,
    AVG(m.home_goal + m.away_goal) AS avg_goals,
    RANK() OVER(ORDER BY AVG(m.home_goal + m.away_goal)) AS league_rank
FROM league AS l
LEFT JOIN match AS m 
ON l.id = m.country_id
WHERE m.season = '2011/2012'
GROUP BY l.name
ORDER BY league_rank;


-- Flip OVER your results
SELECT 
	l.name AS league,
    AVG(m.home_goal + m.away_goal) AS avg_goals,
    RANK() OVER(ORDER BY AVG(m.home_goal + m.away_goal) DESC) AS league_rank
FROM league AS l
LEFT JOIN match AS m 
ON l.id = m.country_id
WHERE m.season = '2011/2012'
GROUP BY l.name
ORDER BY league_rank;


-- PARTITION BY a column
SELECT
	date,
	season,
	home_goal,
	away_goal,
	CASE WHEN hometeam_id = 8673 THEN 'home' 
		 ELSE 'away' END AS warsaw_location,
    AVG(home_goal) OVER(PARTITION BY season) AS season_homeavg,
    AVG(away_goal) OVER(PARTITION BY season) AS season_awayavg
FROM match
WHERE 
	hometeam_id = 8673 
    OR awayteam_id = 8673
ORDER BY (home_goal + away_goal) DESC;


-- PARTITION BY multiple columns
SELECT 
	date,
	season,
	home_goal,
	away_goal,
	CASE WHEN hometeam_id = 8673 THEN 'home' 
         ELSE 'away' END AS warsaw_location,
    AVG(home_goal) OVER(PARTITION BY season, 
         	EXTRACT(month FROM date)) AS season_mo_home,
    AVG(away_goal) OVER(PARTITION BY season, 
            EXTRACT(month FROM date)) AS season_mo_away
FROM match
WHERE 
	hometeam_id = 8673 
    OR awayteam_id = 8673
ORDER BY (home_goal + away_goal) DESC;


-- Slide to the left
SELECT 
	date,
	home_goal,
	away_goal,
    SUM(home_goal) OVER(ORDER BY date 
         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total,
    AVG(home_goal) OVER(ORDER BY date 
         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_avg
FROM match
WHERE 
	hometeam_id = 9908 
	AND season = '2011/2012';


-- Slide to the right
SELECT 
	date,
    home_goal,
    away_goal,
    SUM(home_goal) OVER(ORDER BY date DESC
         ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS running_total,
    AVG(home_goal) OVER(ORDER BY date DESC
         ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS running_avg
FROM match
WHERE 
	awayteam_id = 9908 
    AND season = '2011/2012';


-- Setting up the home team CTE
--Require: matches in which team MU was defeated during the 2014/2015 English Premier League season.
--Step 1: matches where Manchester United played as the home team


SELECT 
	m.id, 
    t.team_long_name,
	CASE WHEN m.home_goal > m.away_goal THEN 'MU Win'
		 WHEN m.home_goal < m.away_goal THEN 'MU Loss'
         ELSE 'Tie' END AS outcome
FROM match AS m
LEFT JOIN team AS t 
ON m.hometeam_id = t.team_api_id
WHERE 
	m.season = '2014/2015'
	AND t.team_long_name = 'Manchester United';


-- Setting up the away team CTE
SELECT 
	m.id, 
    t.team_long_name,
	CASE WHEN m.home_goal > m.away_goal THEN 'MU Loss'
		 WHEN m.home_goal < m.away_goal THEN 'MU Win'
         ELSE 'Tie' END AS outcome
FROM match AS m
LEFT JOIN team AS t 
ON m.awayteam_id = t.team_api_id
WHERE 
	m.season = '2014/2015'
	AND t.team_long_name = 'Manchester United';


-- Putting the CTEs together
WITH home AS (
  SELECT m.id, t.team_long_name,
	  CASE WHEN m.home_goal > m.away_goal THEN 'MU Win'
		   WHEN m.home_goal < m.away_goal THEN 'MU Loss' 
  		   ELSE 'Tie' END AS outcome
  FROM match AS m
  LEFT JOIN team AS t ON m.hometeam_id = t.team_api_id),
away AS (
  SELECT m.id, t.team_long_name,
	  CASE WHEN m.home_goal > m.away_goal THEN 'MU Win'
		   WHEN m.home_goal < m.away_goal THEN 'MU Loss' 
  		   ELSE 'Tie' END AS outcome
  FROM match AS m
  LEFT JOIN team AS t ON m.awayteam_id = t.team_api_id)
SELECT DISTINCT
   m.date,
    home.team_long_name AS home_team,
    away.team_long_name AS away_team,
    m.home_goal,
    m.away_goal
FROM match AS m
LEFT JOIN home ON m.id = home.id
LEFT JOIN away ON m.id = away.id
WHERE m.season = '2014/2015'
      AND (home.team_long_name = 'Manchester United' 
           OR away.team_long_name = 'Manchester United');


-- Add a window function
WITH home AS (
  SELECT m.id, t.team_long_name,
	  CASE WHEN m.home_goal > m.away_goal THEN 'MU Win'
		   WHEN m.home_goal < m.away_goal THEN 'MU Loss' 
  		   ELSE 'Tie' END AS outcome
  FROM match AS m
  LEFT JOIN team AS t ON m.hometeam_id = t.team_api_id),
away AS (
  SELECT m.id, t.team_long_name,
	  CASE WHEN m.home_goal > m.away_goal THEN 'MU Loss'
		   WHEN m.home_goal < m.away_goal THEN 'MU Win' 
  		   ELSE 'Tie' END AS outcome
  FROM match AS m
  LEFT JOIN team AS t ON m.awayteam_id = t.team_api_id)
SELECT DISTINCT
    m.date,
    home.team_long_name AS home_team,
    away.team_long_name AS away_team,
    m.home_goal, m.away_goal,
    RANK() OVER(ORDER BY ABS(home_goal - away_goal) DESC) as match_rank
FROM match AS m
LEFT JOIN home ON m.id = home.id
LEFT JOIN AWAY ON m.id = away.id
WHERE m.season = '2014/2015'
	  AND ((home.team_long_name = 'Manchester United' AND home.outcome = 'MU Loss')
	  OR (away.team_long_name = 'Manchester United' AND away.outcome = 'MU Loss'));

