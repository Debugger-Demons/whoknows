# SQLx Offline Mode Workflow

Okay, let's outline the typical workflow for using `sqlx`'s offline mode, especially thinking about how it fits into a Docker build process where the live database might not be present during the main compilation.

The core idea is to separate the *preparation* step (which needs the database) from the *compilation* step (which uses the prepared data).

## Setup and Workflow

Here's the usual flow:

1.  **Install `sqlx-cli`:** You need the command-line tool `sqlx-cli` installed in the environment where you'll run the preparation step.
    ```bash
    cargo install sqlx-cli
    ```

2.  **Ensure Database Accessibility:** The environment where you run `sqlx prepare` *must* be able to connect to your actual database. In your case, this means having access to the `whoknows.old.db` file and having the correct `DATABASE_URL` (like `sqlite://whoknows.old.db`) set, probably via the `.env.local.backend` file.

3.  **Run `sqlx prepare`:** Execute the command to prepare the queries:
    ```bash
    # If using normal .env file
    sqlx prepare --database-url <your_database_url>
    
    # If using our project's .env.local.backend
    dotenv -f .env.local.backend run -- sqlx prepare
    ```
    
    You can often omit the `--database-url` if the `DATABASE_URL` environment variable is correctly set. This command does the following:
    *   Connects to your database.
    *   Analyzes all the SQL queries within your `sqlx::query!` (and related) macros.
    *   Saves metadata about these queries (like expected input types and output columns) into a file named `sqlx-data.json` in your project root (or wherever `Cargo.toml` is).

4.  **Configure `Cargo.toml`:** Make sure your `sqlx` dependency in `Cargo.toml` includes the necessary features for your database and runtime (e.g., `features = ["runtime-tokio-rustls", "sqlite", "chrono"]`), but *do not* include `offline` as a feature.

5.  **Build Your Application:** Now, when you run your build (with make commands or directly):
    ```bash
    # Using Cargo Make for development
    cargo make dev
    
    # Or using Docker
    cargo make dev-docker
    # or from project root
    make build-backend
    make run-backend
    ```
    
    The `sqlx` macros will detect the `sqlx-data.json` file and use the information in that file to perform compile-time verification of your SQL queries without needing to connect to the database itself.

## Applying this to Docker

The key challenge in Docker is that the build environment for `cargo build` is often separate and might not have the `.db` file. Here's how you address that:

*   **Generate `sqlx-data.json` *Before* or *Early* in the Docker Build:**
    *   **Option A (Recommended for Simplicity):** Run `sqlx prepare` locally on your development machine *before* you even start the `docker build`. Commit the generated `sqlx-data.json` to your repository. Then, in your `Dockerfile`, simply `COPY` the entire project context (including `sqlx-data.json`) into the build stage before running `cargo build`.
    *   **Option B (Multi-stage Docker Build):**
        1.  Have an initial stage in your `Dockerfile` that *does* copy the `.db` file and the `.env` file.
        2.  In that stage, install `sqlx-cli`.
        3.  Run `sqlx prepare`.
        4.  In the *next* build stage (the one that builds the final release binary), `COPY --from=<previous_stage_name> .../sqlx-data.json .` to bring the metadata file over.
        5.  Then run `cargo build`. This stage doesn't need the `.db` file or `sqlx-cli`.

*   **Dockerfile Changes:**
    *   Ensure `sqlx-data.json` is copied into the build container *before* `cargo build` is executed.
    *   The `cargo build` command itself doesn't need the `DATABASE_URL` environment variable set, nor does it need access to the `.db` file.
