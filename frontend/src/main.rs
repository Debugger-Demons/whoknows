use actix_files as files;
use actix_web::{get, middleware, web, App, HttpResponse, HttpServer};
use log::info;
use std::env;
use std::fs;

#[get("/api/health")]
async fn health_check() -> HttpResponse {
    HttpResponse::Ok().json(serde_json::json!({
        "status": "ok",
        "service": "frontend"
    }))
}

#[get("/api/config")]
async fn get_config() -> HttpResponse {
    let backend_port = env::var("BACKEND_INTERNAL_PORT").unwrap_or_else(|_| "92".to_string());

    HttpResponse::Ok().json(serde_json::json!({
        "BACKEND_URL": format!("http://backend:{}", backend_port)
    }))
}

#[get("/static/js/api_config.js")]
async fn api_config() -> HttpResponse {
    let backend_port = env::var("BACKEND_INTERNAL_PORT").unwrap_or_else(|_| "92".to_string());

    let js_content = format!("window.BACKEND_URL = 'http://backend:{}';\n", backend_port);

    HttpResponse::Ok()
        .content_type("application/javascript")
        .body(js_content)
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    dotenv::dotenv().ok();

    env_logger::init_from_env(env_logger::Env::new().default_filter_or("info"));

    let frontend_port = env::var("FRONTEND_INTERNAL_PORT").unwrap_or_else(|_| "91".to_string());
    let backend_port = env::var("BACKEND_INTERNAL_PORT").unwrap_or_else(|_| "92".to_string());

    let env_js = format!("window.BACKEND_URL = 'http://backend:{}';\n", backend_port);

    fs::write("./static/js/environment.js", env_js)?;

    info!("Starting server at http://0.0.0.0:{}", frontend_port);
    info!("Using backend at http://0.0.0.0:{}", backend_port);

    HttpServer::new(move || {
        App::new()
            .wrap(middleware::Logger::default())
            .service(health_check)
            .service(get_config)
            .service(api_config)
            // Serve static files from the 'static' directory
            .service(files::Files::new("/static", "./static").show_files_listing())
            // Serve HTML files from the root directory
            .service(
                files::Files::new("/", "./static/html")
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
