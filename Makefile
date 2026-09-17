# On Windows without make, run the command after each target directly (see CLAUDE.md).
.PHONY: up down db-reset api worker test lint contract fixtures

up:
	docker compose up -d

down:
	docker compose down

db-reset:
	python backend/scripts/db_reset.py

api:
	cd backend && uvicorn app.main:app --reload

worker:
	cd backend && python -m app.worker

test:
	cd backend && pytest tests -q

lint:
	cd backend && ruff check . && mypy app

contract:
	./backend/scripts/gen_contract.sh

fixtures:
	python backend/scripts/make_fixtures.py
