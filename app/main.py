import time

from fastapi import FastAPI, Request, Response, status
from prometheus_client import (
    CONTENT_TYPE_LATEST,
    Counter,
    Histogram,
    generate_latest,
)

from app.database import check_database_connection

app = FastAPI(
    title="Production Ready DevOps Project",
    version="1.0.0",
)

http_requests_total = Counter(
    "http_requests_total",
    "Total number of HTTP requests",
    ["method", "path", "status"],
)

http_request_duration_seconds = Histogram(
    "http_request_duration_seconds",
    "HTTP request duration in seconds",
    ["method", "path"],
)


@app.middleware("http")
async def collect_http_metrics(request: Request, call_next):
    start_time = time.perf_counter()

    response = await call_next(request)

    duration = time.perf_counter() - start_time
    path = request.url.path

    http_requests_total.labels(
        method=request.method,
        path=path,
        status=str(response.status_code),
    ).inc()

    http_request_duration_seconds.labels(
        method=request.method,
        path=path,
    ).observe(duration)

    return response


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
