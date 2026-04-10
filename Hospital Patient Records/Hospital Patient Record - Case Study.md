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

### 2. What is the average age of patients?

````sql
SELECT ROUND(AVG(YEAR(CURDATE()) - YEAR(BIRTHDATE))) AS average_patient_age
FROM patients_raw;
````

**Answer:**
