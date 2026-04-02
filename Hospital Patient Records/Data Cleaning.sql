CREATE TABLE encounters_raw (
    `Id` VARCHAR(36),
    `START` VARCHAR(30),
    `STOP` VARCHAR(30),
    `PATIENT` VARCHAR(36),
    `ORGANIZATION` VARCHAR(36),
    `PAYER` VARCHAR(36),
    `ENCOUNTERCLASS` VARCHAR(50),
    `CODE` VARCHAR(30),
    `DESCRIPTION` TEXT,
    `BASE_ENCOUNTER_COST` VARCHAR(30),
    `TOTAL_CLAIM_COST` VARCHAR(30),
    `PAYER_COVERAGE` VARCHAR(30),
    `REASONCODE` VARCHAR(30),
    `REASONDESCRIPTION` TEXT
);



LOAD DATA LOCAL INFILE '/Users/selam/Downloads/Hospital+Patient+Records/encounters.csv'
INTO TABLE encounters_raw
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;



ALTER TABLE encounters_raw
ADD COLUMN Start_Converted DATETIME;



UPDATE encounters_raw
SET Start_Converted = STR_TO_DATE(REPLACE(REPLACE(START, 'T', ' '), 'Z', ''), '%Y-%m-%d %H:%i:%s');



ALTER TABLE encounters_raw
ADD Stop_Converted DATETIME;



UPDATE encounters_raw
SET Stop_Converted = STR_TO_DATE(REPLACE(REPLACE(STOP, 'T', ' '), 'Z', ''), '%Y-%m-%d %H:%i:%s');



SELECT * 
FROM encounters_raw
WHERE Start_Converted IS NULL
   OR Stop_Converted IS NULL;


/* no rows failed the conversion, drop the original text columns and keep the cleaned datetime columns */


ALTER TABLE encounters_raw
DROP COLUMN START,
DROP COLUMN STOP;


/* rename the cleaned columns: */


ALTER TABLE encounters_raw
CHANGE Start_Converted START DATETIME;


/* remove extra spaces in description column */


UPDATE encounters_raw
SET DESCRIPTION = LTRIM(RTRIM(DESCRIPTION));



