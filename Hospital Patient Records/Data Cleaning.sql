/*

Data Cleaning : Encounters

*/


CREATE TABLE encounters_raw (
    Id VARCHAR(36),
    START VARCHAR(30),
    STOP VARCHAR(30),
    PATIENT VARCHAR(36),
    ORGANIZATION VARCHAR(36),
    PAYER VARCHAR(36),
    ENCOUNTERCLASS VARCHAR(50),
    CODE VARCHAR(30),
    DESCRIPTION TEXT,
    BASE_ENCOUNTER_COST VARCHAR(30),
    TOTAL_CLAIM_COST VARCHAR(30),
    PAYER_COVERAGE VARCHAR(30),
    REASONCODE VARCHAR(30),
    REASONDESCRIPTION TEXT
);

LOAD DATA LOCAL INFILE '/Users/selam/Downloads/Hospital+Patient+Records/encounters.csv'
INTO TABLE encounters_raw
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;


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


-- create patient responsibility cost column after payer coverag

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
