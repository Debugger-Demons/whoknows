# Middleware in Actix Web vs Express.js

## Introduction

Middleware is a crucial concept in web frameworks that allows processing requests and responses at various stages of the request/response lifecycle. This document compares middleware implementation in Actix Web (Rust) and Express.js (Node.js).

## Key Terms and Concepts

| Term                                               | Actix Web                                             | Express.js                                  |
| -------------------------------------------------- | ----------------------------------------------------- | ------------------------------------------- |
| [**Middleware**](#middleware-comparison)           | Types that implement `Transform` and `Service` traits | Functions with signature `(req, res, next)` |
| [**Request**](#request-comparison)                 | `HttpRequest` struct                                  | `req` object                                |
| [**Response**](#response-comparison)               | `HttpResponse` struct                                 | `res` object                                |
| [**Next**](#next-comparison)                       | Handled by the `Service` trait implementation         | Explicit `next()` function call             |
| [**Execution Order**](#execution-order-comparison) | Inside-out (wrap pattern)                             | Linear chain                                |

## Middleware Application Points

### Express.js

In Express, middleware is applied through:

- Application-level: `app.use(middleware)`
- Router-level: `router.use(middleware)`
- Route-level: `app.get('/path', middleware, handler)`
- Error-handling: `app.use((err, req, res, next) => {})`

### Actix Web

In Actix Web, middleware is applied through:

- Application-level: `App::new().wrap(middleware)`
- Scope-level: `web::scope("/api").wrap(middleware)`
- Resource-level: `resource.wrap(middleware)`

## Middleware Flow

### Express.js

```javascript
// Express middleware flow
app.use((req, res, next) => {
  console.log("Middleware 1 - Before handler");
  next();
  console.log("Middleware 1 - After handler");
});

app.use((req, res, next) => {
  console.log("Middleware 2 - Before handler");
  next();
  console.log("Middleware 2 - After handler");
});

app.get("/", (req, res) => {
  console.log("Handler execution");
  res.send("Hello World");
});

// Execution order:
// Middleware 1 - Before handler
// Middleware 2 - Before handler
// Handler execution
// Middleware 2 - After handler
// Middleware 1 - After handler
```

### Actix Web

```rust
// Actix Web middleware flow
struct Logger1;
struct Logger2;

impl<S, B> Transform<S, ServiceRequest> for Logger1
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error>,
    B: MessageBody,
{
    // Implementation details...
    // Wrapped in Future that logs before and after inner service call
}

// In main.rs
HttpServer::new(|| {
    App::new()
        .wrap(Logger1)
        .wrap(Logger2)
        .route("/", web::get().to(handler))
})

// Execution order (conceptually):
// Logger1 start
// Logger2 start
// Handler execution
// Logger2 end
// Logger1 end
```

## Common Middleware Use Cases

### Authentication Middleware

#### Express.js

```javascript
function authMiddleware(req, res, next) {
  const token = req.headers.authorization;
  if (!token) {
    return res.status(401).json({ message: "Authentication required" });
  }

  try {
    const decoded = verifyToken(token);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({ message: "Invalid token" });
  }
}

// Usage
app.use("/api/protected", authMiddleware);
```

#### Actix Web

```rust
struct AuthMiddleware;

impl<S, B> Transform<S, ServiceRequest> for AuthMiddleware
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error>,
    B: MessageBody,
{
    type Response = ServiceResponse<B>;
    type Error = Error;
    type Transform = AuthMiddlewareService<S>;
    type InitError = ();
    type Future = Ready<Result<Self::Transform, Self::InitError>>;

    fn new_transform(&self, service: S) -> Self::Future {
        ok(AuthMiddlewareService { service })
    }
}

struct AuthMiddlewareService<S> {
    service: S,
}

impl<S, B> Service<ServiceRequest> for AuthMiddlewareService<S>
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error>,
    B: MessageBody,
{
    type Response = ServiceResponse<B>;
    type Error = Error;
    type Future = Pin<Box<dyn Future<Output = Result<Self::Response, Self::Error>>>>;

    fn poll_ready(&self, cx: &mut Context<'_>) -> Poll<Result<(), Self::Error>> {
        self.service.poll_ready(cx)
    }

    fn call(&self, req: ServiceRequest) -> Self::Future {
        let headers = req.headers().clone();

        // Check for auth token
        if let Some(auth_header) = headers.get("Authorization") {
            // Verify token
            match verify_token(auth_header.to_str().unwrap_or("")) {
                Ok(user_id) => {
                    // Store user info in request extensions
                    req.extensions_mut().insert(UserId(user_id));
                    let fut = self.service.call(req);
                    Box::pin(async move {
                        fut.await
                    })
                }
                Err(_) => {
                    Box::pin(async move {
                        Ok(req.into_response(
                            HttpResponse::Unauthorized()
                                .json(json!({"message": "Invalid token"}))
                                .into_body(),
                        ))
                    })
                }
            }
        } else {
            Box::pin(async move {
                Ok(req.into_response(
                    HttpResponse::Unauthorized()
                        .json(json!({"message": "Authentication required"}))
                        .into_body(),
                ))
            })
        }
    }
}

// Usage
App::new()
    .wrap(AuthMiddleware)
    .service(
        web::scope("/api/protected")
            .route("/data", web::get().to(get_protected_data))
    )
```

### Logging Middleware

#### Express.js

```javascript
function loggingMiddleware(req, res, next) {
  const start = Date.now();
  console.log(`${req.method} ${req.url} started`);

  // Override res.end to capture response time
  const originalEnd = res.end;
  res.end = function (...args) {
    const duration = Date.now() - start;
    console.log(`${req.method} ${req.url} ${res.statusCode} - ${duration}ms`);
    originalEnd.apply(res, args);
  };

  next();
}

// Usage
app.use(loggingMiddleware);
```

#### Actix Web

```rust
// Actix Web provides built-in logging middleware
use actix_web::middleware::Logger;

// Usage
App::new()
    .wrap(Logger::default())
    .wrap(Logger::new("%a %{User-Agent}i"))

// Custom logging middleware
pub struct CustomLogger;

impl<S, B> Transform<S, ServiceRequest> for CustomLogger
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error>,
    B: MessageBody,
{
    type Response = ServiceResponse<B>;
    type Error = Error;
    type Transform = CustomLoggerMiddleware<S>;
    type InitError = ();
    type Future = Ready<Result<Self::Transform, Self::InitError>>;

    fn new_transform(&self, service: S) -> Self::Future {
        ok(CustomLoggerMiddleware { service })
    }
}

pub struct CustomLoggerMiddleware<S> {
    service: S,
}

impl<S, B> Service<ServiceRequest> for CustomLoggerMiddleware<S>
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error>,
    B: MessageBody,
{
    type Response = ServiceResponse<B>;
    type Error = Error;
    type Future = Pin<Box<dyn Future<Output = Result<Self::Response, Self::Error>>>>;

    fn poll_ready(&self, cx: &mut Context<'_>) -> Poll<Result<(), Self::Error>> {
        self.service.poll_ready(cx)
    }

    fn call(&self, req: ServiceRequest) -> Self::Future {
        let start = std::time::Instant::now();
        let method = req.method().clone();
        let path = req.path().to_owned();

        println!("{} {} started", method, path);

        let fut = self.service.call(req);

        Box::pin(async move {
            let res = fut.await?;
            let duration = start.elapsed();
            println!("{} {} {} - {:?}", method, path, res.status(), duration);
            Ok(res)
        })
    }
}
```

## Simplified Middleware (Actix Web 4.x)

Actix Web 4.x introduced a simplified middleware API for common use cases:

```rust
use actix_web::{dev::ServiceRequest, Error};
use futures::future::{ok, Ready};

// Simple middleware function
async fn simple_middleware(
    req: ServiceRequest,
    srv: actix_web::dev::Service<ServiceRequest>,
) -> Result<actix_web::dev::ServiceResponse, Error> {
    println!("Request: {}", req.path());
    let res = srv.call(req).await?;
    println!("Response: {}", res.status());
    Ok(res)
}

// Usage
use actix_web::middleware::Middleware;

App::new()
    .wrap_fn(|req, srv| {
        println!("Hi from middleware!");
        srv.call(req)
    })
```

## Creating Custom Middleware

### Express.js

```javascript
// Middleware factory pattern
function createRateLimiter(maxRequests, windowMs) {
  const requests = {};

  return (req, res, next) => {
    const ip = req.ip;
    const now = Date.now();

    // Initialize or cleanup old requests
    requests[ip] = requests[ip] || [];
    requests[ip] = requests[ip].filter((time) => now - time < windowMs);

    // Check if limit reached
    if (requests[ip].length >= maxRequests) {
      return res.status(429).json({ message: "Too many requests" });
    }

    // Add request timestamp
    requests[ip].push(now);
    next();
  };
}

// Usage
app.use("/api", createRateLimiter(100, 60000)); // 100 requests per minute
```

### Actix Web

```rust
// Middleware factory pattern
pub struct RateLimiter {
    max_requests: usize,
    window_ms: u64,
}

impl RateLimiter {
    pub fn new(max_requests: usize, window_ms: u64) -> Self {
        Self { max_requests, window_ms }
    }
}

impl<S, B> Transform<S, ServiceRequest> for RateLimiter
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error>,
    B: MessageBody,
{
    type Response = ServiceResponse<B>;
    type Error = Error;
    type Transform = RateLimiterMiddleware<S>;
    type InitError = ();
    type Future = Ready<Result<Self::Transform, Self::InitError>>;

    fn new_transform(&self, service: S) -> Self::Future {
        // In a real implementation, you would use a proper rate limiting store
        // (e.g., Redis, in-memory cache with proper locking)
        let limiter = Arc::new(Mutex::new(HashMap::new()));

        ok(RateLimiterMiddleware {
            service,
            max_requests: self.max_requests,
            window_ms: self.window_ms,
            requests: limiter,
        })
    }
}

struct RateLimiterMiddleware<S> {
    service: S,
    max_requests: usize,
    window_ms: u64,
    requests: Arc<Mutex<HashMap<String, Vec<u128>>>>,
}

impl<S, B> Service<ServiceRequest> for RateLimiterMiddleware<S>
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error>,
    B: MessageBody,
{
    type Response = ServiceResponse<B>;
    type Error = Error;
    type Future = Pin<Box<dyn Future<Output = Result<Self::Response, Self::Error>>>>;

    fn poll_ready(&self, cx: &mut Context<'_>) -> Poll<Result<(), Self::Error>> {
        self.service.poll_ready(cx)
    }

    fn call(&self, req: ServiceRequest) -> Self::Future {
        // Get client IP
        let ip = req.connection_info().realip_remote_addr()
            .unwrap_or("unknown").to_string();

        let now = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap()
            .as_millis();

        let window_ms = self.window_ms as u128;

        // Check rate limits
        let mut requests = self.requests.lock().unwrap();

        // Initialize or cleanup old requests
        let times = requests.entry(ip.clone()).or_insert_with(Vec::new);
        times.retain(|&time| now - time < window_ms);

        // Check if limit reached
        if times.len() >= self.max_requests {
            return Box::pin(async move {
                Ok(req.into_response(
                    HttpResponse::TooManyRequests()
                        .json(json!({"message": "Too many requests"}))
                        .into_body()
                ))
            });
        }

        // Add request timestamp
        times.push(now);
        drop(requests);

        // Forward request
        let fut = self.service.call(req);
        Box::pin(async move {
            fut.await
        })
    }
}

// Usage
App::new()
    .service(
        web::scope("/api")
            .wrap(RateLimiter::new(100, 60000)) // 100 requests per minute
            .route("/data", web::get().to(get_data))
    )
```

## Key Differences Summary

1. **Implementation Approach**:

   - Express: Functional middleware with explicit `next()` calls
   - Actix Web: Type-based middleware implementing service traits

2. **Complexity**:

   - Express: Generally simpler to implement and understand
   - Actix Web: More complex but offers better type safety and performance

3. **Execution Model**:

   - Express: Linear chain (middleware 1 → middleware 2 → handler → middleware 2 → middleware 1)
   - Actix Web: Nested services (middleware 1 wraps middleware 2 which wraps the handler)

4. **Async Handling**:

   - Express: Callback-based or Promise-based with async/await
   - Actix Web: Native async/await with Rust's futures

5. **Error Handling**:

   - Express: Error middleware with (err, req, res, next) signature
   - Actix Web: Error types and mapping with `map_err` or custom error handlers

6. **State Management**:
   - Express: Request object properties or app.locals
   - Actix Web: Request extensions and application data

## Code Comparisons

### Middleware Comparison

| Actix Web | Express.js |
| --------- | ---------- |

```rust
// Basic Actix Web middleware implementation
use actix_web::{dev::{Service, Transform, ServiceRequest, ServiceResponse}, Error};
use futures::future::{ok, Ready};
use std::future::{ready, Future};
use std::pin::Pin;
use std::task::{Context, Poll};

struct ExampleMiddleware;

impl<S, B> Transform<S, ServiceRequest> for ExampleMiddleware
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error>,
    B: 'static,
{
    type Response = ServiceResponse<B>;
    type Error = Error;
    type Transform = ExampleMiddlewareService<S>;
    type InitError = ();
    type Future = Ready<Result<Self::Transform, Self::InitError>>;

    fn new_transform(&self, service: S) -> Self::Future {
        ok(ExampleMiddlewareService { service })
    }
}

struct ExampleMiddlewareService<S> {
    service: S,
}

impl<S, B> Service<ServiceRequest> for ExampleMiddlewareService<S>
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error>,
    B: 'static,
{
    type Response = ServiceResponse<B>;
    type Error = Error;
    type Future = Pin<Box<dyn Future<Output = Result<Self::Response, Self::Error>>>>;

    fn poll_ready(&self, cx: &mut Context<'_>) -> Poll<Result<(), Self::Error>> {
        self.service.poll_ready(cx)
    }

    fn call(&self, req: ServiceRequest) -> Self::Future {
        println!("Before handler execution");

        let fut = self.service.call(req);

        Box::pin(async move {
            let res = fut.await?;
            println!("After handler execution");
            Ok(res)
        })
    }
}

// Usage
App::new()
    .wrap(ExampleMiddleware)
    .route("/", web::get().to(index))
```

```javascript
// Basic Express.js middleware implementation
function exampleMiddleware(req, res, next) {
  console.log("Before handler execution");

  // Call next middleware in the chain
  next();

  // This code runs after the handler
  console.log("After handler execution");
}

// Usage
app.use(exampleMiddleware);
app.get("/", (req, res) => {
  res.send("Hello World");
});
```

### Request Comparison

| Actix Web | Express.js |
| --------- | ---------- |

```rust
// Accessing request in Actix Web
async fn handler(req: HttpRequest) -> impl Responder {
    // Get path
    let path = req.path();

    // Get query parameters
    let query = req.query_string();

    // Get specific header
    let user_agent = req.headers().get("User-Agent");

    // Get path parameters (with web::Path extractor)
    // In a route defined as "/users/{id}"
    let id = req.match_info().get("id").unwrap_or_default();

    // Get request method
    let method = req.method();

    // Access extensions (data added by middleware)
    let user_id = req.extensions().get::<UserId>();

    HttpResponse::Ok().body(format!("Path: {}", path))
}
```

```javascript
// Accessing request in Express.js
app.get("/users/:id", (req, res) => {
  // Get path
  const path = req.path;

  // Get query parameters
  const query = req.query;

  // Get specific header
  const userAgent = req.headers["user-agent"];

  // Get path parameters
  const id = req.params.id;

  // Get request method
  const method = req.method;

  // Access data added by middleware
  const userId = req.user?.id;

  res.send(`Path: ${path}`);
});
```

### Response Comparison

| Actix Web | Express.js |
| --------- | ---------- |

```rust
// Working with responses in Actix Web
async fn response_examples() -> impl Responder {
    // Basic text response
    let text_response = HttpResponse::Ok().body("Hello World");

    // JSON response
    let json_response = HttpResponse::Ok().json(json!({
        "message": "Success",
        "data": {
            "id": 1,
            "name": "Example"
        }
    }));

    // Setting status code
    let not_found = HttpResponse::NotFound().finish();

    // Setting headers
    let with_headers = HttpResponse::Ok()
        .append_header(("X-Custom-Header", "value"))
        .append_header(("Content-Type", "text/plain"))
        .body("With custom headers");

    // Setting cookies
    let with_cookie = HttpResponse::Ok()
        .cookie(
            Cookie::build("name", "value")
                .path("/")
                .secure(true)
                .http_only(true)
                .finish()
        )
        .finish();

    // Redirect
    let redirect = HttpResponse::Found()
        .append_header((header::LOCATION, "/new-url"))
        .finish();

    // Return one of the responses
    text_response
}
```

```javascript
// Working with responses in Express.js
app.get("/response-examples", (req, res) => {
  // Basic text response
  // res.send('Hello World');

  // JSON response
  // res.json({
  //     message: 'Success',
  //     data: {
  //         id: 1,
  //         name: 'Example'
  //     }
  // });

  // Setting status code
  // res.status(404).end();

  // Setting headers
  // res.set('X-Custom-Header', 'value');
  // res.set('Content-Type', 'text/plain');
  // res.send('With custom headers');

  // Setting cookies
  // res.cookie('name', 'value', {
  //     path: '/',
  //     secure: true,
  //     httpOnly: true
  // });
  // res.end();

  // Redirect
  // res.redirect('/new-url');

  // Example of what we'll actually return
  res.send("Hello World");
});
```

### Next Comparison

| Actix Web | Express.js |
| --------- | ---------- |

```rust
// In Actix Web, "next" is handled implicitly by the Service trait
impl<S, B> Service<ServiceRequest> for ExampleMiddlewareService<S>
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error>,
    B: 'static,
{
    type Response = ServiceResponse<B>;
    type Error = Error;
    type Future = Pin<Box<dyn Future<Output = Result<Self::Response, Self::Error>>>>;

    fn poll_ready(&self, cx: &mut Context<'_>) -> Poll<Result<(), Self::Error>> {
        self.service.poll_ready(cx)
    }

    fn call(&self, req: ServiceRequest) -> Self::Future {
        println!("Processing request");

        // This is equivalent to calling "next()" in Express
        // It passes the request to the next middleware or handler
        let fut = self.service.call(req);

        Box::pin(async move {
            // Wait for the response
            let res = fut.await?;
            println!("Processing response");
            Ok(res)
        })
    }
}
```

```javascript
// In Express.js, "next" is explicitly called
function middleware1(req, res, next) {
  console.log("Processing request in middleware1");

  // Calling next passes control to the next middleware
  next();

  // This code runs after all subsequent middleware and handler have completed
  console.log("Processing response in middleware1");
}

function middleware2(req, res, next) {
  console.log("Processing request in middleware2");

  // You can skip to the next middleware by calling next()
  next();

  console.log("Processing response in middleware2");
}

function errorMiddleware(err, req, res, next) {
  // Error handling middleware has a different signature
  console.error("Error caught:", err);
  res.status(500).send("Something broke!");

  // Can still call next(err) to pass to the next error handler
  // next(err);
}

// Usage
app.use(middleware1);
app.use(middleware2);
app.use(errorMiddleware);
```

### Execution Order Comparison

| Actix Web | Express.js |
| --------- | ---------- |

```rust
// Actix Web middleware execution order
// Middleware wrapping (inside-out)
HttpServer::new(|| {
    App::new()
        .wrap(Middleware1) // Outer middleware
        .wrap(Middleware2) // Inner middleware
        .route("/", web::get().to(handler))
})

// Execution flow:
// 1. Middleware1 starts (outer)
// 2. Middleware2 starts (inner)
// 3. Handler executes
// 4. Middleware2 completes (inner)
// 5. Middleware1 completes (outer)
```

```javascript
// Express.js middleware execution order
// Linear chain
app.use(middleware1); // First middleware
app.use(middleware2); // Second middleware
app.get("/", handler); // Handler

// Execution flow:
// 1. middleware1 starts
// 2. middleware1 calls next()
// 3. middleware2 starts
// 4. middleware2 calls next()
// 5. handler executes
// 6. middleware2 completes (after next())
// 7. middleware1 completes (after next())
```
