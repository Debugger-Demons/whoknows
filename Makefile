# Makefile for updating environment secrets and creating pull requests

update-env-secrets:
	@echo "Updating prod and dev .env secrets..."
	@cat .env.production | gh secret set PROD_ENV_FILE -b -
	@cat .env.development | gh secret set DEV_ENV_FILE -b -
	@echo "Secrets updated successfully!"

# Alternative approach using the -f flag to set individual env vars as secrets
update-env-vars:
	@echo "Updating individual environment variables as secrets..."
	@gh secret set -f .env.production
	@gh secret set -f .env.development
	@echo "Environment variables updated successfully!"

pr-create:
	@echo "Creating pull request..."
	@make update-env-secrets
	@gh pr create

# Show help
help:
	@echo --------------------------------------------------------
	@echo Available commands:
	@echo ----
	@echo "  make update-env-secrets  - Update the PROD_ENV_FILE and DEV_ENV_FILE with entire env file contents"
	@echo "  make update-env-vars     - Set each variable in env files as individual secrets"
	@echo "  make pr-create           - Create a pull request with the updated env secrets"
	@echo ----
	@echo "  make help               - Show this help message"
	@echo --------------------------------------------------------
