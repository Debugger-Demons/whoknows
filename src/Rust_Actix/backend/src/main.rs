use actix_web::{get, post, App, HttpResponse, HttpServer, Responder};
use actix_cors::Cors;

// Constants
    // &str is a string slice (a reference to a string) -- used here because we don't need to own the string
    // u16 is an unsigned 16-bit integer (0 to 65,535) -- used here because port numbers are always positive
const HOST_NAME: &str = "0.0.0.0";
const PORT: u16 = 8080; 

// Handlers
    // GET, POST implemented as async functions -- thus non-blocking
        // async necessary here, since functions implemented (get, post) are async
            // async functions are non-blocking, meaning they can return control to the caller while they wait for an operation to complete
                // "return control to the caller" means: the function can return a value to the caller before it has finished executing
    // Responder trait implemented -- allows the function to return a value that can be converted into an HTTP response
        // Responder trait is implemented for many types, including strings, byte arrays, and JSON objects
            // allows the function to return a value that can be converted into an HTTP response
    // HttpResponse::Ok() creates a new instance of an HTTP response with a status code of 200 (OK)
        // .body() sets the body of the response to the specified string
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
            // .wrap() adds middleware to the application -- middleware is code that runs before or after a request is processed
                // here, we are adding the CORS middleware
        App::new()
            .wrap(cors)
            .service(hello)
            .service(search)
            .service(add)
    })

    // .bind() returns a Result, so we use ? to handle the error
        // if the Result is an error, the ? operator will return the error to the caller
    .bind((HOST_NAME, PORT))?
    .run()
    .await
}
