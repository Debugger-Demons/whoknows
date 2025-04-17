# Docker setup

## Setup

This documentation contains information about our docker envrionment.

### Frontend

### Backend

The backend container uses an image built with a specific Rust version to ensure fast deployment and consistent runtime behavior. While it is possible to run the backend locally using cargo run, our containerized solution is not intended to replace local development workflows.

Instead, the purpose of containerizing the backend is to facilitate communication between services — such as the frontend and the database — within a Docker network. Each service remains isolated in its own container, which improves security, maintainability, and modularity, while allowing seamless inter-service communication through Docker’s internal networking.

### Database
