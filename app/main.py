from itertools import count

from fastapi import FastAPI, HTTPException, Response, status
from pydantic import BaseModel, Field

app = FastAPI(
    title="AWS Task Management API",
    version="1.0.0",
    description="A cloud engineering portfolio project",
)

class TaskCreate(BaseModel):
    title: str = Field(min_length=1, max_length=200)
    completed: bool = False

class Task(TaskCreate):
    id: int

tasks: dict[int, Task] = {}
task_ids = count(1)

@app.get("/health")
def health():
    return {"status": "healthy"}

@app.get("/tasks", response_model=list[Task])
def list_tasks():
    return list(tasks.values())

@app.post("/tasks", response_model=Task, status_code=status.HTTP_201_CREATED)
def create_task(payload: TaskCreate):
    task = Task(id=next(task_ids), **payload.model_dump())
    tasks[task.id] = task
    return task

@app.get("/tasks/{task_id}", response_model=Task)
def get_task(task_id: int):
    task = tasks.get(task_id)
    if task is None:
        raise HTTPException(status_code=404, detail="Task not found")
    return task

@app.put("/tasks/{task_id}", response_model=Task)
def update_task(task_id: int, payload: TaskCreate):
    if task_id not in tasks:
        raise HTTPException(status_code=404, detail="Task not found")
    task = Task(id=task_id, **payload.model_dump())
    tasks[task_id] = task
    return task

@app.delete("/tasks/{task_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_task(task_id: int):
    if task_id not in tasks:
        raise HTTPException(status_code=404, detail="Task not found")
    del tasks[task_id]
    return Response(status_code=status.HTTP_204_NO_CONTENT)
