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
There are 55 artworks on display by Robert Frank, making him the artist with the most artworks currently exhibited.

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
There are 128 pieces in the MoMA, Floor 3, 3 East gallery, which has the highest number of artworks on view.

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
Painting and Sculpture dominates the current display with 466 artworks (39%), followed by drawings and prints with 278 artworks (23%) and photography with 230 (19%).

<br>
<br>

### 5. How concentrated is the display among a small number of artists?

````sql
SELECT
  artist_totals.total_artworks,
  COUNT(*) AS number_of_artists
FROM (

  SELECT
    artwork_artists.ConstituentID,
    COUNT(DISTINCT artwork_artists.ObjectID) AS total_artworks
  FROM artwork_artists
  JOIN onview_artworks
    ON artwork_artists.ObjectID = onview_artworks.ObjectID
  GROUP BY artwork_artists.ConstituentID
)

AS artist_totals
GROUP BY artist_totals.total_artworks
ORDER BY artist_totals.total_artworks DESC;
````

**Answer:**

<img width="331" height="351" alt="Image" src="https://github.com/user-attachments/assets/693e2c3f-a219-41bb-a0de-63d4e0a4564f" />
<br>
<br>
Most artists have only one artwork on display (474 artists). The collection is widely distributed across many artists, rather than being dominated by a small number of artists.

<br>
<br>

### 6. Which artworks are collaborations?

````sql
SELECT
  onview_artworks.ObjectID,
  onview_artworks.Title,
  COUNT(*) AS artist_count
FROM artwork_artists
JOIN onview_artworks
  ON artwork_artists.ObjectID = onview_artworks.ObjectID
GROUP BY onview_artworks.ObjectID, onview_artworks.Title
HAVING COUNT(*) > 1
ORDER BY artist_count DESC, onview_artworks.Title
LIMIT 10;
````

**Answer:**

<img width="626" height="191" alt="Image" src="https://github.com/user-attachments/assets/421288ae-c14a-4bdd-9a99-8ef195780d55" />
<br>
<br>
This is a limited list of 10 collaborative artworks, where “Long Distance” stands out with 132 artists involved.

<br>
<br>

**Follow up : How many artworks on display are collaborations?**

````sql
SELECT COUNT(*) AS total_collab_artworks
FROM (
  SELECT
    onview_artworks.ObjectID
  FROM artwork_artists
  JOIN onview_artworks
    ON artwork_artists.ObjectID = onview_artworks.ObjectID
  GROUP BY onview_artworks.ObjectID
  HAVING COUNT(*) > 1
) AS collaborations;
````

**Answer:**

<img width="166" height="83" alt="Image" src="https://github.com/user-attachments/assets/42731a9d-0a13-4d37-9c30-0b7c447dd220" />
<br>
<br>
There are 54 collaborative artworks in total, which is about 4% of the 1,210 artworks on display.

<br>
<br>

### 7. What is the gender representation of artists currently on view?

````sql
SELECT COUNT(DISTINCT artwork_artists.ConstituentID) AS total_artists
FROM artwork_artists
JOIN onview_artworks
  ON artwork_artists.ObjectID = onview_artworks.ObjectID;
````

````sql
SELECT
  artists_raw.Gender,
  COUNT(DISTINCT artists_raw.ConstituentID) AS total_artists
FROM artwork_artists
JOIN onview_artworks
  ON artwork_artists.ObjectID = onview_artworks.ObjectID
JOIN artists_raw
  ON artwork_artists.ConstituentID = artists_raw.ConstituentID
GROUP BY artists_raw.Gender;
````

**Answer:**
