-- Hapus Tabel Dimensi yang Sudah Ada beserta Ketergantungan
DROP TABLE IF EXISTS dim_user CASCADE;
DROP TABLE IF EXISTS dim_post CASCADE;
DROP TABLE IF EXISTS dim_date CASCADE;


--soal1
-- Create Dimension Tables
-- Dimension Table for Users
CREATE TABLE dim_user (
    user_id INTEGER PRIMARY KEY,
    user_name TEXT,
    country TEXT
);

-- Dimension Table for Posts
CREATE TABLE dim_post (
    post_id INTEGER PRIMARY KEY,
    post_text TEXT,
    post_date DATE
);

-- Dimension Table for Dates
CREATE TABLE dim_date (
    date_id SERIAL PRIMARY KEY,
    date_value DATE UNIQUE
);

--soal2
-- Populate Dimension Tables
-- Populate dim_user from raw_users
INSERT INTO dim_user (user_id, user_name, country)
SELECT user_id, user_name, country
FROM raw_users
WHERE user_id NOT IN (SELECT user_id FROM dim_user)
ON CONFLICT (user_id) DO NOTHING;

-- Populate dim_post from raw_posts
INSERT INTO dim_post (post_id, post_text, post_date)
SELECT post_id, post_text, post_date
FROM raw_posts
WHERE post_id NOT IN (SELECT post_id FROM dim_post)
ON CONFLICT (post_id) DO NOTHING;

-- Populate dim_date from raw_posts
INSERT INTO dim_date (date_value)
SELECT DISTINCT post_date
FROM raw_posts
WHERE post_date NOT IN (SELECT date_value FROM dim_date)
ON CONFLICT (date_value) DO NOTHING;


-- soal3
CREATE TABLE fact_post_performance (
    performance_id INTEGER PRIMARY KEY,
    post_id INTEGER REFERENCES dim_post(post_id),
    user_id INTEGER REFERENCES dim_user(user_id),
    date_id INTEGER REFERENCES dim_date(date_id),
    views_count INTEGER,
    likes_count INTEGER
);

--soal4
INSERT INTO fact_post_performance (post_id, user_id, date_id, views_count, likes_count)
SELECT
    p.post_id,
    u.user_id,
    d.date_id,
    COUNT(DISTINCT v.user_id) AS views_count,
    COUNT(DISTINCT l.like_id) AS likes_count
FROM
    dim_post p
JOIN
    dim_user u ON p.user_id = u.user_id
JOIN
    dim_date d ON p.post_date = d.date_value
LEFT JOIN
    raw_likes l ON p.post_id = l.post_id
LEFT JOIN
    raw_views v ON p.post_id = v.post_id
GROUP BY
    p.post_id, u.user_id, d.date_id;





--soal5
CREATE TABLE fact_daily_posts (
    daily_post_id INTEGER PRIMARY KEY,
    user_id INTEGER REFERENCES dim_user(user_id),
    date_id INTEGER REFERENCES dim_date(date_id),
    posts_count INTEGER
);

--soal6
INSERT INTO fact_daily_posts (user_id, date_id, posts_count)
SELECT
    u.user_id,
    d.date_id,
    COUNT(DISTINCT p.post_id) AS posts_count
FROM
    dim_user u
CROSS JOIN
    dim_date d
LEFT JOIN
    dim_post p ON u.user_id = p.user_id AND p.post_date = d.date_value
GROUP BY
    u.user_id, d.date_id;





