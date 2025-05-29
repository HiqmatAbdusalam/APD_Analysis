--1. Total number of incidents that occurred in each sector
SELECT sector, COUNT(*) AS total_incident
FROM apd_calls
GROUP BY 1
ORDER BY total_incident DESC;

--2. Top 5 busiest geographic areas and the average response time for each of these areas.
SELECT census_block_group, COUNT(*) AS total_calls, ROUND(AVG(response_time),2) AS avg_response_time
FROM apd_calls
GROUP BY 1
ORDER BY total_calls DESC
LIMIT 5;

--3. Identify sectors where mental health-related incidents make up more than 30% of the total incidents.
WITH MHI AS (SELECT sector, COUNT(*) AS total_incidents, 
       SUM(CASE WHEN mental_health_flag = 'Mental Health Incident' THEN 1 ELSE 0 END) AS mental_health_incidents
FROM apd_calls
GROUP BY sector)

SELECT sector, (mental_health_incidents *100 / total_incidents) MHI_percentage FROM MHI
	WHERE (mental_health_incidents *100 / total_incidents) > 30;

--4. The busiest days of the week, and how do the types of incidents differ across those days
SELECT response_day_of_week AS weekday,final_problem_category, COUNT(*) Total_incident FROM apd_calls
GROUP BY 1,2
ORDER BY 3 DESC;

--5. Average response time for incidents involving mental health issues
SELECT ROUND(AVG(response_time),2) AS mental_health_average_response_time FROM apd_calls
WHERE mental_health_flag= 'Mental Health Incident';

--6. Incident types with above-average response times
WITH Overall_Average AS (
    SELECT AVG(response_time) AS total_avg_response
    FROM apd_calls)
SELECT incident_type, ROUND(AVG(response_time),2) AS avg_response_time
FROM apd_calls
GROUP BY incident_type
HAVING AVG(response_time) > (SELECT total_avg_response FROM Overall_average);

--7. Geographic areas with above-average units dispatched
WITH Avg_unit AS (
    SELECT ROUND(AVG(number_of_units_arrived),0) AS total_avg_unit_arrived
    FROM apd_calls)
SELECT census_block_group, ROUND(AVG(number_of_units_arrived),0) AS avg_unit
FROM apd_calls
GROUP BY 1
HAVING AVG(number_of_units_arrived) > (SELECT total_avg_unit_arrived FROM Avg_unit)
ORDER BY 2 DESC;

--8. Sectors with the highest percentage of reclassified calls
WITH A AS (SELECT sector, COUNT(*) AS total_calls,
      SUM(CASE WHEN initial_problem_description <> final_problem_description THEN 1 ELSE 0 END)
	  AS reclassified_calls FROM apd_calls
	  GROUP BY sector)
SELECT *, (reclassified_calls*100/total_calls) AS percentage_of_reclassified_calls
FROM A
ORDER BY percentage_of_reclassified_calls DESC;

--9.Cumulative number of calls by day and sector*;
SELECT response_date, sector, COUNT(*) AS total_calls,
SUM(COUNT(*))OVER(PARTITION BY sector ORDER BY response_date) AS cumulative_calls
FROM apd_calls
GROUP BY 1,2;
--OR
WITH Y AS (SELECT response_date, sector, COUNT(*) Total_calls FROM apd_calls
GROUP BY 1,2)
SELECT *, SUM(Total_calls) OVER (PARTITION BY sector ORDER BY response_date) AS cumulative_calls
FROM Y;

--10. For each sector, rank the geographic areas by total number of 911 calls and show the response time for each area
SELECT sector, census_block_group, COUNT(*) AS total_calls, ROUND(AVG(response_time),2) AS avg_response_time,
       RANK() OVER (PARTITION BY sector ORDER BY COUNT(*) DESC) AS call_rank
FROM apd_calls
GROUP BY sector, census_block_group;

--11. What are the most common types of incidents that occur between 10 PM and 6 AM?
SELECT final_problem_category AS common_incidents, COUNT(*) AS total_incident
FROM apd_calls
WHERE response_hour = '22' OR response_hour < '6'
GROUP BY 1
ORDER BY 2 DESC;

--12. What percentage of incidents required more than 3 units to be dispatched?
WITH A AS
(SELECT COUNT(*) AS more_than_3_units FROM apd_calls WHERE number_of_units_arrived > 3),

B AS (SELECT COUNT(*) total_incident FROM apd_calls)

SELECT (more_than_3_units) *100 / (SELECT total_incident FROM B) percentage_more_than_3_units
FROM A;

--13. How do response times compare across different priorities for each type of incident?
SELECT final_problem_category, priority_level, ROUND(AVG(response_time),2) AS avg_response_time 
FROM apd_calls
GROUP BY final_problem_category, priority_level;

--14. Which geographic areas have the highest number of incidents involving officer injuries or fatalities?
SELECT census_block_group, COUNT(officer_injured_or_killed_count) number_of_injured_oficer FROM apd_calls
WHERE officer_injured_or_killed_count>0
GROUP BY census_block_group;

--15. Which council districts have the highest average response times?
SELECT council_district, ROUND(AVG(response_time),2) AS avg_response_time
FROM apd_calls
GROUP BY 1
ORDER BY 2 DESC;

--16. How many incidents involve serious injury or death (either officers or subjects) related to mental health?
SELECT COUNT(*) AS injury_incidents
FROM apd_calls
WHERE mental_health_flag = 'Mental Health Incident'
AND (officer_injured_or_killed_count > 0 OR subject_injured_or_killed_count > 0);

--17. Average response time for each incident type and compare it with the overall average response time.
SELECT final_problem_category, ROUND(AVG(response_time),2) AS avg_response_time
FROM apd_calls
GROUP BY final_problem_category
HAVING AVG(response_time) > (SELECT AVG(response_time) FROM apd_calls)
ORDER BY avg_response_time DESC;

--*18. Which incidents have closure times that are longer than the average closure time for all incidents?
WITH Avg_closure AS (SELECT ROUND(AVG(unit_time_on_scene),2) AS avg_time_on_scene FROM apd_calls)

SELECT final_problem_category, ROUND(AVG(unit_time_on_scene),2) FROM apd_calls
GROUP BY final_problem_category
HAVING AVG(unit_time_on_scene) > (SELECT avg_time_on_scene FROM Avg_closure);

/*19. For each day of the week, calculate the difference between the average response time for that day
and the average response time for all days combined.*/
WITH Overall_average AS
(SELECT AVG(response_time) AS overall_average FROM apd_calls),

Average_per_day AS (SELECT response_day_of_week AS weekday, AVG(response_time) avg_response_time
FROM apd_calls
GROUP BY 1)

SELECT weekday, ROUND(avg_response_time -(SELECT overall_average FROM overall_average),2) AS response_time_difference
FROM Average_per_day
ORDER BY 2 DESC;

--20. What are the top 3 most frequent final problem descriptions?
SELECT final_problem_description, COUNT(*) AS most_frequent FROM apd_calls
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;

--21. What are the busiest times of the day, and how do incident types vary by time?
SELECT response_hour, COUNT(*) AS Total_incident FROM apd_calls
GROUP BY 1
ORDER BY 2 DESC;

--22. What is the total number of mental health-related incidents, and how has this changed over time?
SELECT response_date, COUNT(*) total_MHI FROM apd_calls
WHERE mental_health_flag= 'Mental Health Incident'
GROUP BY 1;

--23. Which sectors have above-average mental health-related incidents compared to the overall average for all sectors?
WITH avg_mental_health AS (
    SELECT AVG(MHI) AS overall_avg
    FROM (SELECT sector, COUNT(*) AS MHI
          FROM apd_calls
          WHERE mental_health_flag = 'Mental Health Incident'
          GROUP BY sector) AS sector_counts)

SELECT sector
FROM (SELECT sector, COUNT(*) AS MHI
      FROM apd_calls
      WHERE mental_health_flag = 'Mental Health Incident'
      GROUP BY sector) AS sector_counts
WHERE MHI > (SELECT overall_avg FROM avg_mental_health);

--24. What is the average time spent on scene by units across different types of incidents?
SELECT final_problem_category, ROUND(AVG(unit_time_on_scene),2) avg_time_on_scene FROM apd_calls
GROUP BY 1;

/*25. What is the distribution of response times across the sectors, and which sectors have the fastest
and slowest response times?*/
SELECT sector, AVG(response_time) AS response_time_distribution FROM apd_calls
GROUP BY 1
ORDER BY 2 DESC;

/*26. Which incidents have the longest on-scene time, and how does this correlate with the incident type or
priority level?*/
SELECT priority_level, final_problem_category, AVG(unit_time_on_scene) AS on_scene_time FROM apd_calls
GROUP BY 1,2;

--27. Which types of incidents typically require reports to be written, and how frequently do these occur?
SELECT final_problem_category, COUNT(*) AS report_count FROM apd_calls
WHERE report_written_flag = 'Yes'
GROUP BY final_problem_category;

--28. What is the average number of units dispatched to incidents based on the incident type?
SELECT incident_type, ROUND(AVG(number_of_units_arrived),0) AS avg_number_of_units_dispatched FROM apd_calls
GROUP BY incident_type;

/*29. How do incidents involving officer injuries correlate with mental health-related flags,
and which sectors have the highest occurrence of these incidents?*/
SELECT sector, COUNT(*) AS incidents_involving_officer_injury FROM apd_calls
WHERE mental_health_flag= 'Mental Health Incident' AND officer_injured_or_killed_count > 0
GROUP BY 1;