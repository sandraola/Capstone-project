/* Cleaning and analysing data with SQL Queries */
----Google capstone projects-cyclistics bike-share analysis


--1 Merging all the 12months into one using Union All

SELECT  * into bike_merged
From 
(
SELECT * From Projects..May_2021
union all 
SELECT *  From Projects..June_2021
union all
SELECT * From Projects..July_2021
union all
SELECT * From Projects..August_2021
union all
SELECT * From Projects..sept_2021
union all 
SELECT * From Projects..Oct_2021
union all
SELECT * From Projects..Nov_2021
union all
SELECT * From Projects..Dec_2021
union all
SELECT * From Projects..Jan_2022
union all
SELECT * From Projects..Feb_2022
union all
SELECT * From Projects..March_2022
union all
SELECT * From Projects..April_2022
) as A

SELECT TOP 5 * from bike_merged
---------------------------------------------------------------------------------------------------------
--2 REMOVING NULLS

SELECT * INTO bike_notnull
FROM
(
SELECT * FROM bike_merged
WHERE start_station_name IS NOT NULL
AND start_station_id  IS  NOT NULL
AND end_station_name IS NOT NULL
AND end_station_id IS NOT NULL
AND start_lng IS NOT NULL
AND start_lat IS NOT NULL
AND end_lat IS NOT NULL
AND end_lng IS NOT NULL
) AS B

---------------------------------------------------------------------------------------------------------------------------------------

--3 Carried out some Exploratory Analysis to check for trends etc

   Select
    TimeofDay, Count(*) as total_ride,
    Min(day_of_week) as min_day_of_week, Min(bike_type) as min_biketype,
    MAX (day_of_week) as max_day_of_week,  MAX (bike_type) as max_biketype
   
   FROM [master].[dbo].[BIKE_TRANSFORM01]
   Group by TimeofDay
 
    -- Rush time and day of the week
	   Select day_of_week as weekday, Count(*) as total_trip, TimeofDay as dailytime, Count(*) as total_trip
	   FROM [master].[dbo].[BIKE_TRANSFORM01]
	   Group by day_of_week,TimeofDay
	   Order by 2 desc

	   -- Rush hour month of the year
	   Select started_month as month, Count(*) as total_trip
	   FROM [master].[dbo].[BIKE_TRANSFORM01]
	   Group by started_month
	   Order by 2 desc
	  
      --Number of biketype by day-of_week
   Select COUNT (bike_type) as total_biketype, day_of_week
   FROM [master].[dbo].[BIKE_TRANSFORM01]
   Group by day_of_week 
   Order by 1,2 desc

    --Mean of ride_length for rider_type
   Select AVG( ride_length) as mean_length, rider_type, Count(*) bike_type  --as total_bike_type
   FROM [master].[dbo].[BIKE_TRANSFORM01]
   Group by rider_type
   Order by 1, 2

      --Calculate  
   select  day_of_week, rider_type , Timeofday,  COUNT (bike_type) as total_bike_type
   FROM [master].[dbo].[BIKE_TRANSFORM01]
   group by rider_type, day_of_week, TimeofDay
   order by 3,2 desc

     --Startedyear per count of month
  Select started_year, count (*) started_month
   FROM [master].[dbo].[BIKE_TRANSFORM01]
   Group by started_year
   Order by started_year 

     --most common start station
  Select  DISTINCT (start_station_name), Count (*) as Count
  FROM [master].[dbo].[BIKE_TRANSFORM01]
  Group by start_station_name
  Order by count (*) desc


  ----------------------------------------------------------------------------------------------------------------------------------------------

--TRANSFORMING THE DATA

 SELECT * into BIKE_TRANSFORM01
 FROM
 ( SELECT  ride_id, rideable_type as bike_type 
 , year (started_at) as started_year
 , Datename (month, started_at) as started_month
 , Datename (weekday,started_at) as  day_of_week
 , Datepart (hour, started_at) as  Hour
 , datediff (minute, started_at, ended_at) as ride_length,

CASE 

WHEN  datepart (hour, started_at) >= 0 and datepart ( hour, started_at) <= 12 then  'morning'
WHEN  datepart (hour, started_at) >12 and datepart ( hour, started_at) <= 16 then 'afternoon'
WHEN  datepart (hour, started_at) >16 and datepart ( hour, started_at) <= 23 then 'evening' 

 ELSE null
 END as  TimeofDay
 ,start_station_id, start_station_name, end_station_id, end_station_name, start_lat, 
 start_lng,  end_lat,  end_lng,  member_casual as rider_type 

FROM [master].[dbo].[bike_notnull] )AS C


 
  SELECT *  FROM [master].[dbo].[BIKE_TRANSFORM]