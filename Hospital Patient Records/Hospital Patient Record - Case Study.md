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

### 3.What is the age structure of the patient population?

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

