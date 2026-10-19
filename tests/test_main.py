
import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import sessionmaker

from app.database import Base, engine
from app.main import app, get_db

TestSessionLocal = sessionmaker(
    bind=engine,
    autoflush=False,
    autocommit=False,
)


def override_get_db():
    db = TestSessionLocal()
    try:
        yield db
    finally:
        db.close()


app.dependency_overrides[get_db] = override_get_db
client = TestClient(app)


@pytest.fixture(autouse=True)
def reset_test_database():
    Base.metadata.create_all(bind=engine)
    with engine.begin() as connection:
        connection.exec_driver_sql("DELETE FROM tasks")
    yield


def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}


def test_readiness():
    response = client.get("/ready")
    assert response.status_code == 200
    assert response.json() == {"status": "ready"}


def test_create_and_list_task():
    response = client.post(
        "/tasks",
        json={"title": "Learn AWS", "completed": False},
    )
    assert response.status_code == 201
    assert response.json()["title"] == "Learn AWS"

    listed = client.get("/tasks")
    assert listed.status_code == 200
    assert len(listed.json()) == 1


def test_update_task():
    created = client.post("/tasks", json={"title": "Old title"})
    task_id = created.json()["id"]

    response = client.put(
        f"/tasks/{task_id}",
        json={"title": "New title", "completed": True},
    )
    assert response.status_code == 200
    assert response.json()["title"] == "New title"
    assert response.json()["completed"] is True


def test_delete_task():
    created = client.post("/tasks", json={"title": "Temporary task"})
    task_id = created.json()["id"]

    response = client.delete(f"/tasks/{task_id}")
    assert response.status_code == 204
    assert client.get(f"/tasks/{task_id}").status_code == 404


def test_missing_task_returns_404():
    response = client.get("/tasks/999999")
    assert response.status_code == 404


def test_invalid_task_returns_422():
    response = client.post("/tasks", json={"title": ""})
    assert response.status_code == 422
