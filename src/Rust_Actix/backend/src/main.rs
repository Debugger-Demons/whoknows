use actix_web::{get, post, App, HttpResponse, HttpServer, Responder};
use actix_cors::Cors;
const HOST_NAME: &str = "0.0.0.0";
const PORT: u16 = 8080;

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

// Main function
#[actix_web::main]

    // main function is asynchronous because we are using async functions -- async functions are non-blocking
        // non-blocking means that the function can return control to the caller while it waits for an operation to complete
async fn main() -> std::io::Result<()> {
    // Initialize the logger
        // logger is a tool that records events that happen while the software runs
            // use cases: debugging, monitoring, security, etc.
            // available by cmd line: RUST_LOG=info cargo run
    env_logger::init_from_env(env_logger::Env::new().default_filter_or("info"));

    println!("Server starting at http://{}:{}", HOST_NAME, PORT);

    // Start the server
        // HttpServer::new() creates a new instance of the server
            // .bind() binds the server to the specified address and port
            
    HttpServer::new(|| {

        let cors = Cors::default()
            .allow_any_origin()
            .allow_any_method()
            .allow_any_header();

        // App instance
            // .service() registers a service with the application
            // .wrap() adds middleware to the application                 
        
        App::new()
            .wrap(cors)  // cors middleware added 
            .service(hello)
            .service(search)
            .service(add)
            .service(weather)
            .service(get_weather)
            .service(register_user)
            .service(register)
    })

    // .bind() returns a Result, so we use ? to handle the error
        // if the Result is an error, the ? operator will return the error to the caller
    .bind((HOST_NAME, PORT))?
    .run()
    .await
}
