/*
This script will document the method I took for conducting preliminary data analysis on the Bixi dataset before apply machine learning models
python
*/

/*
First, I want to gain an understanding of what the bike usage for each year was:
*/

/* First, I want to gain an understanding of what the bike usage for each year was. To do this I need to understand the SQL file and the accompanying 
tables, determining what data is being held in these tables is the first step. 

The SHOW and DESC functions will help me to gain this understanding. It was vital that I didn't choose any trips that may have started in 2016
and then continued over into the next year.
*/

SHOW TABLES;

DESC trips;
DESC stations;

SELECT DISTINCT COUNT(*)
FROM trips;

SELECT COUNT(*)
FROM trips;

SELECT *
FROM trips
LIMIT 20;

SELECT * 
from stations
LIMIT 20;

/* 
The queries above helped me to gain an understanding of both the station and trips table, also provided me with a way to join the two tables together
in the future if need be. 

*/

SELECT COUNT(*) 
FROM trips 
WHERE YEAR(start_date) = 2016 AND YEAR(end_date)= 2016;

SELECT COUNT(*) 
FROM trips 
WHERE YEAR(start_date) = 2017 AND YEAR(end_date)= 2017;

/*
From the two querys above I was able to get data on the number of trips in both 2016 and 2017. From the results it's clear to see that there were
500,000 more trips conducted in 2017 then 2016. 
*/

/* 
I want to gain a futher understanding of whether there was a pattern of behaviour to trips made by users. To do this I will study the month-to-month
usage of the trips made for both years. 
*/

SELECT MONTH(start_date) AS "Month", 
	COUNT(*) AS Total_trips
FROM trips
WHERE YEAR(start_date) = 2016 AND YEAR(end_date) = 2016
GROUP BY MONTH(start_date);

SELECT MONTH(start_date) AS "Month", 
	COUNT(*) AS Total_trips
FROM trips
WHERE YEAR(start_date) = 2017 AND YEAR(end_date) = 2017
GROUP BY MONTH(start_date);

/* 
The results imply that there is a pattern to behaviour for users. 

The number of users jumped up quite dramatically from April to May, five time the amount. This could imply that this was when the weather changed and 
became nicer to ride in. Or it may coincide with school holidays that would mean there are more families out and about and able to ride in. Given that 
there is no data on the demographic of the users it is hard to make concrete conclusions.

Also the bike share is only available from April to November which would imply that the service is not offered in the coldest winter months.

Furthermore, as expected 2017 experienced a higher number of trips than 2017 during the summer months than 2016. This could have been due to better 
weather in 2017 or the availability of more bikes provided by Bixi.
*/

/* 
I want to explore the data for the average number trips a day for each year-month combination in the dataset.

The goal is to determine the average number of trips that were made in each month from 2016 to 2017

Given that we know the number of trips made in a month from the previous question, we can just divide it by the number of days for each month. 
*/

DROP TABLE IF EXISTS ave_year_month;
CREATE TABLE ave_year_month AS 
SELECT YEAR(start_date) AS 'Year', 
	MONTH(start_date) AS 'Month', 
    CAST(COUNT(*) / (COUNT(DISTINCT start_date)) AS DECIMAL(6,2)) AS 'avg_trips_per_day'
FROM trips 
GROUP BY YEAR(start_date),MONTH(start_date)
ORDER BY YEAR(start_date);

/*Given that there were days in the month where people did not rent a bike, I used the DISTINCT function.

For example, if there were only 10 days of the month with different start dates, the average is calculated for each day that is travelled.
The results returned a float number with a large amount of numbers after the decimal, for readability this was a problem so I chose to 
reduce the numbers to two decimal places

From the results it can be seen that during the winter months the average trips per day decreased compared to summer months.
In 2017, the bike share system experienced an increase in the number of people that used the system. As mentioned before this could be due to a multitude of reasons
from better weather in 2017, more availability of bike stations around the city, increase in popularity of membership or increased advertising about 
the service around the city. 

I wanted to save the output of the query into a new table for readability and so that it can be referred to  whilst conducting my anlaysis.
*/

#Sanity Check
SELECT * 
FROM working_table1;

/* 
Bixi has a membership service for their bike users, I wanted to explore what the usage for members and non-members would be for 2016 and 2017.
*/

SELECT COUNT(id), 
	is_member
FROM trips
WHERE YEAR(start_date) = 2016 and YEAR(end_date) = 2016
GROUP BY is_member;

SELECT COUNT(id), 
	is_member
FROM trips
WHERE YEAR(start_date) = 2017 and YEAR(end_date) = 2017
GROUP BY is_member;

/* 
The output for both years follows the same pattern. There are more members than non-members that use the service - members use the system 4 times 
more than non-members.

This may be due to the fact there is a cost barrier to using the bikes if you are not a member compared to if you are a member.
There also maybe a location notification for members, maybe an app, that directs user to the nearest station for the bikes */

/* 
I wanted to explore the percentage of total trips by members for the year 2017 broken down by month.


I initially chose to do a join function that joined the two tables together with the same column of months, however, due to readability 
and processing speed I tried to think of a quicker way of doing it. This led me to using the in-built functions within SQL and the sum 
function which was much quicker and readability-wise was much clearer to understand. 
*/

SELECT MONTH(start_date) AS "Month", 
	CAST((SUM(is_member)*100)/COUNT(*) as DECIMAL(5,2)) AS Percentage
FROM trips 
WHERE YEAR(start_date) = 2016 AND YEAR(end_date) = 2016
GROUP BY MONTH(start_date);

/* 
From the results it can be seen that in the summer months more non-members used the service which decreased the percentages but in the cooler months on 
each side of the year May and October, the percentage increased. 
*/

/*   
Looking at the above queries it is clear to see that the Bixi bikes have the highest demand during the summer months, especially during months 5-9, with the higher peak being in 2017 
in these months than in 2016.

Looking at the data, to encourage non-members to join the bike scheme it is better to do it before the summer months, especially in May. 
This is because the average number of trips is 9 but jumps up to 14 in the next month from the 2017 data. Also, looking at the percentage of members 
taking trips by month, it is clear to see that after May it decreases which shows that more non-members are using the service. To maintain users, 
providing a promotion which last 4 months so that the promotion would last until the winter months would entice users to stay on even after it finishes. 
This could keep user using the service in the winter months and increase usage. */

/*
I want to explore the data to see where the most popular bike stations are so to see if that can illuminate any insights in the data. */

SELECT stations.name AS Station_name, 
	number_of_trips
FROM
(
SELECT start_station_code, 
	COUNT(*) as number_of_trips
FROM trips
GROUP BY start_station_code
LIMIT 5) AS station_sub
JOIN stations ON station_sub.start_station_code = stations.code
GROUP BY stations.name, number_of_trips;

/* I tried to do as much of the filtering within the sub-query to ensure that when it came to joining the two tables together, there was very little 
that needed to be done.

This was a much quicker method than the previous method, as the previous method involving joining two very large tables together and then 
filtering out the data from there which was a very time-intensive process. This way was much quicker and involved joining less data in tables together. 

Looking at the station names, with the help of google maps, it is evident to see that the stations with the highest popularity are the ones which are close 
to famous tourist spots or landamarks. For example Mackay/de maisonneuve is near the Montreal museum of fine arts and the parc du mont-royal. Rivard/
du mont-royal is next to the Metro mont-royal which is next to the Metro mont royal a well connected metro stop. It is clear from the data that users use 
the service as either part of the transportation process e.g. going on to the next stage by metro or to get to a specific tourist hotspot.
*/


/* The station Mackay / de Maisonneuve is the most popular, I wanted to explore its usage throughout the day */
SELECT *
FROM stations
WHERE start_station_code = (SELECT DISTINCT code from stations where name = "Mackay / de Maisonneuve"); 

/* I used the above code to find what the station code is for Makcay / de Miasonneuve. Which is 6100. */


SELECT COUNT(*),
	CASE
		WHEN HOUR(start_date) BETWEEN 7 AND 11 THEN "morning start"
		WHEN HOUR(start_date) BETWEEN 12 AND 16 THEN "afternoon start"
		WHEN HOUR(start_date) BETWEEN 17 AND 21 THEN "evening start"
        ELSE "night start"
	END AS "journey_time"
FROM trips
WHERE start_station_code = 6100
GROUP BY journey_time
ORDER BY journey_time DESC;

/*
From the results as expected, the highest number of trips were started during the afternoon, with the least being started at night. The morning was second
which could imply that the bikes are also used for morning commuters as well.alter
*/

/* 
I want to explore all the stations which at least 10% of trips are round trips and the total number of trips was 500. 
Round trips are those that start and end in the same station. 

1. First I need to determine the station which had 500 total trips per station. 
This is a simple approach of pulling out the station code and the count for each station, then grouping by station.*/

SELECT start_station_code,
	COUNT(*) AS Number_of_starting_trips
FROM trips
GROUP BY start_station_code;

/* 
My approach was to use a join function, given that both tables had a similar column of the station code, I was able to use that as the primary key which I could 
join the two tables on and also used that to group the data together with. Also I was able to calculate the mathematical function within the select command.

I had to filter down to stations with at least 500 trips originating from them and having at least 10% of their trips as round trips. 
I initially filtered out the data with a where function but this seemed quite inefficient and for readability purposes didn't seem concise so I 
chose to use a HAVING command instead and this allowed me to use the aliases as well saving space, >= was used as it wasking for at least 500 trips and 
10%. */

SELECT station_code,
	round_trips.number_of_round_trips/total_station_trips.number_of_starting_trips AS fractional,
    total_station_trips.number_of_starting_trips AS total_trips
FROM
(
SELECT start_station_code AS station_code,
	COUNT(*) AS number_of_round_trips
FROM trips
WHERE start_station_code = end_station_code
GROUP BY start_station_code) AS round_trips
JOIN
(
SELECT start_station_code,
	COUNT(*) AS number_of_starting_trips
FROM trips
GROUP BY start_station_code) AS total_station_trips
ON round_trips.station_code = total_station_trips.start_station_code
GROUP BY station_code
HAVING fractional >= 0.1 AND total_trips >= 500;

/* 
I want to explore further why there were so many round trips for these stations, so I needed to find the address for these stations which is below.*/

SELECT stations.name
FROM 
(
SELECT station_code,
	(round_trips.number_of_round_trips/total_station_trips.number_of_starting_trips) AS Fraction_of_round_trips
FROM
(
SELECT start_station_code AS station_code,
	COUNT(*) AS number_of_round_trips
FROM trips
WHERE start_station_code = end_station_code
GROUP BY start_station_code) AS round_trips
JOIN
(
SELECT start_station_code,
	COUNT(*) AS number_of_starting_trips
FROM trips
GROUP BY start_station_code) As total_station_trips
ON round_trips.station_code = total_station_trips.start_station_code
GROUP BY station_code) AS q5
JOIN stations ON q5.station_code = stations.code
ORDER BY Fraction_of_round_trips DESC;


/* Looking at the bike stations, I ordered the stations with the highest fractions and then matched the code with the station name.
By looking at google maps and searching up the station names, it is clear to see that the bike stations with the higest fractions 
were those close to landmarks or open areas like parks. This would imply that people used it to go for bike rides around 
scenic areas and then docked back where they started. */


/*
In this script I have explored the Bixi database and used SQL to understand the data. Determine trends and insights in the data which could be supplied 
to the company to help increase profits. With this preliminary analysis done, I can use these insights to conduct machine learning techniques on the data
in the future.
*/

