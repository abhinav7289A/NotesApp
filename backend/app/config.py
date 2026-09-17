from functools import lru_cache
from pathlib import Path
from uuid import UUID

from pydantic_settings import BaseSettings, SettingsConfigDict

REPO_ROOT = Path(__file__).resolve().parents[2]


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=REPO_ROOT / ".env", extra="ignore")

    database_url: str = "postgresql+asyncpg://notesapp:notesapp@localhost:5433/notesapp"
    redis_url: str = "redis://localhost:6379/0"

    # Cloudflare R2 in staging/prod, MinIO locally. Set R2_ENDPOINT_URL for MinIO.
    r2_account_id: str = ""
    r2_endpoint_url: str = ""
    r2_access_key_id: str = "minioadmin"
    r2_secret_access_key: str = "minioadmin"
    r2_bucket: str = "notesapp-dev"

    dev_user_id: UUID = UUID("00000000-0000-0000-0000-000000000001")

    max_upload_bytes: int = 40 * 1024 * 1024
    max_pages: int = 500
    signed_url_ttl_seconds: int = 900
    eager_raster_pages: int = 10
    page_image_width_px: int = 1600

    @property
    def async_database_url(self) -> str:
        url = self.database_url
        if url.startswith("postgresql://"):
            url = "postgresql+asyncpg://" + url.removeprefix("postgresql://")
        return url

    @property
    def s3_endpoint_url(self) -> str:
        return self.r2_endpoint_url or f"https://{self.r2_account_id}.r2.cloudflarestorage.com"


@lru_cache
def get_settings() -> Settings:
    return Settings()
