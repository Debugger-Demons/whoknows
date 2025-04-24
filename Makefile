# Makefile for updating environment secrets, creating issues, and pull requests

# === Configuration ===
# Define fixed parameters for easy modification
GH_REPO := Debugger-Demons/whoknows
GH_PROJECT := whoknows-kanban
GH_ASSIGNEE := @me
ISSUE_TITLE_PREFIX := "[DEV]: "

# Allow shorthands for issue creation: t for TITLE_DESC, f for BODY_FILE
TITLE_DESC := $(if $(t),$(t),$(TITLE_DESC))
BODY_FILE  := $(if $(f),$(f),$(BODY_FILE))

# === Phony Targets ===
# Declare targets that don't represent files
.PHONY: help update-env-secrets update-env-vars pr-create i-create \
	i-create-enhancement i-create-bug i-create-dependencies i-create-documentation \
	build-frontend run-frontend stop-frontend

# === Compose Management ===
run-compose: 
	@echo "Running compose..."
	python ./scripts/check_env.py
	docker compose up -d

stop-compose:
	@echo "Stopping compose..."
	docker compose down

clean-compose:
	@echo "Cleaning compose..."
	docker stop whoknows.local.backend 
	docker stop whoknows.local.frontend
	docker rm whoknows.local.backend
	docker rm whoknows.local.frontend
	docker rmi whoknows.local.backend
	docker rmi whoknows.local.frontend
	@echo "Compose cleaned up!"



# === Frontend Management ===
build-frontend:
	@echo "Building frontend Docker image..."
	docker build -t whoknows.frontend --build-arg FRONTEND_INTERNAL_PORT=91 --build-arg BACKEND_INTERNAL_PORT=92 --build-arg COMPOSE_PROJECT_NAME=whoknows --build-arg NODE_ENV=production ./frontend

run-frontend: build-frontend
	@echo "Running frontend container..."
	docker run -d --name whoknows_frontend_test -p 8080:91 -e FRONTEND_INTERNAL_PORT=91 -e BACKEND_INTERNAL_PORT=92 -e COMPOSE_PROJECT_NAME=whoknows -e NODE_ENV=production whoknows.frontend
	@echo "Frontend is now running at http://localhost:8080"

stop-frontend:
	@echo "Stopping frontend container..."
	docker stop whoknows_frontend_test || true
	docker rm whoknows_frontend_test || true

# === Backend Management ===
build-backend:
	@echo "Building backend Docker image..."
	docker build -t whoknows.backend --build-arg BACKEND_INTERNAL_PORT=92 --build-arg COMPOSE_PROJECT_NAME=whoknows --build-arg NODE_ENV=production ./backend

run-backend: build-backend
	@echo "Running backend container..."
	docker run -d --name whoknows_backend_test -p 92:92 -e BACKEND_INTERNAL_PORT=92 -e COMPOSE_PROJECT_NAME=whoknows -e NODE_ENV=production whoknows.backend
	@echo "Backend is now running at http://localhost:92"

stop-backend:
	@echo "Stopping backend container..."
	docker stop whoknows_backend_test || true
	docker rm whoknows_backend_test || true



# === Environment Secret Management ===

env-update:
	@echo "Updating prod and dev .env secrets..."
	@gh secret set PROD_ENV_FILE < .env.production
	@gh secret set DEV_ENV_FILE < .env.development
	@echo "Secrets updated successfully!"

# === Pull Request Creation ===

# Create a pull request with the updated env secrets
# -> This assumes you have a branch already created for the changes
pr-create: env-update
	@echo "Creating pull request..."
	@gh pr create
	@echo "Pull request created successfully!"
# === GitHub Issue Creation ===

# --- Main Issue Creation Target ---
# Creates a GitHub issue with predefined repo, project, assignee, and title prefix.
# Requires TITLE_DESC, LABEL, and BODY_FILE variables to be passed.
i-create:
	@# Input validation
	@if [ -z "$(TITLE_DESC)" ]; then \
		echo "ERROR: TITLE_DESC variable is required for issue title." >&2; \
		$(MAKE) help; \
		exit 1; \
	fi
	@if [ -z "$(LABEL)" ]; then \
		echo "ERROR: LABEL variable is required." >&2; \
		$(MAKE) help; \
		exit 1; \
	fi
	@if [ -z "$(BODY_FILE)" ]; then \
		echo "ERROR: BODY_FILE variable is required." >&2; \
		$(MAKE) help; \
		exit 1; \
	fi
	@if [ ! -f "$(BODY_FILE)" ]; then \
		echo "ERROR: Body file not found: $(BODY_FILE)" >&2; \
		exit 1; \
	fi

	@# Confirmation message
	@echo "Creating issue in repo '$(GH_REPO)' and project '$(GH_PROJECT)'..."
	@echo "  Title    : $(ISSUE_TITLE_PREFIX)$(TITLE_DESC)"
	@echo "  Assignee : $(GH_ASSIGNEE)"
	@echo "  Label    : $(LABEL)"
	@echo "  Body File: $(BODY_FILE)"

	@# Execute the command
	@gh issue create --title "$(ISSUE_TITLE_PREFIX)$(TITLE_DESC)" \
		-a "$(GH_ASSIGNEE)" \
		-l "$(LABEL)" \
		-p "$(GH_PROJECT)" \
		-F "$(BODY_FILE)" \
		--repo "$(GH_REPO)"

# --- Shortcut Targets for Issue Labels ---
i-create-enhancement:
	@$(MAKE) i-create LABEL="enhancement" TITLE_DESC="$(TITLE_DESC)" BODY_FILE="$(BODY_FILE)"

i-create-bug:
	@$(MAKE) i-create LABEL="bug" TITLE_DESC="$(TITLE_DESC)" BODY_FILE="$(BODY_FILE)"

i-create-dependencies:
	@$(MAKE) i-create LABEL="dependencies" TITLE_DESC="$(TITLE_DESC)" BODY_FILE="$(BODY_FILE)"

i-create-documentation:
	@$(MAKE) i-create LABEL="documentation" TITLE_DESC="$(TITLE_DESC)" BODY_FILE="$(BODY_FILE)"



# ====================================================================
# ============================== release =============================

# make release tag="v1.0.0"
release:
	@echo "creating release"
	@python ./scripts/release/release.py $(tag)
	@echo "release successful"

# ====================================================================
# =============================== Help ===============================

# Show help
help:
	@echo "--------------------------------------------------------"
	@echo "Available commands:"
	@echo ""

	@echo "---- Compose Management ----"
	@echo ""
	@echo "  make run-compose         - Run the compose"
	@echo "  make stop-compose        - Stop the compose"
	@echo "  make clean-compose       - Clean the compose"
	@echo ""
	@echo "---- Frontend Management ----"
	@echo ""
	@echo "  make build-frontend       - Build the frontend Docker image"
	@echo "  make run-frontend         - Build and run the frontend container"
	@echo "  make stop-frontend        - Stop and remove the frontend container"
	@echo ""
	@echo "---- Environment & PR Management ----"
	@echo ""
	@echo "  make pr-create           "
	@echo ""
	@echo "  make env-update  		-- Updates PROD_ENV_FILE & DEV_ENV_FILE secrets"
	@echo ""
	@echo "---- GitHub Issue Creation ----"
	@echo ""
	@echo "  make i-create-enhancement ..."
	@echo "  make i-create-bug ..."
	@echo "  make i-create-dependencies ..."
	@echo "  make i-create-documentation ..."
	@echo ""
	@echo "  fx. make i-create-enhancement t=\"Improve performance of API endpoint\" f=\"./docs/issues/perf_issue_body.md\""
	@echo ""
	@echo "---- General ----"
	@echo "  make help                - Show this help message."
	@echo "--------------------------------------------------------"
