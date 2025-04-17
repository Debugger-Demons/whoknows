use actix_files as fs;
use actix_web::{get, middleware, web, App, HttpResponse, HttpServer};
use log::info;
use std::env;

#[get("/api/health")]
async fn health_check() -> HttpResponse {
    HttpResponse::Ok().json(serde_json::json!({
        "status": "ok",
        "service": "frontend"
    }))
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    dotenv::dotenv().ok();

    env_logger::init_from_env(env_logger::Env::new().default_filter_or("info"));

    let frontend_port = env::var("FRONTEND_INTERNAL_PORT").unwrap_or_else(|_| "4040".to_string());
    let backend_port = env::var("BACKEND_INTERNAL_PORT").unwrap_or_else(|_| "5050".to_string());
    let host = "http://localhost:";

    // Get backend URL from environment or use default
    let backend_url =
        env::var("BACKEND_URL").unwrap_or_else(|_| format!("{}{}", host, backend_port));

    info!("Starting server at http://0.0.0.0:8080");
    info!("Using backend at {}", backend_url);

    HttpServer::new(move || {
        App::new()
            .wrap(middleware::Logger::default())
            .service(health_check)
            // Serve static files from the 'static' directory
            .service(fs::Files::new("/static", "./static").show_files_listing())
            // Serve HTML files from the root directory
            .service(
                fs::Files::new("/", "./static/html")
                    .index_file("search.html")
                    .default_handler(web::to(|| async {
                        HttpResponse::NotFound().body("Not Found")
                    })),
            )
    })
    .bind(format!("0.0.0.0:{}", frontend_port))?
    .run()
    .await
}
