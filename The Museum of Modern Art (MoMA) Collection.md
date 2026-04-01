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

