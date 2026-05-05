"""Application configuration.

Keep configuration in env vars; provide safe defaults for local dev.
"""

from __future__ import annotations

import os


class Config:
    """Base configuration loaded from environment variables."""

    SECRET_ID: str = os.getenv("DB_SECRET_ID", "db-password")
    AWS_REGION: str = os.getenv("AWS_REGION", "eu-north-1")
    APP_GREETING: str = os.getenv("APP_GREETING", "Hello from Flask")

