mod domain;
mod handler;
mod infra;

use crate::handler::route::create_app;
use crate::infra::sqlhandler::TodoRepositoryForDb;

use dotenv::dotenv;
use sqlx::PgPool;
use std::env;
use std::net::SocketAddr;

#[tokio::main]
async fn main() {
    let log_level = env::var("RUST_LOG").unwrap_or("info".to_string());
    env::set_var("RUST_LOG", log_level);
    tracing_subscriber::fmt::init();
    dotenv().ok();

    let database_url = &env::var("DATABASE_URL").expect("undefined [DATABASE_URL]");
    tracing::debug!("start connect database...");
    let pool = PgPool::connect(database_url)
        .await
        .expect(&format!("fail connect database, url is {}", database_url));

    let addr = SocketAddr::from(([0, 0, 0, 0], 3000));
    let repository = TodoRepositoryForDb::new(pool.clone());
    let app = create_app(repository);

    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await
        .unwrap()
}
