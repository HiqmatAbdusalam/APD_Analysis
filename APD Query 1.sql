--CREATE TABLE
CREATE TABLE apd_calls (
Incident_Number VARCHAR (100),
Incident_Type VARCHAR (100),
Mental_Health_Flag VARCHAR (100),
Priority_Level VARCHAR (100),
Response_Datetime TIMESTAMP,
Response_Day_of_Week VARCHAR (100),
Response_Hour VARCHAR (10),
First_Unit_Arrived TIMESTAMP,
Call_Closed_Datetime TIMESTAMP,
Sector VARCHAR (100),
Initial_Problem_Description VARCHAR (100),
Initial_Problem_Category VARCHAR (100),
Final_Problem_Description VARCHAR (100),
Final_Problem_Category VARCHAR (100),
Number_of_Units_Arrived INT,
Unit_Time_on_Scene INT,
Call_Disposition_Description VARCHAR (100),
Report_Written_Flag VARCHAR (10),
Response_Time INT,
Officer_Injured_or_Killed_Count INT,
Subject_Injured_or_Killed_Count INT,
Other_Injured_or_Killed_Count INT,
Geo_ID VARCHAR (100),
Census_Block_Group VARCHAR (100),
Council_District VARCHAR (100)
);

-- CHECKING FOR DUPLICATES
SELECT * FROM apd_calls
GROUP BY Incident_Number, Incident_Type,
Mental_Health_Flag, Priority_Level,
Response_Datetime, Response_Day_of_Week, Response_Hour,
First_Unit_Arrived, Call_Closed_Datetime, Sector,
Initial_Problem_Description, Initial_Problem_Category,
Final_Problem_Description, Final_Problem_Category,
Number_of_Units_Arrived, Unit_Time_on_Scene,
Call_Disposition_Description, Report_Written_Flag,
Response_Time, Officer_Injured_or_Killed_Count,
Subject_Injured_or_Killed_Count, Other_Injured_or_Killed_Count,
Geo_ID, Census_Block_Group, Council_District
HAVING COUNT(*)>1;

---CHECKING FOR NULL VALUES
SELECT * FROM apd_calls
WHERE Incident_Number IS NULL;

SELECT * FROM apd_calls
WHERE Mental_Health_Flag IS NULL;

SELECT * FROM apd_calls
WHERE Priority_Level IS NULL;

SELECT * FROM apd_calls
WHERE Response_Datetime IS NULL;

SELECT * FROM apd_calls
WHERE Response_Day_of_Week IS NULL;

SELECT * FROM apd_calls
WHERE Response_Hour IS NULL;

SELECT * FROM apd_calls
WHERE First_Unit_Arrived IS NULL;

SELECT * FROM apd_calls
WHERE Call_Closed_Datetime IS NULL;

SELECT * FROM apd_calls
WHERE Sector IS NULL;

SELECT * FROM apd_calls
WHERE Initial_Problem_Description IS NULL;

SELECT * FROM apd_calls
WHERE Initial_Problem_Category IS NULL;

SELECT * FROM apd_calls
WHERE Final_Problem_Description IS NULL;

SELECT * FROM apd_calls
WHERE Final_Problem_Category IS NULL;

SELECT * FROM apd_calls
WHERE Number_of_Units_Arrived IS NULL;

SELECT * FROM apd_calls
WHERE Call_Disposition_Description IS NULL;

--HANDLING COLUMNS WITH NULL VALUES
--Incident Type
SELECT * FROM apd_calls
WHERE Incident_Type IS NULL;

DELETE FROM apd_calls
WHERE Incident_Type IS NULL;

--Unit Time on Scene
SELECT * FROM apd_calls
WHERE Unit_Time_on_Scene IS NULL;

UPDATE apd_calls
SET Unit_Time_on_Scene = (
  SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Unit_Time_on_Scene)
  FROM apd_calls)
WHERE Unit_Time_on_Scene IS NULL;

--Report Flag
SELECT * FROM apd_calls
WHERE Report_Written_Flag IS NULL;

UPDATE apd_calls
SET Report_Written_Flag = (SELECT Report_Written_Flag FROM (SELECT Report_Written_Flag, COUNT(*) as frequency
FROM apd_calls
GROUP BY Report_Written_Flag) AS report_writen_count
ORDER BY frequency DESC
LIMIT 1)
WHERE Report_Written_Flag IS NULL;

--Response Time
SELECT * FROM apd_calls
WHERE Response_Time IS NULL;

UPDATE apd_calls
SET Response_Time = (
  SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Response_Time)
  FROM apd_calls)
WHERE Response_Time IS NULL;

--Injured persons
SELECT * FROM apd_calls
WHERE Officer_Injured_or_Killed_Count IS NULL;

UPDATE apd_calls
SET Officer_Injured_or_Killed_Count = 
		(SELECT Officer_Injured_or_Killed_Count FROM (SELECT Officer_Injured_or_Killed_Count, COUNT(*) as frequency
		FROM apd_calls
		GROUP BY Officer_Injured_or_Killed_Count) AS officer_injured_count
		ORDER BY frequency DESC
		LIMIT 1)
WHERE Officer_Injured_or_Killed_Count IS NULL;

SELECT * FROM apd_calls
WHERE Subject_Injured_or_Killed_Count IS NULL;

UPDATE apd_calls
SET Subject_Injured_or_Killed_Count = 
		(SELECT Subject_Injured_or_Killed_Count FROM (SELECT Subject_Injured_or_Killed_Count, COUNT(*) as frequency
		FROM apd_calls
		GROUP BY Subject_Injured_or_Killed_Count) AS subject_injured_count
		ORDER BY frequency DESC
		LIMIT 1)
WHERE Subject_Injured_or_Killed_Count IS NULL;

SELECT * FROM apd_calls
WHERE Other_Injured_or_Killed_Count IS NULL;

UPDATE apd_calls
SET Other_Injured_or_Killed_Count = 
		(SELECT Other_Injured_or_Killed_Count FROM (SELECT Other_Injured_or_Killed_Count, COUNT(*) as frequency
		FROM apd_calls
		GROUP BY Other_Injured_or_Killed_Count) AS other_injured_count
		ORDER BY frequency DESC
		LIMIT 1)
WHERE Other_Injured_or_Killed_Count IS NULL;

--Geo ID
SELECT * FROM apd_calls
WHERE Geo_ID IS NULL;

UPDATE apd_calls
SET Geo_ID = (SELECT Geo_ID FROM (SELECT Geo_ID, COUNT(*) as frequency
FROM apd_calls
GROUP BY Geo_ID) AS Geo_ID_count
ORDER BY frequency DESC
LIMIT 1)
WHERE Geo_ID IS NULL;

--Cell Block Group
SELECT * FROM apd_calls
WHERE Census_Block_Group IS NULL;

UPDATE apd_calls
SET census_block_group = (SELECT census_block_group FROM (SELECT census_block_group, COUNT(*) as frequency
FROM apd_calls
GROUP BY census_block_group) AS CBG_ID_count
ORDER BY frequency DESC
LIMIT 1)
WHERE census_block_group IS NULL;

--Council District
SELECT * FROM apd_calls
WHERE Council_District IS NULL;

UPDATE apd_calls
SET Council_District =
		(SELECT Council_District FROM (SELECT Geo_ID, census_block_group, council_district, COUNT(council_district) AS frequency
		FROM apd_calls
		GROUP BY Geo_ID, census_block_group, council_district)
		ORDER BY frequency DESC
		LIMIT 1)
WHERE Council_DistricT IS NULL;

--Others
SELECT * FROM apd_calls
WHERE call_disposition_description ='U{'

--REPLACING A VALUE
SELECT * FROM apd_calls
WHERE call_disposition_description LIKE 'U%'

UPDATE apd_calls
SET call_disposition_description = 'Unable to Locate'
WHERE call_disposition_description = 'U{';


--Standardize Datetime Format to Date Format
SELECT * FROM apd_calls
ALTER TABLE apd_calls
ADD response_date DATE;
UPDATE apd_calls
SET response_date = DATE(response_datetime);

ALTER TABLE apd_calls
ADD first_unit_arrived_date DATE;
UPDATE apd_calls
SET first_unit_arrived_date = DATE(first_unit_arrived);

ALTER TABLE apd_calls
ADD call_closed_date DATE;
UPDATE apd_calls
SET call_closed_date = DATE(call_closed_datetime);

/*SELECT * FROM apd_calls
WHERE Incident_Number IS NULL
OR Incident_Type IS NULL
OR Mental_Health_Flag IS NULL
OR Priority_Level IS NULL
OR Response_Datetime IS NULL
OR Response_Day_of_Week IS NULL
OR Response_Hour IS NULL
OR First_Unit_Arrived IS NULL
OR Call_Closed_Datetime IS NULL
OR Sector IS NULL
OR Initial_Problem_Description IS NULL
OR Initial_Problem_Category IS NULL
OR Final_Problem_Description IS NULL
OR Final_Problem_Category IS NULL
OR Number_of_Units_Arrived IS NULL
OR Unit_Time_on_Scene IS NULL
OR Call_Disposition_Description IS NULL
OR Report_Written_Flag IS NULL
OR Response_Time IS NULL
OR Officer_Injured_or_Killed_Count IS NULL
OR Subject_Injured_or_Killed_Count IS NULL
OR Other_Injured_or_Killed_Count IS NULL
OR Geo_ID IS NULL
OR Census_Block_Group IS NULL
OR Council_District IS NULL;