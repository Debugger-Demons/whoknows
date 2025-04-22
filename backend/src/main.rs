// backend/src/main.rs

// --- Essential Actix and Web Imports ---
use actix_cors::Cors;
use actix_web::{get, post, web, App, HttpResponse, HttpServer, Responder};
use std::env;

// --- Serialization/Deserialization ---
use serde::{Deserialize, Serialize};
use serde_json;

// --- Database (Sqlx) ---
use sqlx::sqlite::SqlitePoolOptions;
use sqlx::{FromRow, SqlitePool};

// --- Date/Time ---
use chrono::NaiveDateTime;

// --- Logging ---
use log;

// --- Session/Cookies/Flash ---
use actix_session::{storage::CookieSessionStore, Session, SessionMiddleware}; // Added SessionMiddleware back
use actix_web::cookie::{Key, SameSite}; // Kept SameSite
use actix_web_flash_messages::{storage::CookieMessageStore, FlashMessage, FlashMessagesFramework};

// --- Password Hashing & Randomness ---
use argon2::{
    // Added PasswordHash back, kept PasswordVerifier
    password_hash::{rand_core::OsRng, PasswordHash, PasswordHasher, PasswordVerifier, SaltString},
    Argon2,
};
// --- Hex Decoding for Key ---
use hex; // Import the hex crate

// --- Struct Definitions ---

#[derive(Deserialize, Debug)]
struct SearchQuery {
    q: Option<String>,
    language: Option<String>,
}

#[derive(Serialize, FromRow, Debug, Clone)]
struct Page {
    title: String,
    url: String,
    language: String,
    last_updated: Option<NaiveDateTime>,
    content: String,
}

-Page {
-    title: rec.title.expect("Database schema violation: title should be NOT NULL"),
-    url: rec.url,
-    language: rec.language,
-    last_updated: rec.last_updated,
-    content: rec.content,
-}
+Page {
+    title: rec
+        .title
+        .expect("DB invariant violated: pages.title is NULL"),
+    url: rec
+        .url
+        .expect("DB invariant violated: pages.url is NULL"),
+    language: rec
+        .language
+        .expect("DB invariant violated: pages.language is NULL"),
+    last_updated: rec.last_updated,
+    content: rec
+        .content
+        .expect("DB invariant violated: pages.content is NULL"),
+}

#[derive(Serialize, Deserialize, FromRow, Debug, Clone)]
struct User {
    id: i64,
    username: String,
    email: String,
    password: String,
}

#[derive(Serialize)]
struct ConfigResponse {
    db_url: String,
    port: String,
    environment: String,
    build_version: String,
}

#[derive(Deserialize, Debug)]
struct RegistrationForm {
    username: String,
    email: String,
    password: String,
    password2: String,
}

#[derive(Deserialize, Debug)]
struct LoginForm {
    username: String,
    password: String,
}

// --- Helper Functions ---
fn hash_password(password: &str) -> Result<String, argon2::password_hash::Error> {
    let salt = SaltString::generate(&mut OsRng);
    let argon2 = Argon2::default();
    let password_hash = argon2
        .hash_password(password.as_bytes(), &salt)?
        .to_string();
    Ok(password_hash)
}

fn verify_password(
    stored_hash: &str,
    password_provided: &str,
) -> Result<bool, argon2::password_hash::Error> {
    // Use PasswordHash here - FIXED
    let parsed_hash = PasswordHash::new(stored_hash)?;
    Ok(Argon2::default()
        .verify_password(password_provided.as_bytes(), &parsed_hash)
        .is_ok())
}

// --- Configuration ---
const HOST_NAME: &str = "0.0.0.0";

// --- Handlers ---

#[get("/")]
async fn hello() -> impl Responder {
    HttpResponse::Ok().body("Hello from Actix Backend!")
}

#[get("/api/about")]
async fn get_about() -> impl Responder {
    HttpResponse::Ok().body("About page placeholder")
}

#[get("/config")]
async fn config() -> impl Responder {
    let db_url = env::var("DATABASE_URL").unwrap_or_else(|_| "Not Set".to_string());
    let port = env::var("BACKEND_INTERNAL_PORT").unwrap_or_else(|_| "Not Set".to_string());
    let environment = env::var("RUST_LOG").unwrap_or_else(|_| "Not Set".to_string());
    let build_version = env::var("BUILD_VERSION").unwrap_or_else(|_| "dev".to_string());

    web::Json(ConfigResponse {
        db_url,
        port,
        environment,
        build_version,
    })
}

#[post("/api/login")]
async fn post_login(
    pool: web::Data<SqlitePool>,
    payload: web::Json<LoginForm>,
    session: Session,
) -> impl Responder {
    let login_data = payload.into_inner();

    if login_data.username.trim().is_empty() || login_data.password.is_empty() {
        return HttpResponse::BadRequest()
            .json(serde_json::json!({"error": "Username and password cannot be empty"}));
    }

    let username = login_data.username.trim();

    // --- Find User by Username --- Using sqlx::query! ---
    match sqlx::query!(
        "SELECT id, username, email, password FROM users WHERE username = ?",
        username
    )
    .fetch_optional(pool.get_ref())
    .await
    {
        Ok(Some(record)) => {
            // --- Assign directly where type is String, expect for id --- FIXED ---
            let user_id = record.id.expect("DB schema violation: id is NULL"); // Keep expect for id
            let user_password = record.password; // REMOVED .expect - already String
            let user_username = record.username; // REMOVED .expect - already String
            let user_email = record.email; // REMOVED .expect - already String

            match verify_password(&user_password, &login_data.password) {
                Ok(true) => {
                    log::info!("User '{}' logged in successfully.", user_username);
                    if let Err(e) = session.insert("user_id", user_id) {
                        log::error!("Failed to insert user_id into session: {:?}", e);
                        return HttpResponse::InternalServerError()
                            .json(serde_json::json!({"error": "Login failed (session error)"}));
                    }
                    FlashMessage::info("You were logged in!").send();
                    HttpResponse::Ok().json(serde_json::json!({
                        "message": "Login successful",
                        "user": {
                            "id": user_id,
                            "username": user_username,
                            "email": user_email
                        }
                    }))
                }
                Ok(false) => {
                    log::warn!(
                        "Failed login attempt for user '{}': Invalid password.",
                        user_username
                    );
                    HttpResponse::Unauthorized()
                        .json(serde_json::json!({"error": "Invalid username or password"}))
                }
                Err(e) => {
                    log::error!(
                        "Password verification process failed for user '{}': {:?}",
                        user_username,
                        e
                    );
                    HttpResponse::InternalServerError()
                        .json(serde_json::json!({"error": "Login failed (verification error)"}))
                }
            }
        }
        Ok(None) => {
            log::warn!("Failed login attempt: Username '{}' not found.", username);
            HttpResponse::Unauthorized()
                .json(serde_json::json!({"error": "Invalid username or password"}))
        }
        Err(e) => {
            log::error!(
                "Database error during login for username '{}': {:?}",
                username,
                e
            );
            HttpResponse::InternalServerError()
                .json(serde_json::json!({"error": "Login failed (database error)"}))
        }
    }
    // --- End of User Find/Verify Block ---
}

#[get("/api/logout")]
async fn get_logout(session: Session) -> impl Responder {
    // Inject the Session object
    log::info!("Logout request received.");

    // Clear the session data.
    // purge() invalidates the session state contained in the cookie.
    session.purge();
    log::info!("Session purged.");

    // Send a flash message indicating successful logout.
    FlashMessage::info("You were logged out").send();

    // Return a simple success response.
    // Clients might redirect based on this or just update UI state.
    HttpResponse::Ok().json(serde_json::json!({"message": "Logout successful"}))
}

#[post("/api/register")]
async fn post_register(
    pool: web::Data<SqlitePool>,
    payload: web::Json<RegistrationForm>,
) -> impl Responder {
    let registration_data = payload.into_inner();

    if registration_data.username.trim().is_empty() {
        return HttpResponse::BadRequest()
            .json(serde_json::json!({"error": "Username cannot be empty"}));
    }
    if registration_data.email.trim().is_empty() || !registration_data.email.contains('@') {
        return HttpResponse::BadRequest()
            .json(serde_json::json!({"error": "Invalid email address"}));
    }
    if registration_data.password.is_empty() {
        return HttpResponse::BadRequest()
            .json(serde_json::json!({"error": "Password cannot be empty"}));
    }
    if registration_data.password != registration_data.password2 {
        return HttpResponse::BadRequest()
            .json(serde_json::json!({"error": "Passwords do not match"}));
    }

    let username = registration_data.username.trim();
    let email = registration_data.email.trim();

    match sqlx::query!(
        "SELECT id FROM users WHERE username = ? OR email = ? LIMIT 1",
        username,
        email
    )
    .fetch_optional(pool.get_ref())
    .await
    {
        Ok(Some(_record_with_id)) => {
            match sqlx::query!(
                "SELECT username, email FROM users WHERE username = ? OR email = ?",
                username,
                email
            )
            .fetch_one(pool.get_ref())
            .await
            {
                Ok(existing_user) => {
                    let reason = if existing_user.username.eq_ignore_ascii_case(username) {
                        "Username already taken"
                    } else {
                        "Email already registered"
                    };
                    log::warn!(
                        "Registration conflict for username '{}': {}",
                        username,
                        reason
                    );
                    return HttpResponse::Conflict().json(serde_json::json!({"error": reason}));
                }
                Err(e) => {
                    log::error!("Database error fetching existing user details: {:?}", e);
                    return HttpResponse::InternalServerError()
                        .json(serde_json::json!({"error": "Database error during validation"}));
                }
            }
        }
        Ok(None) => {
            log::info!(
                "Username '{}' and email '{}' available for registration.",
                username,
                email
            );
        }
        Err(e) => {
            log::error!("Database error checking for existing user: {:?}", e);
            return HttpResponse::InternalServerError()
                .json(serde_json::json!({"error": "Database error checking user"}));
        }
    }

    let hashed_password = match hash_password(&registration_data.password) {
        Ok(hash) => hash,
        Err(e) => {
            log::error!("Password hashing failed: {:?}", e);
            return HttpResponse::InternalServerError()
                .json(serde_json::json!({"error": "Failed to process password"}));
        }
    };

    match sqlx::query!(
        "INSERT INTO users (username, email, password) VALUES (?, ?, ?)",
        username,
        email,
        hashed_password
    )
    .execute(pool.get_ref())
    .await
    {
        Ok(result) => {
            if result.rows_affected() == 1 {
                log::info!("User '{}' registered successfully.", username);
                HttpResponse::Created().json(serde_json::json!({
                    "message": "User registered successfully"
                }))
            } else {
                log::error!(
                    "User insertion query succeeded but did not affect any rows for username '{}'.",
                    username
                );
                HttpResponse::InternalServerError()
                    .json(serde_json::json!({"error": "Registration failed unexpectedly"}))
            }
        }
        Err(e) => {
            log::error!("Failed to insert new user '{}': {:?}", username, e);
            HttpResponse::InternalServerError()
                .json(serde_json::json!({"error": "Database error during registration"}))
        }
    }
}

#[get("/api/search")]
async fn get_search(pool: web::Data<SqlitePool>, query: web::Query<SearchQuery>) -> impl Responder {
    let search_term = query.q.as_deref().unwrap_or("");
    let language = query.language.as_deref().unwrap_or("en");

    if search_term.is_empty() {
        return HttpResponse::Ok().json(serde_json::json!({ "search_results": [] }));
    }

    let pattern = format!("%{}%", search_term);

    match sqlx::query!(
        "SELECT title, url, language, last_updated, content FROM pages WHERE language = ?1 AND content LIKE ?2",
        language,
        pattern
    )
    .fetch_all(pool.get_ref())
    .await
    {
                 Ok(records) => {
            let pages: Vec<Page> = records.into_iter().map(|rec| {
                    Page {
                        title: rec
                            .title
                            .expect("DB invariant violated: pages.title is NULL"),
                        url: rec
                            .url
                            .expect("DB invariant violated: pages.url is NULL"),
                        language: rec
                            .language
                            .expect("DB invariant violated: pages.language is NULL"),
                        last_updated: rec.last_updated,
                        content: rec
                            .content
                            .expect("DB invariant violated: pages.content is NULL"),
                    }
                }).collect();
            HttpResponse::Ok().json(serde_json::json!({ "search_results": pages }))
        },
        Err(e) => {
            log::error!("Failed to execute search query: {:?}", e);
            HttpResponse::InternalServerError().json(serde_json::json!({ "error": "Database query failed" }))
        }
    }
}

#[get("/api/weather")]
async fn get_weather() -> impl Responder {
    HttpResponse::Ok().body("Weather GET placeholder")
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    dotenv::dotenv().ok();

    env_logger::init_from_env(env_logger::Env::new().default_filter_or("info"));

    let port_str = env::var("BACKEND_INTERNAL_PORT").unwrap_or_else(|_| "8080".to_string());
    let port = port_str
        .parse::<u16>()
        .expect("BACKEND_INTERNAL_PORT must be a valid port number");

    println!("Server starting at http://{}:{}", HOST_NAME, port);
    log::info!("Server starting at http://{}:{}", HOST_NAME, port);

    let database_url =
        env::var("DATABASE_URL").expect("DATABASE_URL must be set in environment or .env file");

    let pool = match SqlitePoolOptions::new()
        .max_connections(5)
        .connect(&database_url)
        .await
    {
        Ok(p) => {
            log::info!("Successfully connected to the database at {}", database_url);
            p
        }
        Err(e) => {
            log::error!("Failed to connect to the database: {}", e);
            std::process::exit(1);
        }
    };

    // --- Load Session Key ---
    let session_secret_key_hex =
        env::var("SESSION_SECRET_KEY").expect("SESSION_SECRET_KEY must be set...");

    // println!(
    //     "Read SESSION_SECRET_KEY (length {}): {}",
    //     session_secret_key_hex.len(),
    //     session_secret_key_hex.chars().take(10).collect::<String>()
    // );

    let decoded_key_bytes = match hex::decode(&session_secret_key_hex) {
        Ok(bytes) => {
            println!(
                "Successfully decoded hex key to bytes (length: {})",
                bytes.len()
            );
            bytes
        }
        Err(e) => {
            println!("!!! FAILED to decode hex key: {:?}", e);
            panic!("SESSION_SECRET_KEY decoding failed: {:?}", e);
        }
    };

    let key_array: [u8; 32] = match decoded_key_bytes.try_into() {
        Ok(array) => {
            println!("Successfully converted Vec<u8> to [u8; 32]");
            array
        }
        Err(vec) => {
            println!(
                "!!! FAILED to convert Vec<u8> to [u8; 32]. Original Vec length: {}",
                vec.len()
            );
            panic!(
                "Decoded key was not exactly 32 bytes long, length was: {}",
                vec.len()
            );
        }
    };

    // --- Manually Construct Key (Workaround for potential Key::from bug) ---
    // Key internally holds encryption and signing keys.
    // For a 32-byte master key, cookie 0.16.2 splits it into two 16-byte keys.
    // Ensure the total length provided matches the key structure.
    println!("Attempting manual Key construction...");
    let session_secret_key = Key::derive_from(&key_array); // derive_from should handle splitting
    println!("Manual Key construction (derive_from) succeeded.");

    // --- Setup Flash Messages ---
    let message_store = CookieMessageStore::builder(session_secret_key.clone()).build();
    let message_framework = FlashMessagesFramework::builder(message_store).build();

    // --- Start Actix HTTP Server --- FIXED SESSION MIDDLEWARE ---
    HttpServer::new(move || {
        // --- Create Session Middleware INSIDE the closure ---
        let session_middleware = SessionMiddleware::builder(
            CookieSessionStore::default(),
            session_secret_key.clone(), // Clone the key
        )
        .cookie_secure(true) // Set true for HTTPS
        .cookie_same_site(SameSite::Lax) // Use SameSite here
        .cookie_http_only(true)
        .build();

        let cors = Cors::default()
            .allow_any_origin()
            .allow_any_method()
            .allow_any_header();

        App::new()
            .app_data(web::Data::new(pool.clone()))
            .wrap(cors)
            .wrap(message_framework.clone())
            .wrap(session_middleware) // Now this works
            .service(hello)
            .service(config)
            .service(get_about)
            .service(post_login) // Ensure registered
            .service(post_register)
            .service(get_logout)
            .service(get_search)
            .service(get_weather)
        // Removed duplicate/unused service registrations
    })
    .bind((HOST_NAME, port))?
    .run()
    .await
}
