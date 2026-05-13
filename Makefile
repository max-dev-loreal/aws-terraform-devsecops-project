.PHONY: help lint test build up down

help:
	@echo "Available targets:"
	@echo "  lint      - Run code linters"
	@echo "  test      - Run pytest with coverage"
	@echo "  build     - Build Docker image locally"
	@echo "  up        - Start local environment (docker-compose)"
	@echo "  down      - Stop local environment"

lint:
	@flake8 app/ --count --select=E9,F63,F7,F82 --show-source --statistics
	@black --check app/
	@isort --check-only app/

test:
	@cd app && pytest -v --cov=app --cov-report=term-missing

build:
	@docker build -t statuspage:latest ./app

up:
	@docker-compose up -d --build

down:
	@docker-compose down
