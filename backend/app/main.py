from fastapi import FastAPI

from app.api.v1 import router

app = FastAPI(title="NotesApp API", version="0.1.0")
app.include_router(router)


@app.get("/healthz", include_in_schema=False)
async def healthz() -> dict[str, str]:
    return {"status": "ok"}
