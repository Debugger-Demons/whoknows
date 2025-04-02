# Makefile for updating environment secrets and creating pull requests

update-env-secrets:
	@echo "Updating prod and dev .env secrets..."
	@cat .env.production | gh secret set PROD_ENV_FILE -b -
	@cat .env.development | gh secret set DEV_ENV_FILE -b -
	@echo "Secrets updated successfully!"

# Alternative approach using the -f flag to set individual env vars as secrets
update-env-vars:
	@echo "Updating individual environment variables as secrets..."
	@gh secret set PROD_ENV_FILE < .env.production
	@gh secret set DEV_ENV_FILE < .env.development
	@echo "Environment variables updated successfully!"

# Create a pull request with the updated env secrets
# -> This assumes you have a branch already created for the changes
pr-create:
	@echo "Creating pull request..."
	@make update-env-secrets
	@gh pr create
	@echo "Pull request created successfully!"

# Show help
help:
	@echo --------------------------------------------------------
	@echo Available commands:
	@echo ----
	@echo   make pr-create           - Create a pull request with the updated env secrets
	@echo   			               	- requires:
	@echo  				               	- new branch
	@echo  				               	- gh cli installed and authenticated
	@echo  				               	- .env files in the root directory
	@echo   make update-env-secrets  - Update the PROD_ENV_FILE and DEV_ENV_FILE with entire env file contents
	@echo   			               	- updates:
	@echo   			               		- PROD_ENV_FILE with .env.production contents
	@echo   			               		- DEV_ENV_FILE with .env.development contents
	@echo   make update-env-vars     - Set each variable in env files as individual secrets
	@echo ----
	@echo   make help               	- Show this help message
	@echo --------------------------------------------------------
