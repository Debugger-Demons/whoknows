# WhoKnows Search Engine

A search engine originally developed by Monks in 2009, now being modernized by the next generation ('Debugger Demons').

## Project Overview

This repository contains both the legacy search engine and its modern rewrite, demonstrating the evolution from a Python-based monolith to a modern Rust-based system.

### Repository Structure

```
whoknows/
├── docs/               # Project documentation
|   └── Legacy_Analysis # system analysis
├── src/
│   ├── legacy/         # Original 2009 Python codebase
│   └── Rust_Actix/     # Modern implementation
│       ├── backend/
│       ├── frontend/
│       └── docs/
└── README.md
```

## Vision and Goals

- Evolution from a **basic search engine** to a **modern knowledge _discovery_ platform**
- Implementing modern architectural patterns and best practices
- Facilitating both **human and _agent_ knowledge discovery**
- Enhanced data processing through **graph database integration**

## Legacy analysis

Our analysis of the legacy codebase revealed significant technical debt and security concerns:

- [Detailed Problems Analysis](docs/Legacy_Analysis/list_problems_Legacy_Codebase.md)
- [Tech Stack Architecture](docs/Legacy_Analysis/legacy.tech_stack_architecture.png)
- [Dependency Graph](docs/Legacy_Analysis/legacy.dependency_graph.svg)

Key findings include:

- SQL injection vulnerabilities,
- outdated dependencies,
- and architectural issues that necessitated our modernization effort.

## Technology Stack Evolution

| Component       | Legacy (2009)    | Modern                    | Purpose         |
| --------------- | ---------------- | ------------------------- | --------------- |
| Language        | Python 2.7       | Rust 1.5                  | Core Runtime    |
| Web Framework   | Flask 0.5        | Actix-web 4.4.0           | HTTP Server     |
| Template Engine | Jinja2 2.4       | (Frontend Framework TBD)  | UI Rendering    |
| ORM/DB Access   | Raw SQL          | SQLx 0.7                  | Data Access     |
| Database        | SQLite           | Neo4j + SQLite            | Data Storage    |
| Serialization   | Built-in         | Serde 1.0                 | Data Processing |
| Async Runtime   | N/A              | Tokio 1.0                 | Concurrency     |
| Logging         | Print statements | env_logger 0.10 + log 0.4 | Observability   |

### Legacy Stack Challenges

- Python 2.7 (EOL since 2020)
- Outdated dependencies with no security updates
- Limited scalability and performance
- No modern development tooling support
- Critical security vulnerabilities
- Poor error handling and logging
- Architectural limitations

### Modern Stack Benefits

- Type safety and performance with Rust
- Robust async processing capabilities
- Enhanced security and maintainability
- Modern development workflow support
- Graph database for advanced data relationships
- Comprehensive error handling
- Modern security practices

## Getting Started

- [Legacy System Documentation](src/legacy/README.md)
- [Modern System Documentation](src/Rust_Actix/README.md)
- [Development Guide](src/Rust_Actix/docs/Getting-Started.md)

## Branching strategy

We are using Gitflow branching strategy. Below is a visualization of the given strategy
![Branch strategy](src\Rust_Actix\docs\assets\branchstrategy.webp)

## License

This project is licensed under the terms included in [LICENSE](LICENSE).
