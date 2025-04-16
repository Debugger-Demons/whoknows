use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::FromRow; // To derive mapping from database rows

#[derive(Serialize, Deserialize, FromRow, Debug, Clone)] // Added Debug and Clone for convenience
pub struct User {
    pub id: i64,
    pub username: String,
    pub email: String,
    // We select the password hash, but might not always want to serialize/send it
    // Be careful about exposing password hashes in API responses!
    pub password: String,
}

#[derive(Serialize, Deserialize, FromRow, Debug, Clone)] // Added Debug and Clone
pub struct Page {
    // These must match the column names in schema.sql
    pub title: String,
    pub url: String,
    pub language: String,
    // Use Option<> if the database column can be NULL
    pub last_updated: Option<DateTime<Utc>>,
    pub content: String,
}
