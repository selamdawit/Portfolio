-- MoMA Artists Table 1 : Trim and Handle Empty Values in Fields


UPDATE artists_raw
SET
  DisplayName = NULLIF(TRIM(DisplayName), ''),
  ArtistBio = NULLIF(TRIM(ArtistBio), ''),
  Nationality = NULLIF(TRIM(Nationality), ''),
  Gender = NULLIF(TRIM(Gender), ''),
  `Wiki QID` = NULLIF(TRIM(`Wiki QID`), ''),
  ULAN = NULLIF(TRIM(ULAN), '');


-- Standardize Gender Values


UPDATE artists_raw
SET Gender = LOWER(Gender)
WHERE Gender IS NOT NULL;


-- Handle Missing Year Values


UPDATE artists_raw
SET BeginDate = NULL
WHERE BeginDate = 0;

UPDATE artists_raw
SET EndDate = NULL
WHERE EndDate = 0;



-- MoMA Artworks Table 2: Remove invalid and duplicate rows before adding primary key


DELETE FROM artworks_raw
WHERE ObjectID IS NULL
   OR ObjectID = 0
   OR ObjectID IN (15, 18);


-- Add primary key


ALTER TABLE artworks_raw
ADD PRIMARY KEY (ObjectID);


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


-- Standardise Cataloged values


UPDATE artworks_raw
SET Cataloged = CASE
  WHEN Cataloged = 'Y' THEN 'yes'
  WHEN Cataloged = 'N' THEN 'no'
  ELSE Cataloged
END;


-- Remove quotation marks


UPDATE artworks_raw
SET OnView = REPLACE(OnView, '"', '')
WHERE OnView IS NOT NULL;





-- Create copy of begin date column to clean


ALTER TABLE artworks_raw
ADD COLUMN BeginDate_clean TEXT;

UPDATE artworks_raw
SET BeginDate_clean = BeginDate;


-- Replace invalid date 


UPDATE artworks_raw
SET BeginDate_Clean = NULL
WHERE BeginDate_Clean = '(0)';


-- Remove (0) from BeginDate 


UPDATE artworks_raw
SET BeginDate_Clean = TRIM(REPLACE(BeginDate_Clean, '(0)', ''))
WHERE BeginDate_Clean LIKE '%(0)%'
  AND BeginDate_Clean <> '(0)';


-- Find first ) and keep everything from the start


UPDATE artworks_raw
SET BeginDate_Clean = LEFT(BeginDate_Clean, LOCATE(')', BeginDate_Clean))
WHERE BeginDate_Clean IS NOT NULL
  AND LOCATE(')', BeginDate_Clean) > 0;


-- Empty string to null


UPDATE artworks_raw
SET BeginDate_Clean = NULL
WHERE BeginDate_Clean = '';


-- Remove bracket around date


UPDATE artworks_raw
SET BeginDate_Clean = REPLACE(REPLACE(BeginDate_Clean, '(', ''), ')', '');





-- Create copy of end date column to clean


ALTER TABLE artworks_raw
ADD COLUMN EndDate_clean TEXT;

UPDATE artworks_raw
SET EndDate_clean = EndDate;


-- Replace invalid date 


UPDATE artworks_raw
SET EndDate_clean = NULL
WHERE EndDate_clean = '(0)'
   OR EndDate_clean = '(0) (0)';


UPDATE artworks_raw
SET EndDate_Clean = TRIM(REPLACE(EndDate_Clean, '(0)', ''))
WHERE EndDate_Clean LIKE '%(0)%'
  AND EndDate_Clean <> '(0)';


UPDATE artworks_raw
SET EndDate_Clean = LEFT(EndDate_Clean, LOCATE(')', EndDate_Clean))
WHERE EndDate_Clean IS NOT NULL
  AND LOCATE(')', EndDate_Clean) > 0;


UPDATE artworks_raw
SET EndDate_Clean = NULL
WHERE EndDate_Clean = '';

UPDATE artworks_raw
SET EndDate_Clean = REPLACE(REPLACE(EndDate_Clean, '(', ''), ')', '');




-- Convert to proper date


ALTER TABLE artworks_raw
ADD COLUMN DateAcquired_clean DATE;


UPDATE artworks_raw
SET DateAcquired_clean = STR_TO_DATE(DateAcquired, '%Y-%m-%d')
WHERE DateAcquired IS NOT NULL;


-- Create an acquired year column for dashboard


ALTER TABLE artworks_raw
ADD COLUMN AcquiredYear INT;

UPDATE artworks_raw
SET AcquiredYear = YEAR(DateAcquired_clean)
WHERE DateAcquired_clean IS NOT NULL;





-- Create copy of date column to clean


ALTER TABLE artworks_raw
ADD COLUMN Date_clean TEXT;

UPDATE artworks_raw
SET Date_clean = Date;


-- Remove bad values


UPDATE artworks_raw
SET Date_clean = NULL
WHERE Date_clean IN ('n.d.', 'Unknown', 'Unkown', 'Various');

UPDATE artworks_raw
SET Date_clean = LOWER(Date_clean);

UPDATE artworks_raw
SET Date_clean = REPLACE(Date_clean, 'c.', '');

UPDATE artworks_raw
SET Date_clean = REPLACE(Date_clean, 'ca.', '');

UPDATE artworks_raw
SET Date_clean = REPLACE(Date_clean, 'before', '');

UPDATE artworks_raw
SET Date_clean = REPLACE(Date_clean, 'after', '');

UPDATE artworks_raw
SET Date_clean = REPLACE(Date_clean, 'early', '');

UPDATE artworks_raw
SET Date_clean = REPLACE(Date_clean, 'late', '');


-- Trim Spaces


UPDATE artworks_raw
SET Date_clean = TRIM(Date_clean)
WHERE Date_clean IS NOT NULL;


-- Standardise dashes and .


UPDATE artworks_raw
SET Date_clean = REPLACE(Date_clean, '.', '')
WHERE Date_clean IS NOT NULL;

UPDATE artworks_raw
SET Date_clean = TRIM(Date_clean)
WHERE Date_clean IS NOT NULL;


-- Extract first 4 digit year


ALTER TABLE artworks_raw
ADD COLUMN artwork_year INT;

UPDATE artworks_raw
SET artwork_year =
    CASE
        WHEN Date_clean REGEXP '[0-9]{4}'
        THEN CAST(
            SUBSTRING(
                Date_clean,
                REGEXP_INSTR(Date_clean, '[0-9]{4}'),
                4
            ) AS UNSIGNED
        )
        ELSE NULL
    END;


ALTER TABLE artworks_raw
MODIFY COLUMN BeginDate_clean INT;

ALTER TABLE artworks_raw
MODIFY COLUMN EndDate_clean INT;


-- Create copy of nationality column to clean


ALTER TABLE artworks_raw
ADD COLUMN Nationality_clean TEXT;


-- Copy original


UPDATE artworks_raw
SET Nationality_clean = Nationality;


-- Remove extra ()


UPDATE artworks_raw
SET Nationality_clean = TRIM(
REPLACE(Nationality_clean, '()', '')
);


-- Remove everything after that first )


UPDATE artworks_raw
SET Nationality_clean = LEFT(
Nationality_clean,
LOCATE(')', Nationality_clean)
);


-- Replace unknown nationality to null


UPDATE artworks_raw
SET Nationality_clean = NULL
WHERE Nationality_clean = '(Nationality unknown)';


-- Remove brackets ( _ )


UPDATE artworks_raw
SET Nationality_clean = REPLACE(
    REPLACE(Nationality_clean, '(', ''),
    ')', ''
);


-- Clean gender column


ALTER TABLE artworks_raw
ADD COLUMN Gender_clean TEXT;


-- Copy original


UPDATE artworks_raw
SET Gender_clean = Gender;


-- Remove extra ()


UPDATE artworks_raw
SET Nationality_clean = TRIM(
REPLACE(Nationality_clean, '()', '')
);


-- Keep everything from the start up to that first )


UPDATE artworks_raw
SET Gender_clean = LEFT(
Gender_clean,
LOCATE(')', Gender_clean)
);


-- Standardise

UPDATE artworks_raw
SET Gender_clean = '(transgender woman)'
WHERE Gender_clean = '(female (transwoman)';


-- Remove ( _ )


UPDATE artworks_raw
SET Gender_clean = TRIM(
    REPLACE(
        REPLACE(Gender_clean, '(', ''),
        ')', '')
);


-- Capitalise first letter


UPDATE artworks_raw
SET Gender_clean = CASE 
    WHEN LOWER(Gender_clean) LIKE 'm%' THEN 'Male'
    WHEN LOWER(Gender_clean) LIKE 'f%' THEN 'Female'
    WHEN LOWER(Gender_clean) LIKE 'n%' THEN 'Non-binary'
    WHEN LOWER(Gender_clean) LIKE 't%' THEN 'Transgender woman'
    WHEN LOWER(Gender_clean) LIKE 'g%' THEN 'Gender non-conforming'
    ELSE Gender_clean -- Leave it alone if it's something else
END
WHERE Gender_clean IS NOT NULL;


-- Empty strings to null

UPDATE artworks_raw
SET Gender_clean = NULL
WHERE Gender_clean = '';



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


-- Create table to handle multiple artists per artwork


CREATE TABLE artwork_artists (
  ObjectID INT,
  ConstituentID INT
);


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


-- Prevent duplicate artwork to artist relationships


ALTER TABLE artwork_artists
ADD PRIMARY KEY (ObjectID, ConstituentID);


/*

Create OnView Tables to store only the artworks currently on view

*/


CREATE TABLE onview_artworks AS
SELECT
  ObjectID,
  Title,
  ConstituentID,
  Date,
  Medium,
  Dimensions,
  Classification,
  Department,
  DateAcquired,
  URL,
  ImageURL,
  OnView
FROM artworks_raw
WHERE OnView IS NOT NULL;


ALTER TABLE onview_artworks
ADD PRIMARY KEY (ObjectID);


-- Table that links artists to artworks currently on view


CREATE TABLE onview_artists AS
SELECT DISTINCT
  artists_raw.ConstituentID,
  artists_raw.DisplayName,
  artists_raw.ArtistBio,
  artists_raw.Nationality,
  artists_raw.Gender,
  artists_raw.BeginDate,
  artists_raw.EndDate
FROM artists_raw
JOIN artwork_artists
  ON artists_raw.ConstituentID = artwork_artists.ConstituentID
JOIN onview_artworks
  ON artwork_artists.ObjectID = onview_artworks.ObjectID;


ALTER TABLE onview_artists
ADD PRIMARY KEY (ConstituentID);



