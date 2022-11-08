use crate::domain::repository::todorepository::TodoRepository;
use crate::handler::handler::{all_todo, create_todo, delete_todo, find_todo, update_todo};
use axum::{
    extract::Extension,
    http::Method,
    routing::{get, post},
    Router,
};
use http::header::CONTENT_TYPE;
use std::sync::Arc;
use tower_http::cors::{CorsLayer, Origin};

pub fn create_app<T: TodoRepository>(repository: T) -> Router {
    Router::new()
        .route("/todos", post(create_todo::<T>).get(all_todo::<T>))
        .route(
            "/todos/:id",
            get(find_todo::<T>)
                .patch(update_todo::<T>)
                .delete(delete_todo::<T>),
        )
        .layer(
            CorsLayer::new()
                .allow_origin(Origin::exact("http://localhost:8000".parse().unwrap()))
                .allow_headers([CONTENT_TYPE])
                .allow_methods(vec![
                    Method::GET,
                    Method::POST,
                    Method::PATCH,
                    Method::DELETE,
                ]),
        )
        .layer(Extension(Arc::new(repository)))
}
