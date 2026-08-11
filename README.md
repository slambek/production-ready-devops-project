<p align="center">
  <img src="assets/architecture.png" alt="Architecture" width="85%">
</p>

FastAPI + PostgreSQL with Docker, CI/CD, Kubernetes, Helm and Ansible.

## Local

```bash
cp .env.example .env
docker compose up --build -d
```

```bash
curl http://127.0.0.1:8080/health
```

## Production

```bash
cp deploy/.env.example deploy/.env
./deploy/deploy.sh
```

## Kubernetes

```bash
kubectl apply -k k8s/base
```

```bash
helm upgrade --install devops helm/production-ready-devops-project \
  --namespace devops-helm --create-namespace
```

## Checks

```bash
make check
make security
```

CI builds and publishes `amd64` / `arm64` images to GHCR.

## Ansible

```bash
ansible-playbook -i ansible/inventory/hosts.ini ansible/playbook.yml --ask-vault-pass
```
