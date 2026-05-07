# Hospital Patient Record Analysis 🏥

<p align="center">
  <img src="https://github.com/selamdawit/Portfolio/blob/91b8ae286eaddaebd08ac6aad259cd66e2ab2355/Hospital%20Patient%20Records/dr.jpg" width="100%" height="250" />
</p>

## Objective
To analyze hospital patient and encounter data to understand patient demographics, healthcare usage, costs, and geographic distribution.
<br>
## Solution 

### 1. How many patients are in the dataset?

````sql
SELECT 
  COUNT(DISTINCT Id) AS total_patients
FROM patients_raw;
````

**Answer:**

<img width="191" height="78" alt="Image" src="https://github.com/user-attachments/assets/7d8717c1-0b9e-4f76-861a-4d0e136010e5" />

<br>
<br>
There are 974 unique patients in the dataset.
<br>
<br>

### 2. How many encounters are in the encounters table?

````sql
SELECT COUNT(*) AS total_encounters
FROM encounters_raw;
````

**Answer:**


<br>
<br>

### 3. What is the average age of patients?

````sql
SELECT ROUND(AVG(YEAR(CURDATE()) - YEAR(BIRTHDATE))) AS average_patient_age
FROM patients_raw;
````

**Answer:**

<img width="155" height="76" alt="Image" src="https://github.com/user-attachments/assets/46de6f05-27b0-4874-b41d-3c17ef4883a0" />

<br>
<br>
The average patient age in this dataset is 74 years old.
<br>
<br>

### 4. What is the age structure of the patient population?

````sql
SELECT 
CASE 
    WHEN (2026 - YEAR(BIRTHDATE)) < 18 THEN 'Under 18'
    WHEN (2026 - YEAR(BIRTHDATE)) <= 40 THEN '18-40'
    WHEN (2026 - YEAR(BIRTHDATE)) <= 65 THEN '41-65'
    ELSE '65+'
END AS age_group,
COUNT(*) AS total
FROM patients_raw
GROUP BY age_group;
````

**Answer:**

<img width="225" height="107" alt="Image" src="https://github.com/user-attachments/assets/74935124-31ed-418d-a076-8d9de3f0a258" />

<br>
<br>
The majority of patients are aged 65+, with 629 individuals in this group.
<br>
<br>


### 5. How diverse is the patient population by race?

````sql
SELECT 
  RACE,
  COUNT(*) AS total,
  ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM patients_raw), 2) AS percentage
FROM patients_raw
GROUP BY RACE
ORDER BY total DESC;
````

**Answer:**

<img width="264" height="154" alt="Image" src="https://github.com/user-attachments/assets/2bbc64b1-629b-4925-a154-65dc24728098" />

<br>
<br>
White patients dominate the dataset at 69.82%, while all other racial groups each represent less than 20%.
<br>
<br>


### 6. What is the gender balance of patients?

````sql
SELECT 
  GENDER,
  COUNT(*) AS total,
  ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM patients_raw), 2) AS percentage
FROM patients_raw
GROUP BY GENDER;
````

**Answer:**

<img width="372" height="91" alt="Image" src="https://github.com/user-attachments/assets/0ba473dd-1422-4bdb-a24b-9f6f1cd6a70b" />

<br>
<br>
The dataset is evenly split by gender, with a slight majority of male patients.
<br>
<br>


### 7. Are there missing critical patient records?

````sql
SELECT COUNT(*) AS missing_ID
FROM patients_raw
WHERE Id IS NULL OR BIRTHDATE IS NULL;
````

**Answer:**

<img width="160" height="74" alt="Image" src="https://github.com/user-attachments/assets/d6a93967-9af6-4508-b22d-4fe681b6d23b" />

<br>
<br>
There are no missing patient IDs in the dataset.
<br>
<br>


### 8. How often do patients use healthcare services?
#### a. What is the average of patient encounters?

````sql
SELECT  
ROUND(AVG(encounter_count), 1) AS avg_encounters  
FROM (  
  SELECT COUNT(*) AS encounter_count  
  FROM encounters_raw  
  GROUP BY PATIENT  
) counts;
````

**Answer:**

<img width="135" height="82" alt="Image" src="https://github.com/user-attachments/assets/6dc48c83-4c3b-47ae-9cd1-05e5c69b876a" />

<br>
<br>
On average, each patient has 28.6 healthcare encounters, indicating frequent service usage.
<br>
<br>


#### b. How often do patients use healthcare services?

````sql
SELECT 
  PATIENT,
  COUNT(*) AS encounter_count
FROM encounters_raw
GROUP BY PATIENT
ORDER BY encounter_count DESC
LIMIT 10;
````

**Answer:**

<img width="505" height="204" alt="Image" src="https://github.com/user-attachments/assets/f8c922ef-d6f5-45b6-b108-30654ecfa886" />

<br>
<br>
While the average is 28.6 encounters per patient, some patients have over 1,300 encounters, indicating highly uneven usage.
<br>
<br>


### 9. What types of care are most commonly delivered?

````sql
SELECT 
  ENCOUNTERCLASS,
  COUNT(*) AS total,
  ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM encounters_raw), 2) AS percentage
FROM encounters_raw
GROUP BY ENCOUNTERCLASS
ORDER BY total DESC;
````

**Answer:**

<img width="325" height="151" alt="Image" src="https://github.com/user-attachments/assets/54319be9-b1c2-41a9-abb8-bb67cf6b836e" />

<br>
<br>
Ambulatory and outpatient encounters together make up over 67% of all healthcare visits.
<br>
<br>


### 10. What is the typical cost of an encounter?

````sql
SELECT 
  ROUND(AVG(TOTAL_CLAIM_COST),2) AS avg_cost
FROM encounters_raw;
````

**Answer:**

<img width="159" height="80" alt="Image" src="https://github.com/user-attachments/assets/778bd3fe-cb34-4376-9303-23426126068e" />

<br>
<br>
The average total claim cost per encounter is 3,639.68.
<br>
<br>


### 11. How much do patients pay themselves?

````sql
SELECT 
  ROUND(AVG(out_of_pocket_cost),2) AS avg_out_of_pocket
FROM encounters_raw;
````

**Answer:**

<img width="223" height="79" alt="Image" src="https://github.com/user-attachments/assets/3ddcf147-c7e3-46d6-9c94-f1ac61dbb66d" />

<br>
<br>
The average out of pocket cost per encounter, meaning the amount patients pay themselves, is 2,524.72.
<br>
<br>

### 12. What proportion of costs are covered by insurance?

````sql
SELECT 
  ROUND(AVG(PAYER_COVERAGE / TOTAL_CLAIM_COST) * 100, 2) AS coverage_pct
FROM encounters_raw
WHERE TOTAL_CLAIM_COST > 0;
````

**Answer:**

<img width="187" height="66" alt="Image" src="https://github.com/user-attachments/assets/4ede992f-1daa-43dd-9611-34237ddb1265" />

<br>
<br>
On average, payers cover 32.19% of the total claim cost per encounter.
<br>
<br>

### 13. Does healthcare usage vary by age group?

````sql
SELECT  
  CASE  
    WHEN 2026 - YEAR(BIRTHDATE) < 18 THEN 'Under 18'  
    WHEN 2026 - YEAR(BIRTHDATE) <= 40 THEN '18-40'  
    ELSE '40+'  
  END AS age_group,  
  COUNT(*) AS total_encounters  

FROM patients_raw
JOIN encounters_raw
  ON patients_raw.Id = encounters_raw.PATIENT  

GROUP BY age_group  
ORDER BY total_encounters DESC;
````

**Answer:**

<img width="210" height="95" alt="Image" src="https://github.com/user-attachments/assets/b1ea2550-fe7e-44ff-b897-5a319bf6631e" />

<br>
<br>
Patients aged 40 and over account for nearly all encounters at 26,690, showing that healthcare usage is heavily concentrated among older patients.
<br>
<br>

### 14. Which encounter types are the most expensive?

````sql
SELECT 
  ENCOUNTERCLASS,
  ROUND(AVG(TOTAL_CLAIM_COST),2) AS avg_cost
FROM encounters_raw
GROUP BY ENCOUNTERCLASS
ORDER BY avg_cost DESC;
````

**Answer:**

<img width="256" height="141" alt="Image" src="https://github.com/user-attachments/assets/39d6e401-0397-4413-b96b-7ed714b94469" />

<br>
<br>
Inpatient encounters have the highest average cost at 7,761.35, while outpatient encounters are the lowest at 2,237.30, showing that more intensive types of care drive significantly higher costs.
<br>
<br>

### 15. Where are most patients located?

````sql
SELECT 
  ZIP,
  COUNT(*) AS total_patients
FROM patients_raw
GROUP BY ZIP
ORDER BY total_patients DESC
LIMIT 10;
````

**Answer:**

<img width="203" height="201" alt="Image" src="https://github.com/user-attachments/assets/bc49c730-8e7a-4af1-89a9-8555a23d9cad" />

<br>
<br>
Location data is incomplete in the 'patients' dataset, with 142 patients missing ZIP codes, while the highest recorded ZIP 02151 (Revere, Massachusetts) has 41 patients, limiting accurate geographic analysis.

<br>
<br>

### 16. Which areas have the most encounters?

````sql
SELECT  
  patients_raw.ZIP,  
  COUNT(encounters_raw.Id) AS total_encounters  

FROM patients_raw  
JOIN encounters_raw  
  ON patients_raw.Id = encounters_raw.PATIENT  

GROUP BY patients_raw.ZIP  
ORDER BY total_encounters DESC  
LIMIT 10;
````

**Answer:**

<img width="215" height="199" alt="Image" src="https://github.com/user-attachments/assets/409b2fe3-0c22-46dd-b8f3-c36f6a3539d0" />

<br>
<br>
Missing ZIP codes account for the highest number of encounters at 3,709, while ZIP 02045 (Hull, Massachusetts) has the highest recorded count at 1,519, highlighting a significant gap in the 'encounters' dataset.
<br>
<br>
