DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS pages;

CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(255) NOT NULL UNIQUE,
  email VARCHAR(255) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL
);

-- Create a default user, The password is 'password' (MD5 hashed)
INSERT INTO users (username, email, password) 
    VALUES ('admin', 'keamonk1@stud.kea.dk', '5f4dcc3b5aa765d61d8327deb882cf99');


CREATE TABLE IF NOT EXISTS pages (
    title VARCHAR(255) PRIMARY KEY,
    url VARCHAR(255) NOT NULL UNIQUE,
    language VARCHAR(2) NOT NULL DEFAULT 'en' CHECK(language IN ('en', 'da')),
    last_updated TIMESTAMP,
    content TEXT NOT NULL
);