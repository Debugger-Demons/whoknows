# CodeRabbit AI

We use CodeRabbit AI to automate linting and provide summaries of code changes in pull requests to the development branch.

## Installation

CodeRabbit doesn't require terminal installation. Instead, it needs to be activated on your personal GitHub account through the following link:

[CodeRabbit AI on GitHub Marketplace](https://github.com/marketplace/coderabbitai)

## Configuring CodeRabbit AI

You can configure CodeRabbit AI using either of these methods:

1. **Web Interface**  
   Manually adjust settings for specific repositories at [CodeRabbit Settings](https://app.coderabbit.ai/settings/repositories)  
   _Use "Login with GitHub" to access your account_

2. **Configuration File**  
   Create a `.coderabbit.yml` file in your repository's root directory

### YAML Configuration

To enable live validation of your configuration files, add this line to your `.coderabbit.yml`:

```yaml
# yaml-language-server: $schema=https://coderabbit.ai/integrations/schema.v2.json
```

We recommend using the [YAML extension by Red Hat](https://developers.redhat.com/products/vscode-extensions/overview#openshiftconnector3965) as your YAML language server.
