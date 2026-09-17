import uuid
from functools import lru_cache
from typing import Protocol

from arq import create_pool
from arq.connections import ArqRedis, RedisSettings

from app.config import get_settings

INGEST_FUNCTION = "ingest_job"


class Queue(Protocol):
    async def enqueue_ingest(self, job_id: uuid.UUID, attempt: int = 0) -> None: ...


class ArqQueue:
    def __init__(self, redis_url: str = "", pool: ArqRedis | None = None) -> None:
        self._redis_url = redis_url
        self._pool = pool

    async def enqueue_ingest(self, job_id: uuid.UUID, attempt: int = 0) -> None:
        if self._pool is None:
            self._pool = await create_pool(RedisSettings.from_dsn(self._redis_url))
        # arq ignores a _job_id it has already seen, so retries need a distinct id
        await self._pool.enqueue_job(INGEST_FUNCTION, str(job_id), _job_id=f"ingest:{job_id}:{attempt}")


@lru_cache
def get_queue() -> Queue:
    return ArqQueue(get_settings().redis_url)
