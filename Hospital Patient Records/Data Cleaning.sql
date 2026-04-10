/*

Data Cleaning 

This script cleans two imported raw tables:
- encounters_raw
- patients_raw

The raw CSV files were imported before running this.

*/


-- convert START and STOP from text to datetime

ALTER TABLE encounters_raw
ADD COLUMN start_converted DATETIME,
ADD COLUMN stop_converted DATETIME;

UPDATE encounters_raw
SET start_converted = STR_TO_DATE(REPLACE(REPLACE(START, 'T', ' '), 'Z', ''), '%Y-%m-%d %H:%i:%s'),
    stop_converted = STR_TO_DATE(REPLACE(REPLACE(STOP, 'T', ' '), 'Z', ''), '%Y-%m-%d %H:%i:%s');


-- check date conversion

SELECT *
FROM encounters_raw
WHERE start_converted IS NULL
   OR stop_converted IS NULL;


-- drop original text date columns

ALTER TABLE encounters_raw
DROP COLUMN START,
DROP COLUMN STOP;


-- rename cleaned datetime columns

ALTER TABLE encounters_raw
CHANGE start_converted START DATETIME,
CHANGE stop_converted STOP DATETIME;


-- trim text columns

UPDATE encounters_raw
SET DESCRIPTION = LTRIM(RTRIM(DESCRIPTION))
WHERE DESCRIPTION IS NOT NULL;

UPDATE encounters_raw
SET ENCOUNTERCLASS = LOWER(LTRIM(RTRIM(ENCOUNTERCLASS)))
WHERE ENCOUNTERCLASS IS NOT NULL;

UPDATE encounters_raw
SET REASONDESCRIPTION = LTRIM(RTRIM(REASONDESCRIPTION))
WHERE REASONDESCRIPTION IS NOT NULL;


-- convert cost columns from text to numeric

ALTER TABLE encounters_raw
MODIFY BASE_ENCOUNTER_COST DECIMAL(18,2),
MODIFY TOTAL_CLAIM_COST DECIMAL(18,2),
MODIFY PAYER_COVERAGE DECIMAL(18,2);


-- create out-of-pocket cost column

ALTER TABLE encounters_raw
ADD COLUMN out_of_pocket_cost DECIMAL(18,2);

UPDATE encounters_raw
SET out_of_pocket_cost = TOTAL_CLAIM_COST - PAYER_COVERAGE;


-- check for duplicate encounter ids

SELECT Id, COUNT(*) AS duplicate_count
FROM encounters_raw
GROUP BY Id
HAVING COUNT(*) > 1;


-- Check for negative values in cost columns

SELECT *
FROM encounters_raw
WHERE BASE_ENCOUNTER_COST < 0
   OR TOTAL_CLAIM_COST < 0
   OR PAYER_COVERAGE < 0
   OR out_of_pocket_cost < 0;



/* Imported patients table */

-- convert birthdate and deathdate from txt to date format

ALTER TABLE patients_raw
ADD COLUMN birthdate_converted DATE,
ADD COLUMN deathdate_converted DATE;

UPDATE patients_raw
SET birthdate_converted = STR_TO_DATE(NULLIF(TRIM(BIRTHDATE), ''), '%Y-%m-%d'),
    deathdate_converted = STR_TO_DATE(NULLIF(TRIM(DEATHDATE), ''), '%Y-%m-%d');


-- check date conversion

SELECT BIRTHDATE, birthdate_converted, DEATHDATE, deathdate_converted
FROM patients_raw
LIMIT 20;


-- drop original text columns

ALTER TABLE patients_raw
DROP COLUMN BIRTHDATE,
DROP COLUMN DEATHDATE;

ALTER TABLE patients_raw
CHANGE birthdate_converted BIRTHDATE DATE,
CHANGE deathdate_converted DEATHDATE DATE;


-- check if columns stored as txt need to be trimmed

SELECT DISTINCT PREFIX
FROM patients_raw;


-- check gender values and see if values need to be trimmed
    
SELECT DISTINCT GENDER  
FROM patients_raw;


-- check marital values

SELECT DISTINCT MARITAL
FROM patients_raw;


-- expand marital value 

UPDATE patients_raw
SET MARITAL = 'Married'
WHERE MARITAL = 'M';

UPDATE patients_raw
SET MARITAL = 'Single'
WHERE MARITAL = 'S';


-- standardise, capitalise first letter for consistency

UPDATE patients_raw SET RACE = 'White' WHERE RACE = 'white';
UPDATE patients_raw SET RACE = 'Black' WHERE RACE = 'black';
UPDATE patients_raw SET RACE = 'Asian' WHERE RACE = 'asian';
UPDATE patients_raw SET RACE = 'Native' WHERE RACE = 'native';
UPDATE patients_raw SET RACE = 'Hawaiian' WHERE RACE = 'hawaiian';
UPDATE patients_raw SET RACE = 'Other' WHERE RACE = 'other';

UPDATE patients_raw SET ETHNICITY = 'Hispanic' WHERE ETHNICITY = 'hispanic';
UPDATE patients_raw SET ETHNICITY = 'Nonhispanic' WHERE ETHNICITY = 'nonhispanic';


-- check ZIP formatting, since the zip code starts 0 it needs to be stored at txt

SELECT ZIP
FROM patients_raw
LIMIT 20;


-- convert empty ZIP values to NULL

UPDATE patients_raw
SET ZIP = NULL
WHERE TRIM(ZIP) = '';


-- convert latitude and longitude to numeric datatype 

ALTER TABLE patients_raw
MODIFY LAT DECIMAL(12,8),
MODIFY LON DECIMAL(12,8);


-- check for duplicate patient id

SELECT Id, COUNT(*)
FROM patients_raw
GROUP BY Id
HAVING COUNT(*) > 1;


-- check for null values

SELECT *
FROM patients_raw
WHERE Id IS NULL
   OR BIRTHDATE IS NULL
   OR ZIP IS NULL
   OR LAT IS NULL
   OR LON IS NULL;
