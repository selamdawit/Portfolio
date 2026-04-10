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

