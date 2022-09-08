
--Dataset: nobel

--yr	    subject	    winner
--1960	Chemistry	Willard F. Libby
--1960	Literature	Saint-John Perse
--1960	Medicine	Sir Frank Macfarlane Burnet
--1960	Medicine	Peter Medawar
--1960	Physics	Donald A. Glaser
--1960	Peace	      Albert Lutuli

----1 Show winner's names beginning with C and ending in n

SELECT winner FROM nobel
WHERE winner LIKE 'C%' AND winner LIKE '%n'
----2.Number of Chemistry awards were given between 1950 and 1960

SELECT COUNT(subject) FROM nobel
WHERE subject = 'Chemistry'
AND yr BETWEEN 1950 and 1960
----3. the amount of years where no Medicine awards were given

SELECT COUNT(DISTINCT yr) FROM nobel
 WHERE yr NOT IN 
 (SELECT DISTINCT yr FROM nobel 
  WHERE subject = 'Medicine')
 ----4. Shows winner and subject that winner's name start iwth Sir
 ----- and strat from  year 1960
 
 SELECT subject, winner FROM nobel 
 WHERE winner LIKE 'Sir%' AND yr LIKE '196%'
 ----5.  show the year when neither a Physics or Chemistry award 




 SELECT yr FROM nobel
 WHERE yr NOT IN(SELECT yr 
                 FROM nobel
                 WHERE subject IN ('Chemistry','Physics'))
 ----6.shows the years when a Medicine award was given but no Peace or Literature award was
 

 SELECT DISTINCT yr
 FROM nobel
 WHERE subject='Medicine' 
   AND yr NOT IN(SELECT yr FROM nobel 
                  WHERE subject='Literature')
   AND yr NOT IN (SELECT yr FROM nobel
                   WHERE subject='Peace')
 ----7.Shows subjects and the number of subjects of nobels happened in 1960
  SELECT subject, COUNT(subject) 
  FROM nobel 
  WHERE yr ='1960' 
  GROUP BY subject

--PART 3: SUM and COUNT Quiz
----Dataset: bbc

#name        region      area    population  gdp
#Afghanistan South Asia  652225  26000000  
#Albania     Europe      28728   3200000     6656000000
#Algeria     Middle East 2400000 32900000    75012000000
#Andorra     Europe      468     64000 

--1.3. shows the sum of population of all countries in 'Europe'

SELECT SUM(population)
FROM bbc
WHERE region = 'Europe'

--2.3.shows the number of countries with population smaller than 150000

SELECT COUNT(name) FROM bbc
WHERE population < 150000

--5.3. Show region and sum of area, where area > 15000000

SELECT region, SUM(area) FROM bbc
GROUP BY region
WHERE area > 15000000

--6.3.shows the average population of 'Poland', 'Germany' and 'Denmark'

SELECT AVG(population) FROM bbc
WHERE name IN ('Poland', 'Germany', 'Denmark')

--7.3.shows the medium population density of each region
#medium population density: Mat do dan so trung binh

SELECT region, SUM(polulation)/ SUM(area) as density FROM bbc
GROUP by region
--8.3.shows the name and population density of the country with the largest population

# population density = pupulation/area
#medium population density = SUM(population) SUM(area)

SELECT name, population/area as density FROM bbc
WHERE population = (SELECT MAX(population) FROM bbc)

--Part 4: Nested SELECT Quiz
--Dataset
#name        region      area    population  gdp
#Afghanistan South Asia  652225  26000000  
#Albania     Europe      28728   3200000     6656000000
#Algeria     Middle East 2400000 32900000    75012000000
#Andorra     Europe      468     64000 
#Bangladesh  South Asia  143998  152600000   67144000000
#United Kingdom  Europe  242514  59600000    2022824000000


----Shows the name, region and population of the smallest country in each region


SELECT region, name, population FROM bbc 
WHERE population <= ALL (SELECT population FROM bbc y 
                        WHERE y.region=x.region AND population>0)

----shows the countries belonging to regions with all populations over 50000

SELECT name,region,population FROM bbc 
WHERE 50000 < ALL (SELECT population FROM bbc y 
                  WHERE x.region=y.region AND y.population>0)

----shows the countries with a less than a third of the population of the countries around it

SELECT name, region FROM bbc 
WHERE population < ALL (SELECT population/3 FROM bbc y 
                        WHERE y.region = x.region AND y.name != x.name)


----

SELECT name FROM bbc
 WHERE population >
       (SELECT population
          FROM bbc
         WHERE name='United Kingdom')
   AND region IN
       (SELECT region
          FROM bbc
         WHERE name = 'United Kingdom')

----show the countries with a greater GDP than any country in Africa 
----(some countries may have NULL gdp values).

SELECT name FROM bbc
WHERE gdp > (SELECT MAX(gdp) FROM bbc WHERE region = 'Africa')


----shows the countries with population smaller than Russia but bigger than Denmark


SELECT name FROM bbc
WHERE population < (SELECT population FROM bbc WHERE name='Russia')
AND population > (SELECT population FROM bbc WHERE name='Denmark')