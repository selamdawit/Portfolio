# MoMA Collection Analysis 🎨

## 📌 Solution

### 1. How many artworks are currently on display?

````sql
SELECT COUNT(*) AS total_onview_artworks
FROM onview_artworks;
````

**Answer:**

<img width="138" height="63" alt="Image" src="https://github.com/user-attachments/assets/a4a6f732-4cd6-4f79-8e29-95f2411669b5" />
<br>
<br>
There are 1,210 artworks currently on display at MoMA.

<br>
<br>

### 2. Which artists have the most artworks on display?

````sql
SELECT
  artists_raw.DisplayName,
  COUNT(*) AS total_artworks
FROM artwork_artists

JOIN onview_artworks
  ON artwork_artists.ObjectID = onview_artworks.ObjectID

JOIN artists_raw
  ON artwork_artists.ConstituentID = artists_raw.ConstituentID

GROUP BY artists_raw.DisplayName

ORDER BY total_artworks DESC
LIMIT 10;
````

**Answer:**

<img width="333" height="203" alt="Image" src="https://github.com/user-attachments/assets/09485435-240d-4e54-a5ba-dcd3f07a9a72" />
<br>
<br>
The artists with the most artworks on display are shown above.

<br>
<br>

### 3. Where are most artworks on view?

````sql
SELECT
  OnView,
  COUNT(*) AS total_artworks
FROM onview_artworks
GROUP BY OnView
ORDER BY total_artworks DESC;
````

**Answer:**

<img width="248" height="203" alt="Image" src="https://github.com/user-attachments/assets/4429607f-9826-4a5f-a82d-9b905a63169a" />
<br>
<br>
This shows which locations currently display the most artworks.

<br>
<br>

### 4. Which departments dominate the current display?

````sql
SELECT
  Department,
  COUNT(*) AS total_artworks,
  CONCAT(ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM onview_artworks)), '%') AS percentage
FROM onview_artworks
GROUP BY Department
ORDER BY total_artworks DESC;
````

**Answer:**

<img width="378" height="156" alt="Image" src="https://github.com/user-attachments/assets/3728de30-56ef-4f85-a787-577074a330fe" />
<br>
<br>
It shows both count and share
