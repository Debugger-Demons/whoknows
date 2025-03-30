// backend/src/main.rs
use actix_web::{get, post, web, App, HttpResponse, HttpServer, Responder};
use actix_cors::Cors;
use serde::Serialize;
use std::env;
use std::time::{SystemTime, UNIX_EPOCH};

#[derive(Serialize)]
struct HealthResponse {
    status: String,
    version: String,
    timestamp: u64,
}

#[derive(Serialize)]
struct ConfigResponse {
    db_url: String,
    port: String,
    environment: String,
    build_version: String,
}

const HOST_NAME: &str = "0.0.0.0";

#[get("/")]
async fn hello() -> impl Responder {
    "Hello from Actix Backend!"
}

#[get("/search")]
async fn search() -> impl Responder {
    HttpResponse::Ok().body("Search endpoint")
}

#[post("/")]
async fn add() -> impl Responder {
    HttpResponse::Ok().body("Add endpoint")
}

#[get("/weather")]
async fn weather() -> impl Responder {
    HttpResponse::Ok().body("Get weather")
}

#[get("/api/weather")]
async fn get_weather() -> impl Responder {
    HttpResponse::Ok().body("Weather API")
}

#[get("/register")]
async fn register_user() -> impl Responder {
    HttpResponse::Ok().body("Register User")
}

#[get("/api/register")]
async fn register() -> impl Responder {
    HttpResponse::Ok().body("Get register")
}

#[get("/config")]
async fn config() -> impl Responder {
    let db_url = env::var("DATABASE_URL").unwrap_or_else(|_| "Not Set".to_string());
    let port = env::var("BACKEND_INTERNAL_PORT").unwrap_or_else(|_| "Not Set".to_string());
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

#[get("/health")]
async fn health() -> impl Responder {
    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_secs();
    
    let version = env::var("BUILD_VERSION").unwrap_or_else(|_| "dev".to_string());
    
    HttpResponse::Ok().json(HealthResponse {
        status: "ok".to_string(),
        version,
        timestamp: now,
    })
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    // Initialize the logger
    env_logger::init_from_env(env_logger::Env::new().default_filter_or("info"));

    // Get port from environment variable or use default
    let port_str = env::var("BACKEND_INTERNAL_PORT").unwrap_or_else(|_| "8080".to_string());
    let port = port_str
        .parse::<u16>()
        .expect("BACKEND_INTERNAL_PORT must be a valid port number");
    
    println!("Server starting at http://{}:{}", HOST_NAME, port);

    // Start the server
    HttpServer::new(|| {
        let cors = Cors::default()
            .allow_any_origin()
            .allow_any_method()
            .allow_any_header();
            
        App::new()
            .wrap(cors)
            .service(hello)
            .service(search)
            .service(add)
            .service(weather)
            .service(get_weather)
            .service(register_user)
            .service(register)
            .service(config)
            .service(health)
    })
    .bind((HOST_NAME, port))?
    .run()
    .await
}