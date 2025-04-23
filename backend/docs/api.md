# API Documentation

## Overview
This document details the RESTful API endpoints exposed by the backend service.

## Authentication Endpoints

### Login
- **URL**: `/api/login`
- **Method**: `POST`
- **Request Body**:
  ```json
  {
    "username": "string",
    "password": "string"
  }
  ```
- **Success Response**:
  - **Code**: 200 OK
  - **Content**:
    ```json
    {
      "success": true,
      "message": "Login successful",
      "user": {
        "id": 1,
        "username": "example",
        "email": "user@example.com"
      }
    }
    ```
- **Error Responses**:
  - **Code**: 400 Bad Request (Empty fields)
  - **Code**: 401 Unauthorized (Invalid credentials)
  - **Code**: 500 Internal Server Error

### Logout
- **URL**: `/api/logout`
- **Method**: `GET`
- **Success Response**:
  - **Code**: 200 OK
  - **Content**:
    ```json
    {
      "message": "Logout successful"
    }
    ```

### Register
- **URL**: `/api/register`
- **Method**: `POST`
- **Request Body**:
  ```json
  {
    "username": "string",
    "email": "string",
    "password": "string",
    "password2": "string"
  }
  ```
- **Success Response**:
  - **Code**: 200 OK
  - **Content**:
    ```json
    {
      "success": true,
      "message": "Registration successful"
    }
    ```
- **Error Responses**:
  - **Code**: 400 Bad Request (Validation errors)
  - **Code**: 409 Conflict (Username already exists)
  - **Code**: 500 Internal Server Error

## Data Endpoints

### Search
- **URL**: `/api/search`
- **Method**: `GET`
- **Query Parameters**:
  - `q`: Search query (optional)
  - `language`: Filter by language (optional)
- **Success Response**:
  - **Code**: 200 OK
  - **Content**:
    ```json
    {
      "results": [
        {
          "title": "Example Page",
          "url": "https://example.com",
          "language": "en",
          "last_updated": "2023-01-01T12:00:00Z",
          "content": "Example content..."
        }
      ]
    }
    ```

## System Endpoints

### Health Check
- **URL**: `/`
- **Method**: `GET`
- **Success Response**:
  - **Code**: 200 OK
  - **Content**: "Hello from Actix Backend!"

### Configuration
- **URL**: `/config`
- **Method**: `GET`
- **Success Response**:
  - **Code**: 200 OK
  - **Content**:
    ```json
    {
      "db_url": "string",
      "port": "string",
      "environment": "string",
      "build_version": "string"
    }
    ``` 