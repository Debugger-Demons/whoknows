# Security Testing Implementation Guide

This document outlines the security testing strategy for your Rust/Actix + React project, including both Static Application Security Testing (SAST) and Dynamic Application Security Testing (DAST) approaches.

## Overview

Our security testing approach follows these principles:

- Security testing happens early in the development lifecycle
- Both code and runtime environments are tested
- Security findings are prioritized based on severity
- Automated testing runs on every PR and merge to main branches

## SAST (Static Application Security Testing)

SAST analyzes source code to identify potential security vulnerabilities without executing the application.

### Tools for Rust Backend

1. **cargo-audit**

   - Scans dependencies for known vulnerabilities
   - Checks against the RustSec Advisory Database
   - Installation: `cargo install cargo-audit`
   - Usage: `cargo audit`

2. **Clippy**

   - Identifies unsafe code patterns
   - Finds potential security issues in code
   - Installation: `rustup component add clippy`
   - Usage: `cargo clippy -- -D warnings`

3. **cargo-deny** (optional)
   - Checks licenses, security advisories, and banned dependencies
   - Installation: `cargo install cargo-deny`
   - Usage: `cargo deny check`

### Tools for React Frontend

1. **npm audit**

   - Checks dependencies for known vulnerabilities
   - Usage: `npm audit`

2. **ESLint with security plugins**
   - Add security-focused ESLint plugins:
   ```bash
   npm install --save-dev eslint-plugin-security
   ```
   - Configure in `.eslintrc.js`:
   ```js
   {
     "plugins": ["security"],
     "extends": ["plugin:security/recommended"]
   }
   ```

## DAST (Dynamic Application Security Testing)

DAST tests running applications to find vulnerabilities that only appear at runtime.

### OWASP ZAP

OWASP Zed Attack Proxy (ZAP) scans running applications for security vulnerabilities:

1. **Setup**
   - Create `.zap` directory in your repository
   - Add the `rules.tsv` file for configuring rules
2. **Integration**
   - ZAP runs against the fully deployed application
   - Findings are uploaded as artifacts for review

### Container Scanning

Trivy scans container images for vulnerabilities:

1. **Integration**
   - Scans both frontend and backend Docker images
   - Produces SARIF reports for GitHub Security tab
   - Focuses on high and critical severity issues

## Implementation

### Directory Structure

```
.github/
  workflows/
    security.yml   # Main security workflow
.zap/
  rules.tsv       # ZAP configuration rules
```

### Setup Instructions

1. **Install workflow file**

   - Place the `security.yml` file in `.github/workflows/`

2. **Configure ZAP**

   - Create `.zap` directory in your repository
   - Add the `rules.tsv` file to customize ZAP rules

3. **Add local testing scripts** (optional)
   - Create scripts for running security tests locally
   - Example: `./scripts/run-security-checks.sh`

## Best Practices

1. **Fix vulnerabilities promptly**

   - Prioritize by severity
   - Document false positives or accepted risks

2. **Test locally before pushing**

   - Run SAST tools before creating PRs
   - Use Docker for local container scanning

3. **Review security reports**

   - Check GitHub Security tab regularly
   - Review workflow artifacts for detailed reports

4. **Update tools regularly**
   - Keep security tools up to date
   - Update baseline rules as needed

## Additional Resources

- [RustSec Advisory Database](https://rustsec.org/)
- [OWASP Top Ten](https://owasp.org/www-project-top-ten/)
- [Trivy Documentation](https://aquasecurity.github.io/trivy/)
- [ZAP Documentation](https://www.zaproxy.org/docs/)
