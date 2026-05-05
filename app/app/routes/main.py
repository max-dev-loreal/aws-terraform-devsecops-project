"""Main routes blueprint."""

from __future__ import annotations

from flask import Blueprint, jsonify, render_template

bp = Blueprint("main", __name__)


@bp.get("/")
def index() -> str:
    """Render the home page."""
    return render_template("resume.html")


@bp.get("/health")
def health():
    """Health check endpoint for load balancers."""
    return jsonify({"status": "ok"})

