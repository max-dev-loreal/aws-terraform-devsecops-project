import logging
import os

logger = logging.getLogger(__name__)


def on_starting(server):
    pass


def when_ready(server):
    logger.info("Gunicorn server is ready")


def worker_int(worker):
    logger.info(f"Worker {worker.pid} interrupted")


def worker_abort(worker):
    logger.info(f"Worker {worker.pid} aborted")


def worker_exit(server, worker):
    logger.info(f"Worker {worker.pid} exited")


def on_exit(server):
    logger.info("Gunicorn is shutting down gracefully")


graceful_timeout = 30
timeout = 60

accesslog = "-"
errorlog = "-"
loglevel = os.getenv("LOG_LEVEL", "info")

daemon = False
pidfile = None

proc_name = "statuspage"
