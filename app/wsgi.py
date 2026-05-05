"""WSGI entrypoint for production servers (e.g. Gunicorn)."""

from app import create_app

app = create_app()

