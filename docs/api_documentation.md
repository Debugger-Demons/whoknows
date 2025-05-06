# WhoKnows API Documentation

## Overview

The WhoKnows API provides access to the core functionality of the WhoKnows platform. This documentation outlines the available endpoints for authentication and search.

further details [backend API documentation](../backend/docs/api.md)

## Base URL

All API endpoints are relative to:

```
http://localhost:8080/api
```

## Authentication

All protected routes require a valid session cookie that is set upon successful login.

## Endpoints

### Authentication

#### Register

```
POST /auth/register
```

Registers a new user account.

**Request Body**

```json
{
  "username": "johndoe",
  "email": "john.doe@example.com",
  "password": "secure_password123"
}
```

**Response**

```json
{
  "success": true,
  "message": "User registered successfully"
}
```

#### Login

```
POST /auth/login
```

Authenticates a user and creates a session.

**Request Body**

```json
{
  "username": "johndoe",
  "password": "secure_password123"
}
```

**Response**

```json
{
  "success": true,
  "message": "Login successful",
  "user": {
    "id": 1,
    "username": "johndoe",
    "email": "john.doe@example.com"
  }
}
```

#### Logout

```
POST /auth/logout
```

Ends the current user session.

**Response**

```json
{
  "message": "Logout successful"
}
```

### Search

#### Search Pages

```
GET /search
```

Searches for pages based on query text.

**Query Parameters**

| Parameter | Type | Description |
|-----------|------|-------------|
| `q` | string | The search query text |
| `lang` | string | Optional language filter (en, da) |
| `limit` | integer | Maximum number of results (default: 20) |
| `offset` | integer | Number of results to skip (default: 0) |

**Response**

```json
{
  "search_results": [
    {
      "title": "Introduction to Search",
      "url": "https://example.com/search-intro",
      "language": "en",
      "last_updated": "2023-11-15T10:30:45Z",
      "content": "The full content of the page that matches the search..."
    },
    {
      "title": "Advanced Search Techniques",
      "url": "https://example.com/advanced-search",
      "language": "en",
      "last_updated": "2023-10-20T14:25:30Z",
      "content": "Another page's full content that matches the search query..."
    }
  ]
}
```

#### Get Page

```
GET /pages/{title}
```

Retrieves the full content of a specific page.

**Path Parameters**

| Parameter | Type | Description |
|-----------|------|-------------|
| `title` | string | The title of the page to retrieve |

**Response**

```json
{
  "title": "Introduction to Search",
  "url": "https://example.com/search-intro",
  "language": "en",
  "last_updated": "2023-11-15T10:30:45Z",
  "content": "The full content of the page..."
}
```

## Error Responses

All endpoints follow a consistent error response format:

```json
{
  "error": "Error message describing what went wrong"
}
```

Common error codes include:
- `INVALID_CREDENTIALS`: Username or password is incorrect
- `USER_EXISTS`: Username or email already exists
- `NOT_FOUND`: Requested resource not found
- `UNAUTHORIZED`: Authentication required
- `VALIDATION_ERROR`: Request data failed validation 