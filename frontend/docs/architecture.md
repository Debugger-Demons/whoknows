# Frontend Architecture

## Overview
The frontend service is built with Rust using the Actix web framework. It serves as a lightweight web server for the "Who Knows" search engine frontend, handling static files and API proxying.

## High-Level Architecture

```
┌─────────────┐      ┌──────────────┐      ┌──────────────┐
│  Browser    │◄────►│  Frontend    │◄────►│  Backend     │
│  (Client)   │      │  (Actix Web) │      │  (API)       │
└─────────────┘      └──────────────┘      └──────────────┘
      │                      │                    │
      │                      │                    │
 HTTP/HTTPS           Internal Network      Database Access
```

## Core Components

### Web Server (Actix)
- **Role**: Serves static files and proxies API requests
- **Key Features**:
  - Static file serving for HTML, CSS, JavaScript
  - API request proxying to the backend service
  - CORS configuration
  - Logging middleware

### API Proxy Middleware
- **Purpose**: Intercepts API requests and forwards them to the backend
- **Implementation**: Custom Actix middleware (`ApiProxy`)
- **Flow**:
  1. Intercepts requests starting with `/api/`
  2. Forwards them to the backend service
  3. Returns backend responses to the client

### Static Files
- **Structure**:
  - `/static/html/`: HTML templates for pages
  - `/static/js/`: JavaScript for client-side functionality
  - `/static/css/`: Styling for the application
  - `/static/assets/`: Images and other assets

### JavaScript API Client
- **File**: `static/js/api.js`
- **Purpose**: Provides client-side API interaction
- **Features**:
  - Search functionality
  - User authentication (login/logout)
  - User registration
  - Error handling

## Request Flow

1. **Static Content Request**:
   - Browser requests HTML, CSS, or JavaScript
   - Actix serves files directly from the `/static` directory

2. **API Request**:
   - Browser makes AJAX request to `/api/*` endpoint
   - `ApiProxy` middleware intercepts the request
   - Request is forwarded to backend service
   - Backend response is returned to the browser

## Docker Integration

```
┌────────────────────────────────────────────┐
│ Docker Network                             │
│                                            │
│  ┌──────────────┐      ┌──────────────┐    │
│  │  Frontend    │      │  Backend     │    │
│  │  Container   │─────►│  Container   │    │
│  │              │      │              │    │
│  └──────────────┘      └──────────────┘    │
│        ▲                                   │
└────────┼───────────────────────────────────┘
         │
     Port 8080
         │
┌────────┼───────────────────────────────────┐
│        │                                   │
│  ┌─────▼──────┐                            │
│  │  Browser   │                            │
│  │  (Client)  │                            │
│  └────────────┘                            │
│                                            │
└────────────────────────────────────────────┘
```

- **Frontend Container**: Exposes port 8080 to the host
- **Backend Container**: Only accessible within Docker network
- **Service Discovery**: Containers communicate using service names as hostnames 