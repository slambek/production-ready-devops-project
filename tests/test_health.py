from unittest.mock import patch

from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_root() -> None:
    response = client.get("/")

    assert response.status_code == 200
    assert response.json() == {
        "service": "production-ready-devops-project",
        "status": "running",
    }


def test_health() -> None:
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}


@patch("app.main.check_database_connection", return_value=True)
def test_readiness_when_database_is_available(mock_database_check) -> None:
    response = client.get("/ready")

    assert response.status_code == 200
    assert response.json() == {
        "status": "ready",
        "database": "available",
    }

    mock_database_check.assert_called_once()


@patch("app.main.check_database_connection", return_value=False)
def test_readiness_when_database_is_unavailable(mock_database_check) -> None:
    response = client.get("/ready")

    assert response.status_code == 503
    assert response.json() == {
        "status": "not ready",
        "database": "unavailable",
    }

    mock_database_check.assert_called_once()


def test_metrics() -> None:
    response = client.get("/metrics")

    assert response.status_code == 200
    assert "text/plain" in response.headers["content-type"]
    assert "python_gc_objects_collected_total" in response.text
