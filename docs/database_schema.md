# WhoKnows Database Schema

## Overview

This document describes the database schema for the WhoKnows application. The application uses a simple SQLite database with two main tables to support user authentication and search functionality.

## Database Technology

WhoKnows uses SQLite as its database engine, which is lightweight and easy to set up for development.

## Tables

### Users

Stores user account information for authentication.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | Unique identifier for the user |
| username | TEXT | NOT NULL, UNIQUE | User's username for login |
| email | TEXT | NOT NULL, UNIQUE | User's email address |
| password | TEXT | NOT NULL | Hashed password for authentication |

### Pages

Stores searchable page content.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| title | TEXT | PRIMARY KEY, UNIQUE | Page title |
| url | TEXT | NOT NULL, UNIQUE | URL of the page |
| language | TEXT | NOT NULL, CHECK(language IN ('en', 'da')) DEFAULT 'en' | Page language (English or Danish) |
| last_updated | TIMESTAMP | | When the page was last updated |
| content | TEXT | NOT NULL | Full text content of the page for searching |

## Relationships

This is a simple database structure with no explicit foreign key relationships between tables. The `users` table is used solely for authentication, while the `pages` table stores content that can be searched.

## Database File

The database is stored in a file named `whoknows.db` in the root project directory. For development environments, this file is created automatically when the application is first run. 