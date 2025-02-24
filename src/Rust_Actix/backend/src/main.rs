use actix_web::{get, post, web, App, HttpResponse, HttpServer, Responder};

#[get("/")]
async fn hello() -> impl Responder {
    HttpResponse::Ok().body("Hello world2!")
}

#[get("/search")]
async fn search() -> impl Responder {
    HttpResponse::Ok().body("Search endpoint")
}

/*
Vi skal afgøre hvilket endpoint der er post, og hvilket der ikke er. 
*/

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

#[post("/")]
async fn add() -> impl Responder {
    HttpResponse::Ok().body("Add endpoint")
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    env_logger::init_from_env(env_logger::Env::new().default_filter_or("info"));

    println!("Server starting at http://127.0.0.1:8080");

    HttpServer::new(|| {
        App::new()
            .service(hello)
            .service(search)
            .service(add)
            .service(weather)
            .service(get_weather)
            .service(register_user)
            .service(register)
    })
    .bind(("127.0.0.1", 8080))?
    .run()
    .await
}
