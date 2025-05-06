Okay, let's break down these files line by line to understand how this Dockerized Rust web application deployment works.

**Overall Goal:**

The setup aims to run a web application consisting of a Rust/Actix backend and a frontend (presumably served by Nginx, based on the config file mount). Docker and Docker Compose are used to containerize these components, manage their configuration, networking, and data persistence, making deployment consistent and reproducible.

---

### 1. `docker-compose.yml` (SERVER deployment)

This file defines and configures the multi-container application managed by Docker Compose.

```yaml
# docker-compose.yml (SERVER deployment)
services:
```

- **`services:`**
  - **Definition:** The top-level key where you define the individual containers (services) that make up your application stack.
  - **Explanation:** Each entry under `services` represents a container that Docker Compose will build (if needed) and run.
  - **Example:** Here, we define two services: `backend` and `frontend`.

```yaml
backend:
```

- **`backend:`**
  - **Definition:** A user-defined name for the service running the Rust Actix application.
  - **Explanation:** This name is used internally by Docker Compose for referencing the service (e.g., in `depends_on`, network communication).
  - **Example:** This block defines the configuration for the container running your Rust code.

```yaml
container_name: ${COMPOSE_PROJECT_NAME:-mywebapp}_backend
```

- **`container_name:`**
  - **Definition:** Specifies a custom, fixed name for the container created by this service.
  - **Explanation:** By default, Docker Compose names containers like `<project>_<service>_<index>`. This line overrides that, using the `COMPOSE_PROJECT_NAME` environment variable (often derived from the directory name) or defaulting to `mywebapp`, and appending `_backend`. This provides a predictable name.
  - **Example:** If the project directory is `my_cool_app`, the container might be named `my_cool_app_backend`. If `COMPOSE_PROJECT_NAME` isn't set, it defaults to `mywebapp_backend`.

```yaml
image: ${IMAGE_TAG_BACKEND}
```

- **`image:`**
  - **Definition:** Specifies the Docker image to use for this service's container.
  - **Explanation:** `${IMAGE_TAG_BACKEND}` indicates that the image name and tag are provided by an environment variable named `IMAGE_TAG_BACKEND` (likely defined in a `.env` file). This allows you to easily switch image versions without modifying the compose file.
  - **Example:** If `.env` contains `IMAGE_TAG_BACKEND=myregistry/my-rust-app:v1.2`, Docker Compose will pull and run that specific image.

```yaml
restart: unless-stopped
```

- **`restart:`**
  - **Definition:** Defines the container's restart policy.
  - **Explanation:** `unless-stopped` means the container will automatically restart if it exits due to an error or if the Docker daemon restarts, but _not_ if it was explicitly stopped by a user (e.g., via `docker stop` or `docker-compose stop`).
  - **Example:** If the Rust backend crashes unexpectedly, Docker will attempt to restart it.

```yaml
environment:
  RUST_LOG: ${RUST_LOG:-info}
  DATABASE_URL: sqlite:/app/data/whoknows.db
  APP_PORT: ${BACKEND_INTERNAL_PORT:-8080}
```

- **`environment:`**
  - **Definition:** Sets environment variables inside the container.
  - **Explanation:** This is the primary way to pass configuration to the application running inside the container.
  - **`RUST_LOG: ${RUST_LOG:-info}`**: Sets the logging level for the Rust application (used by `env_logger`). It takes the value from the `RUST_LOG` environment variable (from `.env`) or defaults to `info`.
  - **`DATABASE_URL: sqlite:/app/data/whoknows.db`**: Sets the database connection string. It specifies a SQLite database located at the path `/app/data/whoknows.db` _inside the container_. This path is mapped to a persistent volume later.
  - **`APP_PORT: ${BACKEND_INTERNAL_PORT:-8080}`**: Sets the port number the Rust application should listen on _inside the container_. It uses the `BACKEND_INTERNAL_PORT` variable (from `.env`) or defaults to `8080`.

```yaml
volumes:
  - db_data:/app/data
```

- **`volumes:`** (within the `backend` service)
  - **Definition:** Mounts host paths or named volumes into the container.
  - **Explanation:** `- db_data:/app/data` maps the named volume `db_data` (defined later) to the `/app/data` directory inside the container. This ensures that the SQLite database file (`whoknows.db`) persists even if the container is removed and recreated.
  - **Example:** The `whoknows.db` file created by the backend will be stored in the Docker-managed `db_data` volume on the host machine.

```yaml
expose:
  - "${BACKEND_INTERNAL_PORT:-8080}"
```

- **`expose:`**
  - **Definition:** Documents which ports the container listens on internally, without publishing them to the host machine.
  - **Explanation:** This makes the specified port (default 8080) accessible to _other services on the same Docker network_ (`app-network`), but not directly from the host machine's network. The `frontend` service will use this to communicate with the `backend`.
  - **Example:** The `frontend` container can reach the backend by making requests to `http://backend:8080` (using the service name `backend` as the hostname).

```yaml
networks:
  - app-network
```

- **`networks:`** (within the `backend` service)
  - **Definition:** Connects the service's container to specified Docker networks.
  - **Explanation:** This line attaches the `backend` container to the custom network named `app-network`.

```yaml
frontend:
  container_name: ${COMPOSE_PROJECT_NAME:-mywebapp}_frontend
  image: ${IMAGE_TAG_FRONTEND}
  restart: always
```

- **`frontend:`**: Defines the service for the frontend container.
- **`container_name:`**: Sets a predictable name like `mywebapp_frontend`.
- **`image:`**: Uses the image specified by the `IMAGE_TAG_FRONTEND` environment variable.
- **`restart: always`**: Configures the container to always restart if it stops for any reason, unless explicitly stopped.

```yaml
ports:
  - "${HOST_PORT_FRONTEND:-8081}:${FRONTEND_INTERNAL_PORT:-91}"
```

- **`ports:`**
  - **Definition:** Maps ports between the host machine and the container. Format: `"HOST_PORT:CONTAINER_PORT"`.
  - **Explanation:** This makes the frontend accessible from outside the Docker host. It maps the port specified by `HOST_PORT_FRONTEND` (from `.env`, default 8081) on the host machine to the port specified by `FRONTEND_INTERNAL_PORT` (from `.env`, default 91) inside the `frontend` container.
  - **Example:** If `HOST_PORT_FRONTEND` is 80, you can access the frontend via `http://<your_host_ip>:80` (or just `http://<your_host_ip>`), and this traffic will be directed to port 91 inside the frontend container. With the default 8081, you'd use `http://<your_host_ip>:8081`.

```yaml
volumes:
  - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
```

- **`volumes:`** (within the `frontend` service)
  - **Definition:** Mounts a local file into the container.
  - **Explanation:** This mounts the `nginx.conf` file (located in the same directory as the `docker-compose.yml` file) into the container at `/etc/nginx/conf.d/default.conf`. The `:ro` flag makes the mounted file read-only inside the container. This allows you to provide a custom Nginx configuration.
  - **Example:** The Nginx server running inside the `frontend` container will use the rules defined in your local `nginx.conf`.

```yaml
networks:
  - app-network
```

- **`networks:`** (within the `frontend` service): Connects the `frontend` container to the `app-network`.

```yaml
depends_on:
  - backend
```

- **`depends_on:`**
  - **Definition:** Specifies dependencies between services.
  - **Explanation:** This tells Docker Compose to start the `backend` service _before_ starting the `frontend` service. **Important:** It only waits for the `backend` container to _start_, not necessarily for the application inside it to be fully ready and listening.
  - **Example:** `docker-compose up` will ensure the `backend` container is running before it attempts to start the `frontend` container.

```yaml
volumes:
  db_data:
```

- **`volumes:`** (top-level)
  - **Definition:** Declares named volumes used by the services.
  - **Explanation:** `db_data:` declares a named volume called `db_data`. Docker manages the storage for this volume on the host machine. This is the volume used by the `backend` service to persist its database.
  - **Example:** This ensures that even if you run `docker-compose down` (which removes containers), the data in `db_data` remains until you explicitly remove the volume (e.g., `docker volume rm <project>_db_data`).

```yaml
networks:
  app-network:
    driver: bridge
```

- **`networks:`** (top-level)
  - **Definition:** Declares custom networks used by the services.
  - **Explanation:** `app-network:` declares a custom network named `app-network`. `driver: bridge` specifies that it should use Docker's standard `bridge` network driver. This creates a private, isolated network for the containers connected to it. Containers on the same bridge network can communicate with each other using their service names as hostnames.
  - **Example:** The `frontend` container can send requests to the `backend` container using the address `http://backend:8080` (or whatever port `BACKEND_INTERNAL_PORT` is set to).

```yaml
# environment variables used in this docker-compose.yml file from .env file
#   IMAGE_TAG_BACKEND
#   IMAGE_TAG_FRONTEND
#   COMPOSE_PROJECT_NAME
#   RUST_LOG
#   HOST_PORT_FRONTEND
#   FRONTEND_INTERNAL_PORT
#   BACKEND_INTERNAL_PORT
```

- **Comment:** Lists the environment variables expected to be defined in a `.env` file in the same directory as the `docker-compose.yml`. Docker Compose automatically loads variables from a `.env` file.

---

### 2. `Dockerfile` (Backend: Rust Actix Web app)

This file defines the steps to build the Docker image for the `backend` service. It uses a multi-stage build for optimization.

```dockerfile
# ---- Stage 1: Builder ----
    FROM rust:1.81 as builder
```

- **`FROM rust:1.81 as builder`**
  - **Definition:** Specifies the base image for this build stage and names the stage `builder`.
  - **Explanation:** Starts the build process using the official Rust image (version 1.81), which contains the Rust compiler (`rustc`), package manager (`cargo`), and other necessary build tools. Naming the stage allows copying artifacts from it later.

```dockerfile
    # Install build dependencies
    RUN apt-get update && apt-get install -y --no-install-recommends libssl-dev pkg-config \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*
```

- **`RUN apt-get update ...`**
  - **Definition:** Executes commands in a new layer of the image.
  - **Explanation:** Updates the package list and installs system libraries (`libssl-dev`, `pkg-config`) required by some Rust crates (often those involving cryptography or native bindings) during compilation. `--no-install-recommends` avoids installing optional packages. The cleanup commands (`apt-get clean`, `rm -rf ...`) reduce the size of this image layer.

```dockerfile
    WORKDIR /app
```

- **`WORKDIR /app`**
  - **Definition:** Sets the working directory for subsequent instructions (`COPY`, `RUN`, `CMD`) in the Dockerfile.
  - **Explanation:** Creates the `/app` directory if it doesn't exist and changes the current directory to `/app`. Files will be copied here, and commands will run from here.

```dockerfile
    # Copy manifests
    COPY Cargo.toml Cargo.lock ./
```

- **`COPY Cargo.toml Cargo.lock ./`**
  - **Definition:** Copies files from the build context (your local project directory) into the image's current working directory (`/app`).
  - **Explanation:** Copies the Rust project manifest (`Cargo.toml`) and the lock file (`Cargo.lock`). This is done _before_ copying the source code to leverage Docker's layer caching. If these files haven't changed, Docker can reuse the cached layer from the next `RUN` command (which builds dependencies).

```dockerfile
    RUN mkdir src \
        && echo 'fn main() {println!("Building dependencies...")}' > src/main.rs \
        && cargo build --release \
        && rm -rf src \
        && rm -f target/release/deps/whoknows_rust_actix_backend*
```

- **`RUN mkdir src ...`**
  - **Definition:** Executes a series of shell commands to pre-build dependencies.
  - **Explanation:** This is a common Rust Docker caching optimization:
    1.  `mkdir src && echo ... > src/main.rs`: Creates a minimal dummy `src/main.rs` file.
    2.  `cargo build --release`: Compiles the project. Since only `Cargo.toml` and `Cargo.lock` (and the dummy `main.rs`) are present, this primarily downloads and compiles _only the dependencies_.
    3.  `rm -rf src ...`: Removes the dummy source and the temporary executable artifact created from it. The compiled _dependencies_ remain in `target/release/deps`.
  - **Example:** If you change only your application code (`src/`) later, Docker will reuse the cached layer created by this step, significantly speeding up the build.

```dockerfile
    # Copy the actual source code
    COPY src ./src
```

- **`COPY src ./src`**
  - **Definition:** Copies the application's source code directory (`src`) from the build context into the image's `/app/src` directory.
  - **Explanation:** This happens _after_ dependencies are built. If only files within `src` change, the build process restarts from this point.

```dockerfile
    # Build the application
    RUN cargo build --release
```

- **`RUN cargo build --release`**
  - **Definition:** Compiles the actual application source code.
  - **Explanation:** Runs the Rust compiler in release mode (optimized build). It uses the previously compiled dependencies and compiles the code from the `src` directory copied in the previous step. The final executable will be located at `/app/target/release/whoknows_rust_actix_backend`.

```dockerfile
    # --------------------------
    # ---- Stage 2: Runtime ----
    FROM debian:bookworm-slim
```

- **`FROM debian:bookworm-slim`**
  - **Definition:** Starts a new, final build stage based on a minimal Debian image.
  - **Explanation:** This creates the final, smaller runtime image. It doesn't contain the Rust compiler or build tools, only the necessary runtime dependencies and the compiled application binary.

```dockerfile
    RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*
```

- **`RUN apt-get update ...`**
  - **Definition:** Installs runtime dependencies in the final image.
  - **Explanation:** Installs `ca-certificates`, which are needed by the application to make secure HTTPS/TLS connections (e.g., if it needed to call external APIs, or for `sqlx` with `rustls`). Cleans up apt cache.

```dockerfile
    WORKDIR /app
```

- **`WORKDIR /app`**: Sets the working directory in the final runtime image.

```dockerfile
    COPY --from=builder /app/target/release/whoknows_rust_actix_backend .
```

- **`COPY --from=builder ...`**
  - **Definition:** Copies an artifact from a previous build stage (`builder`) into the current stage.
  - **Explanation:** This copies _only_ the compiled application binary (`whoknows_rust_actix_backend`) from the `/app/target/release/` directory in the `builder` stage to the current working directory (`/app`) in the final image.

```dockerfile
    RUN chmod +x ./whoknows_rust_actix_backend
```

- **`RUN chmod +x ...`**
  - **Definition:** Changes the permissions of the file.
  - **Explanation:** Makes the copied application binary executable.

```dockerfile
    # Start the application
    CMD ["./whoknows_rust_actix_backend"]
```

- **`CMD ["./whoknows_rust_actix_backend"]`**
  - **Definition:** Specifies the default command to run when a container is started from this image.
  - **Explanation:** Executes the compiled Rust application binary located at `/app/whoknows_rust_actix_backend`. The JSON array format is the preferred syntax for `CMD`.

---

### 3. `Cargo.toml` (Backend)

This is the Rust project's manifest file, defining metadata and dependencies.

```toml
[package]
name = "whoknows_rust_actix_backend"
version = "0.1.0"
edition = "2021"
```

- **`[package]`**: Section defining metadata about the crate (the Rust package).
  - **`name`**: The name of the crate. By default, this is also the name of the binary produced.
  - **`version`**: The crate version, following Semantic Versioning.
  - **`edition`**: The Rust language edition to use (e.g., "2021"), enabling specific language features.

```toml
[dependencies]
actix-web = "4"
actix-cors = "0.6"
env_logger = "0.10"
log = "0.4"
dotenv = "0.15" # For loading .env during local development
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"

# Example: SQLite driver (sqlx)
sqlx = { version = "0.7", features = [ "runtime-tokio-rustls", "sqlite", "macros", "migrate" ] }
```

- **`[dependencies]`**: Section listing the crates (libraries) the project depends on to compile and run.
  - **`actix-web = "4"`**: The core Actix web framework.
  - **`actix-cors = "0.6"`**: Middleware for handling Cross-Origin Resource Sharing (CORS) headers in Actix.
  - **`env_logger = "0.10"`**: A logger implementation that configures itself via environment variables (like `RUST_LOG`).
  - **`log = "0.4"`**: A generic logging facade (API). `env_logger` provides the implementation.
  - **`dotenv = "0.15"`**: A utility to load environment variables from a `.env` file into the application's environment, primarily used for local development (as noted by the comment and conditional compilation in `main.rs`).
  - **`serde = { ... }`**: A popular framework for serializing and deserializing Rust data structures efficiently. The `derive` feature enables automatic implementation of `Serialize` and `Deserialize` traits using macros.
  - **`serde_json = "1.0"`**: Provides JSON serialization/deserialization support for Serde.
  - **`sqlx = { ... }`**: An asynchronous SQL toolkit. The features enable:
    - `runtime-tokio-rustls`: Integration with the Tokio async runtime and use of Rustls for TLS.
    - `sqlite`: Support for the SQLite database.
    - `macros`: Compile-time SQL query checking and other helpful macros.
    - `migrate`: Support for database migrations. (Note: `sqlx` usage is commented out in `main.rs`).

```toml
[dev-dependencies]
# Add test dependencies here
```

- **`[dev-dependencies]`**: Section listing crates needed only for running tests, examples, or benchmarks. They are not included in release builds.

---

### 4. `main.rs` (Backend/src)

This is the main source file for the Rust Actix backend application.

```rust
use actix_web::{get, App, HttpServer, Responder};
//use actix_web::http::header; // Commented out import
use env_logger::Env;
//use sqlx::sqlite::SqlitePoolOptions; // Commented out import
use std::env;
use std::path::Path;
use std::fs; // Added for create_dir_all
```

- **`use ...;`**: Imports necessary items (structs, functions, traits, macros) from external crates or standard library modules into the current scope.

```rust
#[get("/")]
async fn hello() -> impl Responder {
    "Hello from Actix Backend!"
}
```

- **`#[get("/")]`**: An Actix macro that registers the following function (`hello`) to handle HTTP GET requests made to the root path (`/`).
- **`async fn hello() -> impl Responder`**: Defines an asynchronous function named `hello`. It takes no arguments and returns a type that implements the `Responder` trait (Actix knows how to convert this into an HTTP response). Here, it simply returns a static string literal.

```rust
#[get("/config")]
async fn config() -> impl Responder {
    let db_url = env::var("DATABASE_URL").unwrap_or_else(|_| "Not Set".to_string());
    let port = env::var("APP_PORT").unwrap_or_else(|_| "Not Set".to_string());
    format!("DB URL: {}, Internal Port: {}", db_url, port)
}
```

- **`#[get("/config")]`**: Registers this function to handle GET requests to `/config`.
- **`async fn config() -> impl Responder`**: An async function that reads the `DATABASE_URL` and `APP_PORT` environment variables. `unwrap_or_else` provides a default value ("Not Set") if the variable isn't found. It returns a formatted string containing these values, useful for verifying configuration inside the running container.

```rust
#[actix_web::main]
async fn main() -> std::io::Result<()> {
```

- **`#[actix_web::main]`**: A macro that sets up the Tokio asynchronous runtime needed by Actix and makes the `main` function async.
- **`async fn main() -> std::io::Result<()>`**: The main entry point of the application. It's async due to the macro and server operations. It returns `std::io::Result<()>` because operations like binding to a network port can fail with I/O errors.

```rust
    env_logger::init_from_env(Env::default().default_filter_or("info"));
```

- **`env_logger::init_from_env(...)`**: Initializes the logger. It reads the `RUST_LOG` environment variable to configure logging levels. If `RUST_LOG` is not set, it defaults to showing logs at `info` level and above (`default_filter_or("info")`).

```rust
    #[cfg(debug_assertions)]
    dotenv::dotenv().ok();
```

- **`#[cfg(debug_assertions)]`**: A conditional compilation attribute. The code inside this block (`dotenv::dotenv().ok();`) is only included in _debug_ builds (e.g., when running `cargo run`). It's excluded from release builds (`cargo build --release`).
- **`dotenv::dotenv().ok();`**: Attempts to load environment variables from a `.env` file in the current or parent directories. `.ok()` converts the `Result` into an `Option`, effectively ignoring any errors (e.g., if the `.env` file doesn't exist). This is useful for local development but avoided in production/Docker where env vars should be explicitly set.

```rust
    let database_url = env::var("DATABASE_URL").expect("DATABASE_URL must be set");
    let port_str = env::var("APP_PORT").unwrap_or_else(|_| "8080".to_string());
    let port = port_str
        .parse::<u16>()
        .expect("APP_PORT must be a valid port number");
```

- Reads the `DATABASE_URL` environment variable. `.expect()` causes the program to panic and exit if the variable is not set.
- Reads the `APP_PORT` environment variable, defaulting to "8080" if not set.
- Parses the `port_str` into a `u16` (unsigned 16-bit integer) suitable for port numbers. `.expect()` panics if the string is not a valid number.

```rust
    log::info!("Starting backend server...");
    log::info!("Internal Port: {}", port);
    log::info!("Database URL: {}", database_url);
```

- **`log::info!(...)`**: Uses the logging facade to print informational messages to the console/log output, showing the port and database URL being used.

```rust
    if database_url.starts_with("sqlite:") {

        let db_path_str = database_url.trim_start_matches("sqlite:");
        let db_path = Path::new(db_path_str);

        if let Some(parent_dir) = db_path.parent() {
            if !parent_dir.exists() {
                log::info!("Creating database directory: {:?}", parent_dir);
                // Use std::fs::create_dir_all which is idempotent (doesn't error if dir exists)
                std::fs::create_dir_all(parent_dir)?; // The '?' propagates potential I/O errors
                log::info!("Database directory created (or already exists).");
            }
        }
    }
```

- **`if database_url.starts_with("sqlite:")`**: Checks if the configured database is SQLite.
- **`let db_path_str = ...`**: Extracts the file path part from the `DATABASE_URL` (e.g., `/app/data/whoknows.db`).
- **`let db_path = Path::new(...)`**: Creates a `Path` object representing the database file location.
- **`if let Some(parent_dir) = db_path.parent()`**: Gets the parent directory of the database file (e.g., `/app/data`).
- **`if !parent_dir.exists()`**: Checks if this directory does _not_ exist.
- **`std::fs::create_dir_all(parent_dir)?`**: If the directory doesn't exist, this creates it, including any necessary parent directories (`/app` in this case). The `?` operator is used for error handling: if `create_dir_all` returns an `Err`, the error will be propagated, causing the `main` function to return the `std::io::Error`. This is crucial because SQLite needs the directory to exist before it can create the database file.

```rust
       // Create connection pool (COMMENTED OUT)
    //    let pool = SqlitePoolOptions::new()
    //         .max_connections(5)
    //         .connect(&database_url) // creates the file if not exists (requires directory to exist!)
    //         .await
    //         .expect("Failed to create SQLite connection pool."); // Will panic if dir doesn't exist or permissions fail
    //     log::info!("Database connection pool created.");
```

- **Commented-out `sqlx` code**: This block shows how you _would_ initialize a `sqlx` connection pool for SQLite if you were using it. `connect` would attempt to open (and create if missing) the database file specified in `database_url`. This operation requires the parent directory to exist, hence the directory creation logic above it.

```rust
    HttpServer::new(move || {
        App::new()
            //.app_data(web::Data::new(pool.clone())) // Share pool with handlers (COMMENTED OUT)
            .service(hello)
            .service(config)
    })
    .bind(("0.0.0.0", port))?
    .run()
    .await
}
```

- **`HttpServer::new(move || { ... })`**: Creates a new Actix HTTP server. It takes a closure (the part inside `|| { ... }`) as an argument. This closure acts as an "application factory" - it's called for each worker thread the server spawns, and it must return an `App` instance. `move` captures variables from the surrounding scope (like `port`, or `pool` if it were used) by value.
- **`App::new()`**: Creates a new Actix application instance within the factory closure.
- **`.app_data(...)`**: (Commented out) This is how you would share application state (like a database connection pool) with your route handlers. `web::Data` is a smart pointer for shared state.
- **`.service(hello)`**: Registers the `hello` function (defined earlier with `#[get("/")]`) as a route handler in the application.
- **`.service(config)`**: Registers the `config` function.
- **`.bind(("0.0.0.0", port))?`**: Tells the server to listen for incoming connections on all available network interfaces (`0.0.0.0`) inside the container, using the `port` determined earlier (default 8080). The `?` propagates any I/O error if binding fails (e.g., port already in use).
- **`.run()`**: Starts the server, spawning worker threads to handle requests.
- **`.await`**: Since `run()` returns a Future, `.await` is used to pause the `main` function and allow the server to run until it's stopped or encounters a fatal error.

---

**In Summary:**

1.  **`docker-compose.yml`** orchestrates the deployment, defining the `backend` (Rust) and `frontend` (Nginx likely) services. It manages their images, configuration (via environment variables from `.env`), networking (`app-network` allowing `frontend` to call `backend`), port mapping (`frontend` exposed to host), and data persistence (`db_data` volume for the backend's SQLite DB).
2.  **`Dockerfile`** builds the `backend` image efficiently using multi-stage builds. It compiles the Rust code in a `builder` stage with caching optimizations and then copies _only_ the final binary and necessary runtime dependencies into a minimal `debian:bookworm-slim` image.
3.  **`Cargo.toml`** lists the Rust dependencies needed for the backend, including the Actix web framework, logging, serialization, and (optionally) the `sqlx` database library.
4.  **`main.rs`** contains the Rust application logic. It sets up logging, reads configuration from environment variables, ensures the SQLite database directory exists, defines HTTP route handlers (`/` and `/config`), and starts the Actix web server listening on the configured internal port (`APP_PORT`).
