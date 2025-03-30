// backend/src/main.rs
use actix_web::{get, web, App,HttpResponse, HttpServer, Responder};
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

#[get("/")]
async fn hello() -> impl Responder {
    "Hello from Actix Backend!"
}

#[get("/config")]
async fn config() -> impl Responder {
    let db_url = env::var("DATABASE_URL").unwrap_or_else(|_| "Not Set".to_string());
    let port = env::var("BACKEND_PORT").unwrap_or_else(|_| "Not Set".to_string());
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
    env_logger::init();

    let port_str = env::var("BACKEND_PORT").unwrap_or_else(|_| "8080".to_string());
    let port = port_str
        .parse::<u16>()
        .expect("APP_PORT must be a valid port number");

    HttpServer::new(move || {
        App::new()
            .service(hello)
            .service(config)
            .service(health)
    })
    .bind(("0.0.0.0", port))?
    .run()
    .await
}
