from app import create_app


def test_health_endpoint():
    app = create_app()
    client = app.test_client()
    response = client.get("/health")
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "healthy"


def test_metrics_endpoint():
    app = create_app()
    client = app.test_client()
    response = client.get("/metrics")
    assert response.status_code == 200


def test_index_endpoint():
    app = create_app()
    client = app.test_client()
    response = client.get("/")
    assert response.status_code == 200
