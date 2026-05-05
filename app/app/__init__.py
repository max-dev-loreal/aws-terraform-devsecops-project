"""Application factory for the Flask app."""

from __future__ import annotations
import mimetypes  

from flask import Flask
from .config import Config

mimetypes.add_type('text/css', '.css')
mimetypes.add_type('application/javascript', '.js')

def create_app(config_object: type[Config] | None = None) -> Flask:
    """Create and configure the Flask application.

    Args:
        config_object: Optional config class. Defaults to `Config`.

    Returns:
        Configured Flask app instance.
    """
    app = Flask(
        __name__,
        template_folder="templates",
        static_folder="static",
    )

    app.config.from_object(config_object or Config)

    from .routes.main import bp as main_bp
    app.register_blueprint(main_bp)

    return app