### Overview

Refactor the deployment process to use Docker image labels for targeted pruning of unused application images on the deployment server. This improves cleanup safety and specificity by avoiding the removal of unrelated images or cached layers belonging to other projects or Docker operations on the server.

### Technical Context

**Current State:**

- The `deployment/scripts/deploy.sh` script is responsible for deploying the application via Docker Compose and cleaning up old Docker images.
- An attempt was made to use `docker image prune --filter reference=ghcr.io/debugger-demons/whoknows/*` for targeted cleanup.
- This `reference=` filter fails on the target deployment server (`Error response from daemon: invalid filter 'reference'`), likely due to Docker version limitations or subtle incompatibilities, even after a Docker version update was performed.
- The current working fallback in `deploy.sh` uses `docker image prune -af`, which prunes _all_ unused images on the system, not just those belonging to the 'whoknows' application. This is functional but overly broad and potentially disruptive to other processes or cached layers on the server.

**Target State:**

- Docker images for the 'whoknows' application (both `backend` and `frontend`) are consistently built with a standard `application="whoknows"` label (or another agreed-upon label key/value).
- The `deployment/scripts/deploy.sh` script is updated to use `docker image prune -af --filter label=application=whoknows` for the image cleanup step.
- This command leverages Docker's label filtering, which is supported on the target server's Docker version.
- The deployment process safely and specifically removes only unused images belonging to _this_ application, preserving unrelated images and layers.

**Dependencies:**

- Requires modifications to `backend/Dockerfile` and `frontend/Dockerfile` to add the `LABEL` instruction.
- Requires modification to the `cleanup_docker_images` function within `deployment/scripts/deploy.sh`.
- The CI/CD pipeline (`build-push` job in the GitHub Actions workflow) must successfully build and push images containing the new labels _before_ the updated `deploy.sh` script is deployed and executed.

### Acceptance Criteria

- [ ] `backend/Dockerfile` updated with `LABEL application="whoknows"` (or chosen standard).
- [ ] `frontend/Dockerfile` updated with `LABEL application="whoknows"` (or chosen standard).
- [ ] `deployment/scripts/deploy.sh` updated to use `docker image prune --filter label=application=whoknows` (or chosen standard).
- [ ] CI/CD pipeline successfully builds and pushes images containing the specified label.
- [ ] Deployment script runs successfully on the target server using the label filter for pruning.
- [ ] Verification on the server confirms that `docker image prune` (as run by the script) only removes unused `whoknows` images and leaves other unrelated images/layers untouched.
- [ ] Documentation (e.g., README section on deployment or Docker image standards) updated if necessary.
- [ ] PR review completed and changes merged.

### Resources

**Related Documentation:**

- Docker Builder `LABEL` instruction: https://docs.docker.com/engine/reference/builder/#label
- `docker image prune` command (including `--filter`): https://docs.docker.com/engine/reference/commandline/image_prune/
- Open Container Initiative (OCI) standard image labels (good practice): https://github.com/opencontainers/image-spec/blob/main/annotations.md

**Relevant Files (Current State):**

- `deployment/scripts/deploy.sh` (specifically the `cleanup_docker_images` function)
- `backend/Dockerfile`
- `frontend/Dockerfile`
- GitHub Actions workflow responsible for build/push (e.g., `cd.branch-test.yml` or similar)
