"""ARQ worker.

    python -m app.worker        (from backend/; works on Windows too)
"""

import logging
import sys
from typing import Any

from arq import run_worker
from arq.connections import RedisSettings

from app.config import get_settings
from app.db import get_sessionmaker
from app.ingest.jobs import recover_stuck_jobs, run_ingest
from app.queue import ArqQueue
from app.storage import get_storage

log = logging.getLogger("app.worker")


async def startup(ctx: dict[str, Any]) -> None:
    ctx["settings"] = get_settings()
    ctx["sessionmaker"] = get_sessionmaker()
    ctx["storage"] = get_storage()
    recovered = await recover_stuck_jobs(ctx["sessionmaker"], ArqQueue(pool=ctx["redis"]))
    if recovered:
        log.warning("recovered %d job(s) left running by a previous worker", recovered)


async def ingest_job(ctx: dict[str, Any], job_id: str) -> None:
    from uuid import UUID

    await run_ingest(UUID(job_id), ctx["sessionmaker"], ctx["storage"], ctx["settings"])


class WorkerSettings:
    functions = [ingest_job]
    on_startup = startup
    redis_settings = RedisSettings.from_dsn(get_settings().redis_url)
    max_jobs = 2
    job_timeout = 900
    max_tries = 1  # retries are handled by recover_stuck_jobs, which also tracks attempts in the DB


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    # arq's signal handlers are not supported by the Windows event loop
    run_worker(WorkerSettings, handle_signals=sys.platform != "win32")  # type: ignore[arg-type]
