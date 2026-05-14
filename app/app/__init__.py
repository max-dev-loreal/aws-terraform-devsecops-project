import os
from flask import Flask


def create_app():
    app = Flask(__name__)
    app.config["DEPLOY_TIME"] = os.getenv("DEPLOY_TIME", "unknown")
    app.config["VERSION"] = os.getenv("APP_VERSION", "dev")
    app.config["ENVIRONMENT"] = os.getenv("ENVIRONMENT", "local")

    from .routes import bp

    app.register_blueprint(bp)

    return app
