# Rust Security Checklist for Actix Web

This checklist outlines specific security considerations for your Rust/Actix Web application. Use this as a guide to harden your backend application against common security vulnerabilities.

## Dependencies Management

- [ ] Use `cargo audit` regularly to check for vulnerable dependencies
- [ ] Pin dependency versions precisely to prevent unexpected updates
- [ ] Minimize dependency count to reduce attack surface
- [ ] Verify licenses of all dependencies using `cargo deny`
- [ ] Monitor Rust Security Advisories (https://rustsec.org)

## Input Validation & Sanitization

- [ ] Validate all request parameters (path, query, body)
- [ ] Implement strict type checking with proper error handling
- [ ] Use Serde's validation capabilities for complex inputs
- [ ] Sanitize inputs before processing (especially for database operations)
- [ ] Avoid using `unsafe` blocks unless absolutely necessary

## Authentication & Authorization

- [ ] Implement proper JWT validation (check signature, expiration, claims)
- [ ] Use strong password hashing (Argon2id recommended)
- [ ] Implement rate limiting for authentication endpoints
- [ ] Enforce proper authorization checks on all routes
- [ ] Use middleware to enforce authentication consistently

Example for JWT middleware in Actix Web:

```rust
use actix_web::{dev::ServiceRequest, Error};
use actix_web_httpauth::extractors::bearer::BearerAuth;

async fn validator(req: ServiceRequest, credentials: BearerAuth) -> Result<ServiceRequest, Error> {
    // Validate JWT token
    let token = credentials.token();

    // Your validation logic here
    // ...

    Ok(req)
}
```

## Database Security

- [ ] Use parameterized queries or ORM to prevent SQL injection
- [ ] Implement database connection pooling with proper limits
- [ ] Use least privilege principle for database accounts
- [ ] Encrypt sensitive data at rest
- [ ] Validate and sanitize all database inputs

Example with SQLx:

```rust
// Good: Parameterized query
let user = sqlx::query_as!(User,
    "SELECT * FROM users WHERE username = $1",
    username
).fetch_one(&pool).await?;

// Bad: String interpolation (SQL Injection risk)
// let user = sqlx::query_as!(User,
//    "SELECT * FROM users WHERE username = '{}'",
//    username
// ).fetch_one(&pool).await?;
```

## Error Handling & Logging

- [ ] Implement custom error types that don't leak sensitive information
- [ ] Use proper error logging with appropriate detail levels
- [ ] Configure structured logging (JSON format) for production
- [ ] Avoid exposing stack traces to users
- [ ] Implement centralized error handling

Example of secure error handling:

```rust
#[derive(Debug, thiserror::Error)]
pub enum ApiError {
    #[error("Authentication required")]
    Unauthorized,

    #[error("Not allowed to access this resource")]
    Forbidden,

    #[error("Resource not found")]
    NotFound,

    #[error("Internal server error")]
    InternalError, // Public message doesn't leak details

    #[error("Database error: {0}")]
    DatabaseError(#[from] sqlx::Error), // Internal only, not exposed
}

impl ResponseError for ApiError {
    fn error_response(&self) -> HttpResponse {
        // Log the actual error with details internally
        match self {
            ApiError::DatabaseError(e) => {
                log::error!("Database error: {}", e);
                HttpResponse::InternalServerError().json(ErrorResponse {
                    message: "Internal server error".into(),
                    code: "INTERNAL_ERROR".into(),
                })
            }
            // Handle other cases...
        }
    }
}
```

## HTTP Security Headers

- [ ] Set appropriate security headers for all responses:
  - [ ] Content-Security-Policy
  - [ ] X-Content-Type-Options: nosniff
  - [ ] X-Frame-Options: deny
  - [ ] Strict-Transport-Security
  - [ ] Referrer-Policy
  - [ ] Permissions-Policy (formerly Feature-Policy)

Example middleware for Actix Web:

```rust
use actix_web::{
    dev::{forward_ready, Service, ServiceRequest, ServiceResponse, Transform},
    Error,
};
use futures::future::{ready, LocalBoxFuture, Ready};
use std::future::Future;
use std::pin::Pin;
use std::task::{Context, Poll};

pub struct SecurityHeadersMiddleware;

impl<S, B> Transform<S, ServiceRequest> for SecurityHeadersMiddleware
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error>,
    S::Future: 'static,
    B: 'static,
{
    type Response = ServiceResponse<B>;
    type Error = Error;
    type Transform = SecurityHeadersMiddlewareService<S>;
    type InitError = ();
    type Future = Ready<Result<Self::Transform, Self::InitError>>;

    fn new_transform(&self, service: S) -> Self::Future {
        ready(Ok(SecurityHeadersMiddlewareService { service }))
    }
}

pub struct SecurityHeadersMiddlewareService<S> {
    service: S,
}

impl<S, B> Service<ServiceRequest> for SecurityHeadersMiddlewareService<S>
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error>,
    S::Future: 'static,
    B: 'static,
{
    type Response = ServiceResponse<B>;
    type Error = Error;
    type Future = LocalBoxFuture<'static, Result<Self::Response, Self::Error>>;

    forward_ready!(service);

    fn call(&self, req: ServiceRequest) -> Self::Future {
        let fut = self.service.call(req);

        Box::pin(async move {
            let mut res = fut.await?;

            res.headers_mut().insert(
                "X-Content-Type-Options",
                actix_web::http::header::HeaderValue::from_static("nosniff"),
            );
            res.headers_mut().insert(
                "X-Frame-Options",
                actix_web::http::header::HeaderValue::from_static("DENY"),
            );
            // Add other security headers...

            Ok(res)
        })
    }
}
```

## API Security

- [ ] Implement proper rate limiting
- [ ] Set appropriate request size limits
- [ ] Use CORS with specific allowed origins (not wildcard)
- [ ] Validate and sanitize file uploads
- [ ] Implement proper API versioning

Example of rate limiting with `actix-governor`:

```rust
use actix_governor::{Governor, GovernorConfigBuilder};
use std::time::Duration;

// In your app configuration
let governor_conf = GovernorConfigBuilder::default()
    .per_second(2)
    .burst_size(5)
    .finish()
    .unwrap();

HttpServer::new(move || {
    App::new()
        .wrap(Governor::new(&governor_conf))
        // ...other middleware and routes
})
```

## Secret Management

- [ ] Don't hardcode secrets in the application
- [ ] Load secrets from environment variables or dedicated secret stores
- [ ] Use secure ways to pass secrets to containers
- [ ] Rotate secrets regularly
- [ ] Monitor for secret leaks in code repositories

Example with dotenv for development:

```rust
use dotenv::dotenv;
use std::env;

fn main() {
    // Only in development
    #[cfg(debug_assertions)]
    dotenv().ok();

    let database_url = env::var("DATABASE_URL")
        .expect("DATABASE_URL must be set");

    // Use the secrets...
}
```

## Container Security

- [ ] Use minimal base images (alpine or distroless)
- [ ] Run as non-root user
- [ ] Use multi-stage builds to reduce image size
- [ ] Don't install unnecessary packages
- [ ] Scan images for vulnerabilities with Trivy

Example Dockerfile with security best practices:

```dockerfile
# Build stage
FROM rust:1.67-alpine as builder

WORKDIR /usr/src/app
COPY . .

RUN apk add --no-cache musl-dev
RUN cargo build --release

# Runtime stage
FROM alpine:3.17

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app
COPY --from=builder /usr/src/app/target/release/your-app /app/your-app

# Switch to non-root user
USER appuser

EXPOSE 8080
CMD ["./your-app"]
```

## Resources

- [OWASP Rust Security Guidelines](https://owasp.org/www-project-top-ten/)
- [Actix Web Security Documentation](https://actix.rs/docs/)
- [The Rust Security Mindset](https://www.youtube.com/watch?v=hUPcky3Dl4I)
- [RustSec Advisory Database](https://rustsec.org/)
