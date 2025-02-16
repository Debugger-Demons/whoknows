use actix_web::{get, post, web, App, HttpResponse, HttpServer, Responder};

#[get("/")]
async fn hello() -> impl Responder {
    HttpResponse::Ok().body("Hello world!")
}

#[get("/search")]
async fn search() -> impl Responder {
    HttpResponse::Ok().body("Search endpoint")
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
    })
    .bind(("0.0.0.0", 8080))?
    .run()
    .await
}
