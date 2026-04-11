# Hospital Patient Record Analysis 🏥

## 📌 Solution

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
There are 974 patients in the dataset.
<br>
<br>

### 2. What is the average age of patients?

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

### 3. What is the age structure of the patient population?

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
N/A
<br>
<br>


### 4. How diverse is the patient population by race?

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
N/A
<br>
<br>


### 5. What is the gender balance of patients?

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
N/A
<br>
<br>


### 6. Are there missing critical patient records?

````sql
SELECT COUNT(*) AS missing_ID
FROM patients_raw
WHERE Id IS NULL OR BIRTHDATE IS NULL;
````

**Answer:**

<img width="160" height="74" alt="Image" src="https://github.com/user-attachments/assets/d6a93967-9af6-4508-b22d-4fe681b6d23b" />

<br>
<br>
N/A
<br>
<br>


### 7. How often do patients use healthcare services?
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
N/A
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
N/A
<br>
<br>


### 8. What types of care are most commonly delivered?

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
N/A
<br>
<br>


### 9. What is the typical cost of an encounter?

````sql
SELECT 
  ROUND(AVG(TOTAL_CLAIM_COST),2) AS avg_cost
FROM encounters_raw;
````

**Answer:**

<img width="159" height="80" alt="Image" src="https://github.com/user-attachments/assets/778bd3fe-cb34-4376-9303-23426126068e" />

<br>
<br>
N/A
<br>
<br>


### 10. How much do patients pay themselves?

````sql
SELECT 
  ROUND(AVG(out_of_pocket_cost),2) AS avg_out_of_pocket
FROM encounters_raw;
````

**Answer:**

<img width="223" height="79" alt="Image" src="https://github.com/user-attachments/assets/3ddcf147-c7e3-46d6-9c94-f1ac61dbb66d" />

<br>
<br>
N/A
<br>
<br>

### 11. What proportion of costs are covered by insurance?

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
N/A
<br>
<br>

### 12. Does healthcare usage vary by age group?

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
Patients aged 40+ have the highest number of encounters, indicating that older patients use healthcare services more frequently.
<br>
<br>

### 13. Which encounter types are the most expensive?

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
N/A
<br>
<br>

### 14. Where are most patients located?

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
N/A
<br>
<br>

### 15. Which areas have the most encounters?

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
