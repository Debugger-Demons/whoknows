"""Loads environment variables from .env.local.frontend for Makefile tasks."""
import os
import dotenv

env_path = os.path.join(os.path.dirname(__file__), '../.env.local.frontend')

dotenv.load_dotenv(env_path)

def check_env() -> bool | None:
    """ Check if .env.local.frontend exists """
    return os.path.exists(env_path)

def get_project_name() -> str | None:
    """Gets the COMPOSE_PROJECT_NAME from environment variables."""    
    return os.getenv('COMPOSE_PROJECT_NAME')

def get_frontend_port() -> str | None:
    """Gets the FRONTEND_PORT_INTERNAL from environment variables."""
    return os.getenv('FRONTEND_INTERNAL_PORT')

def get_backend_port() -> str | None:
    """Gets the BACKEND_PORT_INTERNAL from environment variables."""
    return os.getenv('BACKEND_INTERNAL_PORT')

def is_db_needed() -> bool:
    """Checks if the DB_HOST environment variable is set."""
    return os.getenv('DB_HOST') is not None

def get_db_host() -> str | None:
    """Gets the DB_HOST from environment variables."""
    return os.getenv('DB_HOST')

def get_db_username() -> str | None:
    """Gets the DB_USERNAME from environment variables."""
    return os.getenv('DB_USERNAME')

def get_db_password() -> str | None:
    """Gets the DB_PASSWORD from environment variables."""
    return os.getenv('DB_PASSWORD')

def get_db_name() -> str | None:
    """Gets the DB_NAME from environment variables."""
    return os.getenv('DB_NAME')
