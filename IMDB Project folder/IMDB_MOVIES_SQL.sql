USE project_movie_database;

SHOW TABLES;

DESCRIBE movies;
DESCRIBE directors;

SELECT COUNT(*) AS total_movies FROM movies;
SELECT COUNT(*) AS total_directors FROM directors;


-- 1. Get all movie data
SELECT *
FROM movies;

-- 2. Get all director data
SELECT *
FROM directors;

-- 3. Count movies
SELECT COUNT(*) AS total_movies
FROM movies;

-- 4. Find James Cameron, Luc Besson, and John Woo
SELECT id, name, gender, department
FROM directors
WHERE name IN ('James Cameron', 'Luc Besson', 'John Woo');

-- 5. Find directors whose names start with S
SELECT id, name, gender, department
FROM directors
WHERE name LIKE 'S%'
ORDER BY name;

-- 6. Count female directors
-- The brief defines gender code 1 as female
SELECT COUNT(*) AS female_director_count
FROM directors
WHERE gender = 1;

-- 7. Tenth female director, ordered by director ID
SELECT id, name
FROM directors
WHERE gender = 1
ORDER BY id
LIMIT 1 OFFSET 9;

-- Optional alternative: tenth female director alphabetically
SELECT id, name
FROM directors
WHERE gender = 1
ORDER BY name, id
LIMIT 1 OFFSET 9;

-- 8. Three most popular movies
SELECT title, popularity, release_date
FROM movies
ORDER BY popularity DESC
LIMIT 3;

-- 9. Three most bankable movies
-- Here, bankable means highest revenue; revenue is not profit
SELECT title, budget, revenue, release_date
FROM movies
ORDER BY revenue DESC
LIMIT 3;

-- 10. Highest-rated movie released since January 1, 2000
SELECT title, vote_average, vote_count, release_date
FROM movies
WHERE STR_TO_DATE(release_date, '%Y-%m-%d') >= '2000-01-01'
ORDER BY vote_average DESC, vote_count DESC
LIMIT 1;

-- If "most awarded average vote" means most votes, use this version
SELECT title, vote_average, vote_count, release_date
FROM movies
WHERE STR_TO_DATE(release_date, '%Y-%m-%d') >= '2000-01-01'
ORDER BY vote_count DESC, vote_average DESC
LIMIT 1;

-- 11. Movies directed by Brenda Chapman
SELECT m.title, m.release_date, m.revenue
FROM movies AS m
JOIN directors AS d ON d.id = m.director_id
WHERE d.name = 'Brenda Chapman';

-- 12. Director or directors with the most movies
-- This version returns ties and works without CTE syntax
SELECT d.id, d.name, mc.movies_made
FROM (
    SELECT director_id, COUNT(*) AS movies_made
    FROM movies
    WHERE director_id IS NOT NULL
    GROUP BY director_id
) AS mc
JOIN directors AS d ON d.id = mc.director_id
WHERE mc.movies_made = (
    SELECT MAX(counts.movies_made)
    FROM (
        SELECT COUNT(*) AS movies_made
        FROM movies
        WHERE director_id IS NOT NULL
        GROUP BY director_id
    ) AS counts
)
ORDER BY d.name;

-- 13. Most bankable director by total movie revenue
SELECT d.id, d.name, dr.total_revenue
FROM (
    SELECT director_id, SUM(COALESCE(revenue, 0)) AS total_revenue
    FROM movies
    WHERE director_id IS NOT NULL
    GROUP BY director_id
) AS dr
JOIN directors AS d ON d.id = dr.director_id
WHERE dr.total_revenue = (
    SELECT MAX(revenues.total_revenue)
    FROM (
        SELECT SUM(COALESCE(revenue, 0)) AS total_revenue
        FROM movies
        WHERE director_id IS NOT NULL
        GROUP BY director_id
    ) AS revenues
)
ORDER BY d.name;