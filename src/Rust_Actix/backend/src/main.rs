use actix_web::{get, post, App, HttpResponse, HttpServer, Responder};
use actix_cors::Cors;

const HOST_NAME: &str = "0.0.0.0";
const PORT: i32 = 8080;



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

    println!("Server starting at http://{}:{}", HOST_NAME, PORT); 

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
    })
    .bind((HOST_NAME, PORT))?
    .run()
    .await
}
