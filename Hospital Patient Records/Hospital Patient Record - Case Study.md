# Hospital Patient Record Analysis 🏥

## 📌 Solution

### 1. How many patients are in the dataset?

````sql
SELECT 
  COUNT(DISTINCT Id) AS total_patients
FROM patients_raw;
````



