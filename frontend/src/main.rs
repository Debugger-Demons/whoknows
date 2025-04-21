use actix_files as files;
use actix_web::dev::{forward_ready, Service, ServiceRequest, ServiceResponse, Transform};
use actix_web::{get, http, middleware, web, App, Error, HttpResponse, HttpServer, Responder};
use awc::Client;
use futures::future::{ok, Either, Ready};
use log::info;
use std::env;
use std::fs;
use std::rc::Rc;
use std::task::{Context, Poll};

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

// Proxy middleware
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

impl<S, B> Transform<S, ServiceRequest> for ApiProxy
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error>,
    S::Future: 'static,
    B: 'static,
{
    type Response = ServiceResponse<B>;
    type Error = Error;
    type Transform = ApiProxyMiddleware<S>;
    type InitError = ();
    type Future = Ready<Result<Self::Transform, Self::InitError>>;

    fn new_transform(&self, service: S) -> Self::Future {
        ok(ApiProxyMiddleware {
            service,
            client: self.client.clone(),
            backend_url: self.backend_url.clone(),
        })
    }
}

struct ApiProxyMiddleware<S> {
    service: S,
    client: Client,
    backend_url: String,
}

impl<S, B> Service<ServiceRequest> for ApiProxyMiddleware<S>
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error>,
    S::Future: 'static,
    B: 'static,
{
    type Response = ServiceResponse<B>;
    type Error = Error;
    type Future = Either<S::Future, Ready<Result<ServiceResponse<B>, Error>>>;

    forward_ready!(service);

    fn call(&self, req: ServiceRequest) -> Self::Future {
        // Only proxy requests starting with /api/
        if req.path().starts_with("/api/")
            && req.path() != "/api/health"
            && req.path() != "/api/config"
        {
            let client = self.client.clone();
            let backend_url = self.backend_url.clone();
            let path = req.path().to_string();
            let method = req.method().clone();

            // Create backend URL
            let backend_req_url = format!("{}{}", backend_url, path);

            // For simplicity in this example, we'll just respond with a message
            // In a real implementation, you would forward the request to the backend
            // and return the response
            let response = HttpResponse::Ok()
                .content_type("application/json")
                .body(format!(
                    "{{\"message\": \"Would proxy to: {}\"}}",
                    backend_req_url
                ));

            return Either::Right(ok(req.into_response(response)));
        }

        // Pass other requests to the next service
        Either::Left(self.service.call(req))
    }
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
    info!("Using backend at http://backend:{}", backend_port);

    // Define the backend URL for proxying
    let backend_url = format!("http://backend:{}", backend_port);

    HttpServer::new(move || {
        App::new()
            .wrap(middleware::Logger::default())
            .wrap(ApiProxy::new(backend_url.clone()))
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
