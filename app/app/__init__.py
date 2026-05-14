import os
import signal
import sys

from flask import Flask
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()


def create_app():
    app = Flask(__name__)
    app.config["DEPLOY_TIME"] = os.getenv("DEPLOY_TIME", "unknown")
    app.config["VERSION"] = os.getenv("APP_VERSION", "dev")
    app.config["ENVIRONMENT"] = os.getenv("ENVIRONMENT", "local")

    db_url = os.getenv("DATABASE_URL")
    if not db_url:
        db_url = "sqlite:////tmp/statuspage.db"

    app.config["SQLALCHEMY_DATABASE_URI"] = db_url
    app.config["SQLALCHEMY_ENGINE_OPTIONS"] = {
        "pool_pre_ping": True,
        "pool_recycle": 300,
    }
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

    db.init_app(app)

    from .routes import bp

    app.register_blueprint(bp)

    def handle_sigterm(signum, frame):
        app.logger.info("Received SIGTERM, shutting down gracefully...")
        sys.exit(0)

    signal.signal(signal.SIGTERM, handle_sigterm)

    return app
