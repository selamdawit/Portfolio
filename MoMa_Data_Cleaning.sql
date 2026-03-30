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






