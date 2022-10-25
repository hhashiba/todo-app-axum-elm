build:
	docker-compose build

db:
	docker-compose up

dev:
	sqlx db create
	sqlx migrate run
	cargo run

dev:
	sqlx db create
	sqlx migrate run
	cargo run


debug:
	sqlx db create
	sqlx migrate run
	RUST_LOG=debug cargo run