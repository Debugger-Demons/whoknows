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
	i-create-enhancement i-create-bug i-create-dependencies i-create-documentation

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

# === Help ===

# Show help
help:
	@echo "--------------------------------------------------------"
	@echo "Available commands:"
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