import os


# Configure the application before test modules import it. StaticPool in
# app.database makes this in-memory database available across TestClient threads.
os.environ.setdefault("DATABASE_URL", "sqlite+pysqlite://")
