"""
   Builds and runs the Docker container for local development.
   - using .env.local.frontend 
   running: 
   'docker build -t ${COMPOSE_PROJECT_NAME} . 
      && docker run --rm -d 
         --env-file .env.local.frontend 
         -p ${FRONTEND_INTERNAL_PORT}:${FRONTEND_EXTERNAL_PORT} 
         ${COMPOSE_PROJECT_NAME}'
"""
import sys
import subprocess
import makefile_env_loader

PROJECT_NAME = makefile_env_loader.get_project_name()
FRONTEND_CONTAINER_NAME = f"{PROJECT_NAME}"
FRONTEND_PORT = makefile_env_loader.get_frontend_port()
BACKEND_PORT = makefile_env_loader.get_backend_port()

def get_build_cmd(project_name_prm="whoknows.frontend.test") -> str | None:
   """ docker build -t ${project_name} . """
   return f"docker build -t {project_name_prm} ."

def get_run_cmd(frontend_port_prm="8080", image_name="whoknows.frontend.test") -> str | None:
   """ 
   docker run --rm -d 
         --env-file .env.local.frontend 
         -p ${FRONTEND_INTERNAL_PORT}:${FRONTEND_EXTERNAL_PORT} 
         ${COMPOSE_PROJECT_NAME} 
   """
   return f"docker run --rm -d --env-file .env.local.frontend -p {frontend_port_prm}:{frontend_port_prm} {image_name}"

cmds = {
   "build": get_build_cmd(PROJECT_NAME),
   "run": get_run_cmd(FRONTEND_PORT, FRONTEND_CONTAINER_NAME)
}

def cmd_build_run_combined():
   """ combined docker build && docker run """
   return f"{cmds["build"]} && {cmds['run']}"

def run_dev_docker():
   """ executing the dev-docker commands for building and running container with env variables """
   subprocess.run(cmd_build_run_combined(), shell=True, check=False)

if __name__ == "__main__":
   if not makefile_env_loader.check_env():
      print(" \n"
            "Error: Required environment file .env.local.frontend not found.\n"
            "-> copy and edit the template: \n"
            "  cp .env.local.frontend.template .env.local.frontend \n"
            " \n",
            file=sys.stderr)
      sys.exit(1)
      
   run_dev_docker()
