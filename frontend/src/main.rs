use actix_files as files;
use actix_web::dev::{forward_ready, Service, ServiceRequest, ServiceResponse, Transform};
use actix_web::{get, http, middleware, web, App, Error, HttpResponse, HttpServer, Responder};
use actix_web::body::{EitherBody, MessageBody};
use actix_cors::Cors;
use awc::Client;
use futures::future::{self, Either, LocalBoxFuture, Ready};
use log::{info, error};
use std::env;
use std::task::{Context, Poll};

// --- Prometheus Monitoring ---
use lazy_static::lazy_static;
use prometheus::{
    register_int_counter, register_int_counter_vec, Encoder, IntCounter, IntCounterVec, TextEncoder,
};

// Query string parser crate
use querystring;

// Define constants for environment variable names
const FRONTEND_URL_KEY: &str = "FRONTEND_URL";
const BACKEND_INTERNAL_PORT_KEY: &str = "BACKEND_INTERNAL_PORT";
const FRONTEND_INTERNAL_PORT_KEY: &str = "FRONTEND_INTERNAL_PORT";

// --- Prometheus Metrics ---
lazy_static! {
    static ref HTTP_REQUESTS_TOTAL: IntCounter = register_int_counter!(
        "http_requests_total",
        "Total number of HTTP requests handled by the frontend server"
    )
    .unwrap();

    static ref SEARCH_QUERIES_TOTAL: IntCounter = register_int_counter!(
        "search_queries_total",
        "Total number of search queries made via the frontend"
    )
    .unwrap();

    static ref SEARCH_QUERIES_BY_LANG: IntCounterVec = register_int_counter_vec!(
        "search_queries_by_language_total",
        "Number of search queries made per language",
        &["language"]
    )
    .unwrap();
}

// Request counter middleware
struct RequestCounter;

impl<S, B> Transform<S, ServiceRequest> for RequestCounter
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error>,
    S::Future: 'static,
    B: 'static,
{
    type Response = ServiceResponse<B>;
    type Error = Error;
    type Transform = RequestCounterMiddleware<S>;
    type InitError = ();
    type Future = Ready<Result<Self::Transform, Self::InitError>>;

    fn new_transform(&self, service: S) -> Self::Future {
        future::ok(RequestCounterMiddleware { service })
    }
}

struct RequestCounterMiddleware<S> {
    service: S,
}

impl<S, B> Service<ServiceRequest> for RequestCounterMiddleware<S>
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error>,
    S::Future: 'static,
    B: 'static,
{
    type Response = ServiceResponse<B>;
    type Error = Error;
    type Future = LocalBoxFuture<'static, Result<Self::Response, Self::Error>>;

    forward_ready!(service);

    fn call(&self, req: ServiceRequest) -> Self::Future {
        // Increment counter for all requests
        HTTP_REQUESTS_TOTAL.inc();

        let fut = self.service.call(req);
        Box::pin(async move {
            let res = fut.await?;
            Ok(res)
        })
    }
}

#[get("/api/health")]
async fn health_check() -> HttpResponse {
    HttpResponse::Ok().json(serde_json::json!({
        "status": "ok",
        "service": "frontend"
    }))
}

#[get("/api/config")]
async fn get_config() -> HttpResponse {
    let backend_port = env::var(BACKEND_INTERNAL_PORT_KEY).unwrap_or_else(|_| "92".to_string());

    HttpResponse::Ok().json(serde_json::json!({
        "BACKEND_URL": format!("http://backend:{}", backend_port)
    }))
}

#[get("/api/metrics")]
async fn metrics() -> impl Responder {
    let encoder = TextEncoder::new();
    let metric_families = prometheus::gather();
    let mut buffer = Vec::new();

    if let Err(err) = encoder.encode(&metric_families, &mut buffer) {
        error!("Failed to encode Prometheus metrics: {:?}", err);
        return HttpResponse::InternalServerError().finish();
    }

    let response_body = match String::from_utf8(buffer) {
        Ok(s) => s,
        Err(_) => return HttpResponse::InternalServerError().finish(),
    };

    HttpResponse::Ok()
        .content_type("text/plain; charset=utf-8")
        .body(response_body)
}

#[get("/static/js/api_config.js")]
async fn api_config() -> HttpResponse {
    let backend_port = env::var(BACKEND_INTERNAL_PORT_KEY).unwrap_or_else(|_| "92".to_string());

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
        if req.path().starts_with("/api/")
            && req.path() != "/api/health"
            && req.path() != "/api/config"
            && req.path() != "/api/logout"
            && req.path() != "/api/metrics"
        {
            // 🚀 NEW: Handle search metrics
            if req.path() == "/api/search" {
                // Increment the total search counter
                SEARCH_QUERIES_TOTAL.inc();

                // Extract 'language' param from query string
                let query_params = req.query_string();
                let lang = querystring::querify(query_params)
                    .iter()
                    .find(|(key, _)| *key == "language")
                    .map(|(_, value)| *value)
                    .unwrap_or("unknown");

                SEARCH_QUERIES_BY_LANG.with_label_values(&[lang]).inc();
            }

            let client = self.client.clone();
            let backend_url = self.backend_url.clone();
            let path = req.path().to_string();
            let query = req.query_string().to_string();
            let method = req.method().clone();
            let headers = req.headers().clone();

            let (request, payload) = req.into_parts();

            let backend_req_url = if query.is_empty() {
                format!("{}{}", backend_url, path)
            } else {
                format!("{}{}?{}", backend_url, path, query)
            };

            info!("Proxying request to backend: {}", backend_req_url);

            Box::pin(async move {
                let mut client_req = client.request(method, &backend_req_url).no_decompress();

                for (header_name, header_value) in headers.iter().filter(|(h, _)| {
                    *h != http::header::HOST
                        && *h != http::header::CONNECTION
                        && *h != http::header::CONTENT_LENGTH
                }) {
                    client_req =
                        client_req.insert_header((header_name.clone(), header_value.clone()));
                }

                let backend_response = client_req.send_stream(payload).await;

                match backend_response {
                    Ok(mut res) => {
                        let mut client_resp = HttpResponse::build(res.status());

                        for (header_name, header_value) in res.headers().iter().filter(|(h, _)| {
                            *h != http::header::CONNECTION
                                && *h != http::header::CONTENT_LENGTH
                        }) {
                            client_resp
                                .insert_header((header_name.clone(), header_value.clone()));
                        }

                        let bytes = res.body().await?;

                        Ok(ServiceResponse::new(
                            request,
                            client_resp.body(bytes).map_into_right_body(),
                        ))
                    }
                    Err(e) => {
                        error!("Backend request error: {}", e);
                        let error_response = HttpResponse::ServiceUnavailable()
                            .content_type("application/json")
                            .body(format!(
                                "{{\"error\": \"Backend service unavailable: {}\"}}",
                                e
                            ))
                            .map_into_right_body();

                        Ok(ServiceResponse::new(request, error_response))
                    }
                }
            })
        } else {
            let res = self.service.call(req);

            Box::pin(async move {
                let res = res.await?;
                Ok(res.map_into_left_body())
            })
        }
    }
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    dotenv::dotenv().ok();

    env_logger::init_from_env(env_logger::Env::new().default_filter_or("info"));

    let frontend_port = env::var(FRONTEND_INTERNAL_PORT_KEY).unwrap_or_else(|_| "91".to_string());
    let backend_port = env::var(BACKEND_INTERNAL_PORT_KEY).unwrap_or_else(|_| "92".to_string());

    info!("Starting server at http://0.0.0.0:{}", frontend_port);
    info!("Using backend at http://backend:{}", backend_port);

    let backend_url = format!("http://backend:{}", backend_port);

    HttpServer::new(move || {
        App::new()
            .wrap(middleware::Logger::default())
            .wrap(RequestCounter)
            .wrap(ApiProxy::new(backend_url.clone()))
            .wrap(
                Cors::default()
                    .allowed_origin(
                        &std::env::var(FRONTEND_URL_KEY)
                            .unwrap_or_else(|_| "http://localhost:8080".into()),
                    )
                    .allowed_methods(vec!["GET", "POST"])
                    .allowed_headers(vec![
                        http::header::AUTHORIZATION,
                        http::header::ACCEPT,
                    ])
                    .allowed_header(http::header::CONTENT_TYPE)
                    .expose_headers(&[http::header::CONTENT_DISPOSITION])
                    .supports_credentials()
                    .max_age(3600),
            )
            .service(health_check)
            .service(get_config)
            .service(api_config)
            .service(metrics)
            .service(files::Files::new("/static", "./static").show_files_listing())
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
