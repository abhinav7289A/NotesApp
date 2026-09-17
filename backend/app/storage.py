"""Object storage: Cloudflare R2 in staging/prod, MinIO locally. Both speak S3."""

from functools import lru_cache
from typing import Protocol

import boto3
from botocore.client import Config
from botocore.exceptions import ClientError

from app.config import Settings, get_settings


class Storage(Protocol):
    def presign_put(self, key: str, content_type: str, expires: int) -> str: ...
    def presign_get(self, key: str, expires: int) -> str: ...
    def get_bytes(self, key: str) -> bytes: ...  # raises FileNotFoundError
    def put_bytes(self, key: str, data: bytes, content_type: str) -> None: ...
    def exists(self, key: str) -> bool: ...


class S3Storage:
    def __init__(self, settings: Settings) -> None:
        self.bucket = settings.r2_bucket
        self.client = boto3.client(
            "s3",
            endpoint_url=settings.s3_endpoint_url,
            aws_access_key_id=settings.r2_access_key_id,
            aws_secret_access_key=settings.r2_secret_access_key,
            region_name="auto",
            config=Config(signature_version="s3v4", s3={"addressing_style": "path"}),
        )

    def presign_put(self, key: str, content_type: str, expires: int) -> str:
        url: str = self.client.generate_presigned_url(
            "put_object", Params={"Bucket": self.bucket, "Key": key, "ContentType": content_type}, ExpiresIn=expires
        )
        return url

    def presign_get(self, key: str, expires: int) -> str:
        url: str = self.client.generate_presigned_url("get_object", Params={"Bucket": self.bucket, "Key": key}, ExpiresIn=expires)
        return url

    def get_bytes(self, key: str) -> bytes:
        try:
            data: bytes = self.client.get_object(Bucket=self.bucket, Key=key)["Body"].read()
        except ClientError as e:
            if e.response.get("Error", {}).get("Code") in ("NoSuchKey", "404"):
                raise FileNotFoundError(key) from e
            raise
        return data

    def put_bytes(self, key: str, data: bytes, content_type: str) -> None:
        self.client.put_object(Bucket=self.bucket, Key=key, Body=data, ContentType=content_type)

    def exists(self, key: str) -> bool:
        try:
            self.client.head_object(Bucket=self.bucket, Key=key)
        except ClientError as e:
            if e.response.get("Error", {}).get("Code") in ("NoSuchKey", "404", "NotFound"):
                return False
            raise
        return True


@lru_cache
def get_storage() -> Storage:
    return S3Storage(get_settings())
