-- database/migrations/0001_initial_schema.sql

-- Use PRAGMA for foreign keys if needed (good practice)
-- PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT NOT NULL UNIQUE,
  email TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL -- Store hashed passwords! MD5 is insecure. Use bcrypt/argon2.
);

-- Create a default user, The password is 'password' (MD5 hashed - CONSIDER A STRONGER HASH)
-- INSERT OR IGNORE prevents errors if the user already exists (useful for repeatable migrations)
INSERT OR IGNORE INTO users (id, username, email, password)
    VALUES (1, 'admin', 'keamonk1@stud.kea.dk', '5f4dcc3b5aa765d61d8327deb882cf99');


CREATE TABLE IF NOT EXISTS pages (
    title TEXT PRIMARY KEY UNIQUE,
    url TEXT NOT NULL UNIQUE,
    language TEXT NOT NULL CHECK(language IN ('en', 'da')) DEFAULT 'en',
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Set default on creation
    content TEXT NOT NULL
);

-- Optional: Trigger to update last_updated timestamp automatically
CREATE TRIGGER IF NOT EXISTS update_pages_last_updated
AFTER UPDATE ON pages
FOR EACH ROW
BEGIN
    UPDATE pages SET last_updated = CURRENT_TIMESTAMP WHERE title = OLD.title;
END;