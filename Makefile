# Makefile for updating environment secrets and creating pull requests

update-env-secrets:
	@echo "Updating prod and dev .env secrets..."
	@gh secret set PROD_ENV_FILE --body-file .env.production
	@gh secret set DEV_ENV_FILE --body-file .env.development
	@echo "Secrets updated successfully!"

pr-create:
	@echo "Creating pull request..."
	update-env-secrets
	@gh pr create

# Show help
help:
	@echo --------------------------------------------------------
	@echo Available commands:
	@echo --
	@echo   make update-env-secrets  	- Update the PROD_ENV_FILE with updated .env.production and Update DEV_ENV_FILE with updated .env.development
	@echo   make pr-create           	- Create a pull request with the updated env secrets
	@echo --------------------------------------------------------

