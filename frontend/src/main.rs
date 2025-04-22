use actix_files as files;
use actix_web::dev::{forward_ready, Service, ServiceRequest, ServiceResponse, Transform};
use actix_web::{get, http, middleware, web, App, Error, HttpResponse, HttpServer, Responder};
use actix_web::body::{EitherBody, MessageBody};
use actix_cors::Cors;
use awc::Client;
use futures::future::{self, Either, LocalBoxFuture, Ready};
use log::{info, error};
use std::env;
use std::fs;
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
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error> + 'static,
    S::Future: 'static,
    B: MessageBody + 'static,
{
    type Response = ServiceResponse<EitherBody<B>>;
    type Error = Error;
    type Transform = ApiProxyMiddleware<S>;
    type InitError = ();
    type Future = Ready<Result<Self::Transform, Self::InitError>>;

    fn new_transform(&self, service: S) -> Self::Future {
        future::ok(ApiProxyMiddleware {
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
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error> + 'static,
    S::Future: 'static,
    B: MessageBody + 'static,
{
    type Response = ServiceResponse<EitherBody<B>>;
    type Error = Error;
    type Future = LocalBoxFuture<'static, Result<Self::Response, Self::Error>>;

    forward_ready!(service);

    fn call(&self, req: ServiceRequest) -> Self::Future {
        // Only proxy requests starting with /api/
        if req.path().starts_with("/api/")
            && req.path() != "/api/health"
            && req.path() != "/api/config"
            && req.path() != "/api/login"
            && req.path() != "/api/logout"
            && req.path() != "/api/register"
        {
            let client = self.client.clone();
            let backend_url = self.backend_url.clone();
            let path = req.path().to_string();
            let query = req.query_string().to_string();
            let method = req.method().clone();
            let headers = req.headers().clone();
            
            // Get request body if present
            let (request, payload) = req.into_parts();
            
            // Create backend URL with query params if present
            let backend_req_url = if query.is_empty() {
                format!("{}{}", backend_url, path)
            } else {
                format!("{}{}?{}", backend_url, path, query)
            };
            
            info!("Proxying request to backend: {}", backend_req_url);
            
            // Create a boxed future for the proxy request
            Box::pin(async move {
                // Create a client request
                let mut client_req = client
                    .request(method, &backend_req_url)
                    .no_decompress();
                    
                // Copy headers from original request
                for (header_name, header_value) in headers.iter().filter(|(h, _)| 
                    // Skip headers that might cause issues
                    *h != http::header::HOST 
                    && *h != http::header::CONNECTION
                    && *h != http::header::CONTENT_LENGTH
                ) {
                    client_req = client_req.insert_header((header_name.clone(), header_value.clone()));
                }
                
                // Send the request with the stream payload
                let backend_response = client_req
                    .send_stream(payload)
                    .await;
                
                match backend_response {
                    Ok(mut res) => {
                        // Create a response for the client based on the backend response
                        let mut client_resp = HttpResponse::build(res.status());
                        
                        // Copy headers from backend response
                        for (header_name, header_value) in res.headers().iter().filter(|(h, _)| 
                            *h != http::header::CONNECTION
                            && *h != http::header::CONTENT_LENGTH
                        ) {
                            client_resp.insert_header((header_name.clone(), header_value.clone()));
                        }
                        
                        // Get the response body
                        let bytes = res.body().await?;
                        
                        // Create the ServiceResponse with EitherBody
                        Ok(ServiceResponse::new(
                            request, 
                            client_resp.body(bytes).map_into_right_body())
                        )
                    },
                    Err(e) => {
                        error!("Backend request error: {}", e);
                        let error_response = HttpResponse::ServiceUnavailable()
                            .content_type("application/json")
                            .body(format!("{{\"error\": \"Backend service unavailable: {}\"}}", e))
                            .map_into_right_body();
                        
                        Ok(ServiceResponse::new(request, error_response))
                    }
                }
            })
        } else {
            // Pass other requests to the next service
            let res = self.service.call(req);
            
            Box::pin(async move {
                let res = res.await?;
                // Convert to EitherBody
                Ok(res.map_into_left_body())
            })
        }
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
            .wrap(Cors::default()
                    // Read your frontend URL(s) from config or env, never use `allow_any_origin` in prod
                    .allowed_origin(&std::env::var("FRONTEND_URL")
                        .unwrap_or_else(|_| "http://localhost:8080".into()))
                    .allowed_methods(vec!["GET", "POST"])
                    .allowed_headers(vec![
                        http::header::AUTHORIZATION,
                        http::header::ACCEPT,
                    ])
                    .allowed_header(http::header::CONTENT_TYPE)
                    .expose_headers(&[http::header::CONTENT_DISPOSITION])
                    // Enable credentials only if needed (cookies / auth)
                    .supports_credentials()
                    .max_age(3600)
            )
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
