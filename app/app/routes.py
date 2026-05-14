import logging
import time
from datetime import datetime, timezone

from flask import Blueprint, current_app, jsonify, render_template, request
from prometheus_client import (CONTENT_TYPE_LATEST, Counter, Histogram,
                               generate_latest)

bp = Blueprint("main", __name__)

START_TIME = time.time()

REQUEST_COUNT = Counter(
    "statuspage_requests_total", "Total requests", ["method", "endpoint", "status"]
)
REQUEST_DURATION = Histogram("statuspage_request_duration_seconds", "Request duration")

logger = logging.getLogger(__name__)


@bp.before_app_request
def before_request():
    request.start_time = time.time()


@bp.after_app_request
def after_request(response):
    duration = time.time() - getattr(request, "start_time", time.time())
    REQUEST_COUNT.labels(
        method=request.method, endpoint=request.path, status=response.status_code
    ).inc()
    REQUEST_DURATION.observe(duration)
    return response


@bp.get("/")
def index():
    uptime = int(time.time() - START_TIME)
    return render_template(
        "index.html",
        uptime=uptime,
        version=current_app.config["VERSION"],
        deploy_time=current_app.config["DEPLOY_TIME"],
        environment=current_app.config["ENVIRONMENT"],
    )


@bp.get("/health")
def health():
    return jsonify(
        {
            "status": "healthy",
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "version": current_app.config["VERSION"],
            "uptime_seconds": int(time.time() - START_TIME),
        }
    )


@bp.get("/metrics")
def metrics():
    return generate_latest(), 200, {"Content-Type": CONTENT_TYPE_LATEST}


@bp.get("/api/status")
def api_status():
    return jsonify(
        {
            "services": {
                "statuspage": "up",
                "bot": "unknown",
                "database": "unknown",
            },
            "version": current_app.config["VERSION"],
            "environment": current_app.config["ENVIRONMENT"],
            "deploy_time": current_app.config["DEPLOY_TIME"],
            "uptime_seconds": int(time.time() - START_TIME),
        }
    )
