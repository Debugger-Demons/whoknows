# API Proxy Middleware

## Overview
The API Proxy Middleware is a core component of the frontend service that allows seamless communication between the client's browser and the backend API. This document details how the middleware works, its implementation, and configuration options.

## Purpose
The proxy middleware solves several key challenges:

1. **Mixed Content Issues**: Prevents HTTPS/HTTP mixed content issues by serving all content from a single origin
2. **Network Isolation**: Keeps the backend service inaccessible directly from the internet
3. **Service Discovery**: Simplifies client-side code by using relative URLs for API calls
4. **Docker Integration**: Enables container-to-container communication in a Docker environment

## Implementation Details

### Middleware Architecture
The proxy middleware is implemented as a custom Actix Web middleware that:

1. Intercepts requests that start with `/api/`
2. Forwards these requests to the backend service
3. Returns the backend's response to the client

### Code Structure
The middleware consists of two main structs:
- `ApiProxy`: The middleware factory that creates new middleware instances
- `ApiProxyMiddleware`: The actual middleware that processes requests

### Request Flow
When a request is received:

1. The middleware checks if the request path starts with `/api/`
2. Special endpoints (`/api/health`, `/api/config`) are excluded from proxying
3. For API requests, the middleware:
   - Creates a new client request to the backend
   - Copies relevant headers from the original request
   - Forwards the request body
   - Waits for the backend response
   - Returns the backend response to the client
4. For non-API requests, the middleware passes the request to the next handler

## Configuration
The proxy middleware is configured with:

- **Backend URL**: The URL of the backend service (typically `http://backend:PORT`)
- **Port**: The backend service port (from environment variable `BACKEND_INTERNAL_PORT`)

## Example Implementation

```rust
// ApiProxy middleware implementation
struct ApiProxy {
    client: Client,
    backend_url: String,
}

impl ApiProxy {
    fn new(backend_url: String) -> Self {
        ApiProxy {
            client: Client::default(),
            backend_url,
        }
    }
}

// Usage in main.rs
let backend_port = env::var(BACKEND_INTERNAL_PORT_KEY).unwrap_or_else(|_| "92".to_string());
let backend_url = format!("http://backend:{}", backend_port);

// Add middleware to Actix app
App::new()
    .wrap(ApiProxy::new(backend_url.clone()))
    .service(health_check)
    // Other services...
```

## Header Management
The middleware carefully handles HTTP headers:

1. **Request Headers**: Copies headers from original request, excluding:
   - `Host`: Must match the backend service
   - `Connection`: Managed by the HTTP client
   - `Content-Length`: Recalculated for the forwarded request

2. **Response Headers**: Copies headers from backend response, excluding:
   - `Connection`: Managed by Actix
   - `Content-Length`: Recalculated for the client response

## Error Handling
The middleware includes robust error handling:

1. If the backend is unavailable, returns a 503 Service Unavailable response
2. For other errors, returns appropriate HTTP status codes
3. Logs errors with detailed information

## Docker Network Considerations
In a Docker environment:

1. The frontend container must be on the same network as the backend
2. Service discovery relies on Docker DNS resolution (service name as hostname)
3. Environment variables configure the backend port 