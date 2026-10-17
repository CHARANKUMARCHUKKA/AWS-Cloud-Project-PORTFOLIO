from fastapi.testclient import TestClient

from app.main import app, tasks

client = TestClient(app)


def setup_function():
    tasks.clear()


def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}


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
    response = client.get("/tasks/999")
    assert response.status_code == 404


def test_invalid_task_returns_422():
    response = client.post("/tasks", json={"title": ""})
    assert response.status_code == 422
