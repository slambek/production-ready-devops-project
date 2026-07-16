from fastapi import FastAPI, Response, status
from prometheus_client import CONTENT_TYPE_LATEST, generate_latest

from app.database import check_database_connection

app = FastAPI(
    title="Production Ready DevOps Project",
    version="1.0.0",
)


@app.get("/")
def root() -> dict[str, str]:
    return {
        "service": "production-ready-devops-project",
        "status": "running",
    }


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "healthy"}


@app.get(
    "/ready",
    responses={
        503: {
            "description": "Database is unavailable",
        }
    },
)
def readiness(response: Response) -> dict[str, str]:
    if not check_database_connection():
        response.status_code = status.HTTP_503_SERVICE_UNAVAILABLE
        return {
            "status": "not ready",
            "database": "unavailable",
        }

    return {
        "status": "ready",
        "database": "available",
    }


@app.get("/metrics")
def metrics() -> Response:
    return Response(
        content=generate_latest(),
        media_type=CONTENT_TYPE_LATEST,
    )
