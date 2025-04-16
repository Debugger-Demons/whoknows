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
use sqlx::{FromRow, SqlitePool}; // Keep FromRow for the struct, even if not used by query_as! here

// --- Date/Time ---
use chrono::NaiveDateTime; // Only import NaiveDateTime for now

// --- Logging ---
use log;

// --- Struct Definitions ---

#[derive(Deserialize, Debug)]
struct SearchQuery {
    q: Option<String>,
    language: Option<String>,
}

// Still derive FromRow and Serialize for general usefulness and potential future use
#[derive(Serialize, FromRow, Debug, Clone)]
struct Page {
    title: String,
    url: String,
    language: String,
    last_updated: Option<NaiveDateTime>,
    content: String,
}

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

#[get("/api/login")]
async fn get_login() -> impl Responder {
    HttpResponse::Ok().body("Login page placeholder")
}

#[post("/api/login")]
async fn post_login() -> impl Responder {
    HttpResponse::Ok().body("Login POST placeholder")
}

#[get("/api/logout")]
async fn get_logout() -> impl Responder {
    HttpResponse::Ok().body("Logout placeholder")
}

#[get("/api/register")]
async fn get_register() -> impl Responder {
    HttpResponse::Ok().body("Register page placeholder")
}

#[post("/api/register")]
async fn post_register() -> impl Responder {
    HttpResponse::Ok().body("Register POST placeholder")
}

#[get("/api/search")]
async fn get_search(pool: web::Data<SqlitePool>, query: web::Query<SearchQuery>) -> impl Responder {
    let search_term = query.q.as_deref().unwrap_or("");
    let language = query.language.as_deref().unwrap_or("en");

    if search_term.is_empty() {
        return HttpResponse::Ok().json(serde_json::json!({ "search_results": [] }));
    }

    let pattern = format!("%{}%", search_term);

    // --- UPDATED: Use query! and manual mapping ---
    match sqlx::query!(
        // Select columns explicitly
        "SELECT title, url, language, last_updated, content FROM pages WHERE language = ?1 AND content LIKE ?2",
        // Bind parameters by position
        language, // ?1
        pattern   // ?2
    )
    .fetch_all(pool.get_ref()) // Execute and fetch all records
    .await // Await the async operation
    {
                 Ok(records) => {
            // Manually map the fetched records to the Page struct
            let pages: Vec<Page> = records.into_iter().map(|rec| {
                    Page {
                        // Apply .expect because the compiler insists rec.title is Option<String>
                        title: rec.title.expect("Database schema violation: title should be NOT NULL"),
                        // Leave others as direct assignment (assuming they were String previously)
                        url: rec.url,
                        language: rec.language,
                        // last_updated is correctly Option<NaiveDateTime>
                        last_updated: rec.last_updated,
                        content: rec.content,
                    }
                }).collect();

            HttpResponse::Ok().json(serde_json::json!({ "search_results": pages }))
        },
        Err(e) => {
            log::error!("Failed to execute search query: {:?}", e);
            HttpResponse::InternalServerError().json(serde_json::json!({ "error": "Database query failed" }))
        }
    }
    // --- End of UPDATED block ---
}

#[post("/api/search")]
async fn post_search() -> impl Responder {
    HttpResponse::MethodNotAllowed().finish()
}

#[get("/api/weather")]
async fn get_weather() -> impl Responder {
    HttpResponse::Ok().body("Weather GET placeholder")
}

#[post("/api/weather")]
async fn post_weather() -> impl Responder {
    HttpResponse::Ok().body("Weather POST placeholder")
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    env_logger::init_from_env(env_logger::Env::new().default_filter_or("info"));

    let port_str = env::var("BACKEND_INTERNAL_PORT").unwrap_or_else(|_| "8080".to_string());
    let port = port_str
        .parse::<u16>()
        .expect("BACKEND_INTERNAL_PORT must be a valid port number");

    log::info!("Server starting at http://{}:{}", HOST_NAME, port);

    dotenv::dotenv().ok();
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

    HttpServer::new(move || {
        let cors = Cors::default()
            .allow_any_origin()
            .allow_any_method()
            .allow_any_header();

        App::new()
            .app_data(web::Data::new(pool.clone()))
            .wrap(cors)
            .service(hello)
            .service(config)
            .service(get_about)
            .service(get_login)
            .service(post_login)
            .service(get_register)
            .service(post_register)
            .service(get_logout)
            .service(get_search) // Should work now
            .service(post_search)
            .service(get_weather)
            .service(post_weather)
    })
    .bind((HOST_NAME, port))?
    .run()
    .await
}
