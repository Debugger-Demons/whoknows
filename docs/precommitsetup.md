
# Pre-commit
This guide explains how to install and setup pre-commit.

## Step 1: Install pre-commit Python Package
1. Make sure you have Python installed on your system.
2. Install the pre-commit package globally using the following command:
pip install pre-commit

## Step 2: Setup
1. Install pre-commit hooks in your project by running:
pre-commit install

2. Verify pre-commit hooks are working
git add .
git commit -m "Test pre-commit hooks"
If any hook fails (e.g., formatting errors), the commit will be prevented, and you’ll see the relevant message.

3. Run all hooks manually (optional)
pre-commit run --all-files

## Troubleshooting
If you encounter any issues, here are some steps to try:
- pre-commit not found: Ensure that pre-commit is installed and available in your system’s PATH.
- Hooks not running: Ensure that pre-commit install has been run correctly and that .git/hooks/pre-commit exists.
- Hook errors: If a hook fails (e.g., due to coding style issues), fix the errors and reattempt the commit.
