.PHONY: install install-dev run test lint format check compose-up compose-down logs clean

install:
	python -m pip install -r app/requirements.txt

install-dev:
	python -m pip install -r requirements-dev.txt
	pre-commit install

run:
	uvicorn app.main:app --reload

test:
	python -m pytest -v

lint:
	python -m ruff check .

format:
	python -m ruff check . --fix
	python -m ruff format .

check:
	python -m ruff check .
	python -m ruff format --check .
	python -m pytest -v

compose-up:
	docker compose up --build -d

compose-down:
	docker compose down

logs:
	docker compose logs -f

clean:
	find . -type d -name "__pycache__" -prune -exec rm -rf {} +
	rm -rf .pytest_cache .ruff_cache

helm-lint:
	helm lint helm/production-ready-devops-project \
		-f helm/production-ready-devops-project/values.local.yaml

helm-template:
	helm template devops \
		helm/production-ready-devops-project \
		--namespace devops-ci \
		-f helm/production-ready-devops-project/values.ci.yaml \
		> /tmp/devops-manifests.yaml

kubeconform: helm-template
	kubeconform \
		-strict \
		-summary \
		-kubernetes-version 1.35.1 \
		/tmp/devops-manifests.yaml
