
# Contributing to Whoknows - Rust ActixWeb

## Quick Start

1. Fork the repository (external) or create a branch (team member)
2. Make your changes following our standards
3. Submit a [PR](../../.github/templates/PULL_REQUEST_TEMPLATE.md) with clear description and purpose
4. Respond to review feedback
5. Your PR will be merged after approval

## Branch Naming

- `feat/` - New features (e.g., feature/search-api)
- `bugfix/` - Bug fixes (e.g., bugfix/login-error)
- `hotfix/` - Critical fixes (e.g., hotfix/security-patch)
- `docs/` - Documentation (e.g., docs/api-guide)
- `release/` - Release preparation (e.g., release/v1.2.0)

## Development Standards

### Git Practices
- Write clear commit messages describing why not what
- Keep commits focused and logical
- Use default branch (development) for feature development and testing
- Delete branches after merge (always merge to 'development')
- Don't use main, it is protected and solely for releases (CI/CD) -- i.e. its a production branch

### Code Standards
- Follow Rust style guide (use clippy)
- Add tests for new features
- Run Clippy (cargo clippy) and fix warnings before committing
- Update documentation
- Ensure CI checks pass


### PR Guidelines
- Use PR template
- Keep changes focused
- Add useful description
- Link related issues
- Request review from relevant team members

### Never Commit (all mentioned are in .gitignore)
- IDE settings (.idea, .vscode)
- OS files (.DS_Store)
- Build artifacts (__pycache__)
- Environment files (.env)
- Dependency directories (node_modules)

## Review Process

1. Submit PR
2. Address automated check failures
3. Respond to reviewer feedback
4. Get approval
5. Merge when ready
6. Delete branch after merge

## Getting Help

- Check existing issues and documentation
- Ask in team chat for clarification
- Tag relevant maintainers in PR

## Local Development

See [Development Setup](docs/development/setup/rust_setup.md) for detailed environment setup.
