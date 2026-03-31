/*

Cleaning Data in SQL Queries – MoMA Artists Table 1

*/


CREATE DATABASE moma_art;

USE moma_art;

--------------------------------------------------------------------------------------------------------------------------

-- Create raw table to store imported artist data


CREATE TABLE artists_raw (
  ConstituentID INT PRIMARY KEY,
  DisplayName TEXT,                
  ArtistBio TEXT,                
  Nationality TEXT,               
  Gender TEXT,                    
  BeginDate INT,                  
  EndDate INT,                    
  `Wiki QID` TEXT,                
  ULAN TEXT                       
);

--------------------------------------------------------------------------------------------------------------------------

-- Load Data from CSV File


LOAD DATA LOCAL INFILE '/Users/selam/Downloads/MoMA+Art+Collection/Artists.csv'
INTO TABLE artists_raw
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

--------------------------------------------------------------------------------------------------------------------------

-- Trim and Handle Empty Values in Fields


UPDATE artists_raw
SET
  DisplayName = NULLIF(TRIM(DisplayName), ''),
  ArtistBio = NULLIF(TRIM(ArtistBio), ''),
  Nationality = NULLIF(TRIM(Nationality), ''),
  Gender = NULLIF(TRIM(Gender), ''),
  `Wiki QID` = NULLIF(TRIM(`Wiki QID`), ''),
  ULAN = NULLIF(TRIM(ULAN), '');

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Gender Values


UPDATE artists_raw
SET Gender = LOWER(Gender)
WHERE Gender IS NOT NULL;

--------------------------------------------------------------------------------------------------------------------------

-- Handle Missing Year Values


UPDATE artists_raw
SET BeginDate = NULL
WHERE BeginDate = 0;

UPDATE artists_raw
SET EndDate = NULL
WHERE EndDate = 0;




/*

Cleaning Data in SQL Queries – MoMA Artworks Table 2

*/


CREATE TABLE artworks_raw (
  Title TEXT,
  Artist TEXT,
  ConstituentID TEXT,
  ArtistBio TEXT,
  Nationality TEXT,
  BeginDate TEXT,
  EndDate TEXT,
  Gender TEXT,
  Date TEXT,
  Medium TEXT,
  Dimensions TEXT,
  CreditLine TEXT,
  AccessionNumber TEXT,
  Classification TEXT,
  Department TEXT,
  DateAcquired TEXT,
  Cataloged TEXT,
  ObjectID INT,
  URL TEXT,
  ImageURL TEXT,
  OnView TEXT,
  `Circumference (cm)` TEXT,
  `Depth (cm)` TEXT,
  `Diameter (cm)` TEXT,
  `Height (cm)` TEXT,
  `Length (cm)` TEXT,
  `Weight (kg)` TEXT,
  `Width (cm)` TEXT,
  `Seat Height (cm)` TEXT,
  `Duration (sec.)` TEXT
);

--------------------------------------------------------------------------------------------------------------------------

-- Load data from CSV


LOAD DATA LOCAL INFILE '/Users/selam/Downloads/MoMA+Art+Collection/Artworks.csv'
INTO TABLE artworks_raw
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

--------------------------------------------------------------------------------------------------------------------------

-- Remove invalid and duplicate rows before adding primary key


DELETE FROM artworks_raw
WHERE ObjectID IS NULL
   OR ObjectID = 0
   OR ObjectID IN (15, 18);

--------------------------------------------------------------------------------------------------------------------------

-- Add primary key


ALTER TABLE artworks_raw
ADD PRIMARY KEY (ObjectID);

--------------------------------------------------------------------------------------------------------------------------

-- Trim spaces and replace blanks with NULL


UPDATE artworks_raw
SET
  Title = NULLIF(TRIM(Title), ''),
  Artist = NULLIF(TRIM(Artist), ''),
  ArtistBio = NULLIF(TRIM(ArtistBio), ''),
  Nationality = NULLIF(TRIM(Nationality), ''),
  Medium = NULLIF(TRIM(Medium), ''),
  Dimensions = NULLIF(TRIM(Dimensions), ''),
  CreditLine = NULLIF(TRIM(CreditLine), ''),
  AccessionNumber = NULLIF(TRIM(AccessionNumber), ''),
  Classification = NULLIF(TRIM(Classification), ''),
  Department = NULLIF(TRIM(Department), '');



UPDATE artworks_raw
SET
  ConstituentID = NULLIF(TRIM(ConstituentID), ''),
  URL = NULLIF(TRIM(URL), ''),
  ImageURL = NULLIF(TRIM(ImageURL), '');



UPDATE artworks_raw
SET
  BeginDate = NULLIF(TRIM(BeginDate), ''),
  EndDate = NULLIF(TRIM(EndDate), ''),
  Date = NULLIF(TRIM(Date), ''),
  DateAcquired = NULLIF(TRIM(DateAcquired), '');



UPDATE artworks_raw
SET
  Gender = NULLIF(TRIM(Gender), ''),
  Cataloged = NULLIF(TRIM(Cataloged), ''),
  OnView = NULLIF(TRIM(OnView), '');



UPDATE artworks_raw
SET
  Gender = NULLIF(TRIM(Gender), '()'),
  Nationality = NULLIF(TRIM(Nationality), '()'),
  ArtistBio = NULLIF(TRIM(ArtistBio), '()'),
  BeginDate = NULLIF(TRIM(BeginDate), '()'),
  EndDate = NULLIF(TRIM(EndDate), '()');

--------------------------------------------------------------------------------------------------------------------------

-- Standardise Cataloged values


UPDATE artworks_raw
SET Cataloged = CASE
  WHEN Cataloged = 'Y' THEN 'yes'
  WHEN Cataloged = 'N' THEN 'no'
  ELSE Cataloged
END;

--------------------------------------------------------------------------------------------------------------------------

-- Remove quotation marks


UPDATE artworks_raw
SET OnView = REPLACE(OnView, '"', '')
WHERE OnView IS NOT NULL;

--------------------------------------------------------------------------------------------------------------------------

-- Replace invalid date 


UPDATE artworks_raw
SET BeginDate = NULL
WHERE BeginDate = '(0)';



UPDATE artworks_raw
SET EndDate = NULL
WHERE EndDate = '(0)'
   OR EndDate = '(0) (0)';

--------------------------------------------------------------------------------------------------------------------------

-- Convert measurement columns (rounded to 2 decimal places)


ALTER TABLE artworks_raw MODIFY COLUMN `Height (cm)` DECIMAL(8,2);
ALTER TABLE artworks_raw MODIFY COLUMN `Width (cm)` DECIMAL(8,2);
ALTER TABLE artworks_raw MODIFY COLUMN `Depth (cm)` DECIMAL(8,2);
ALTER TABLE artworks_raw MODIFY COLUMN `Diameter (cm)` DECIMAL(8,2);
ALTER TABLE artworks_raw MODIFY COLUMN `Length (cm)` DECIMAL(8,2);
ALTER TABLE artworks_raw MODIFY COLUMN `Weight (kg)` DECIMAL(8,2);
ALTER TABLE artworks_raw MODIFY COLUMN `Circumference (cm)` DECIMAL(8,2);
ALTER TABLE artworks_raw MODIFY COLUMN `Seat Height (cm)` DECIMAL(8,2);
ALTER TABLE artworks_raw MODIFY COLUMN `Duration (sec.)` DECIMAL(12,2);

--------------------------------------------------------------------------------------------------------------------------

-- Create table to handle multiple artists per artwork


CREATE TABLE artwork_artists (
  ObjectID INT,
  ConstituentID INT
);


--------------------------------------------------------------------------------------------------------------------------

-- Split comma-separated ConstituentID values into separate rows


INSERT INTO artwork_artists (ObjectID, ConstituentID)
SELECT
  artworks_raw.ObjectID,
  CAST(TRIM(j.ConstituentID) AS UNSIGNED)
FROM artworks_raw,
JSON_TABLE(
  CONCAT('["', REPLACE(artworks_raw.ConstituentID, ',', '","'), '"]'),
  '$[*]' COLUMNS (
    ConstituentID VARCHAR(50) PATH '$'
  )
) AS j
WHERE artworks_raw.ConstituentID IS NOT NULL;

--------------------------------------------------------------------------------------------------------------------------

-- Prevent duplicate artwork to artist relationships


ALTER TABLE artwork_artists
ADD PRIMARY KEY (ObjectID, ConstituentID);
