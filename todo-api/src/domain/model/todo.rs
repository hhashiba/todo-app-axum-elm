use serde::{Deserialize, Serialize};
use sqlx::FromRow;

#[derive(Debug, Deserialize, Serialize, Clone, FromRow)]
pub struct Todo {
    pub id: i32,
    pub text: String,
    pub completed: bool,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct CreateTodo {
    pub text: String,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct UpdateTodo {
    pub text: Option<String>,
    pub completed: Option<bool>,
}
