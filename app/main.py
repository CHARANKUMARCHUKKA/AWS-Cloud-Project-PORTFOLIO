
from fastapi import Depends, FastAPI, HTTPException, Response, status
from pydantic import BaseModel, ConfigDict, Field
from sqlalchemy import select, text
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from app.database import SessionLocal
from app.models import TaskRecord


class TaskCreate(BaseModel):
    title: str = Field(min_length=1, max_length=200)
    completed: bool = False


class TaskResponse(TaskCreate):
    model_config = ConfigDict(from_attributes=True)
    id: int


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


app = FastAPI(
    title="AWS Task Management API",
    version="1.0.0",
    description="A cloud engineering portfolio project",
)


@app.get("/health")
def health():
    return {"status": "healthy"}


@app.get("/ready")
def readiness(db: Session = Depends(get_db)):
    try:
        db.execute(text("SELECT 1"))
    except SQLAlchemyError as error:
        raise HTTPException(status_code=503, detail="Database is unavailable") from error
    return {"status": "ready"}


@app.get("/tasks", response_model=list[TaskResponse])
def list_tasks(db: Session = Depends(get_db)):
    return db.scalars(select(TaskRecord).order_by(TaskRecord.id)).all()


@app.post(
    "/tasks",
    response_model=TaskResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_task(payload: TaskCreate, db: Session = Depends(get_db)):
    task = TaskRecord(**payload.model_dump())
    db.add(task)
    db.commit()
    db.refresh(task)
    return task


@app.get("/tasks/{task_id}", response_model=TaskResponse)
def get_task(task_id: int, db: Session = Depends(get_db)):
    task = db.get(TaskRecord, task_id)
    if task is None:
        raise HTTPException(status_code=404, detail="Task not found")
    return task


@app.put("/tasks/{task_id}", response_model=TaskResponse)
def update_task(
    task_id: int,
    payload: TaskCreate,
    db: Session = Depends(get_db),
):
    task = db.get(TaskRecord, task_id)
    if task is None:
        raise HTTPException(status_code=404, detail="Task not found")

    task.title = payload.title
    task.completed = payload.completed
    db.commit()
    db.refresh(task)
    return task


@app.delete("/tasks/{task_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_task(task_id: int, db: Session = Depends(get_db)):
    task = db.get(TaskRecord, task_id)
    if task is None:
        raise HTTPException(status_code=404, detail="Task not found")

    db.delete(task)
    db.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)
