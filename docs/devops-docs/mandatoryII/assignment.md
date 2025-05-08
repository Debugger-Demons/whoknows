# Mandatory II – DevOps Reflection (Debugger-Demons, Spring 2025)

## 1. Meta

- **Repo:** `github.com/debugger-demons/whoknows`
- **CI/CD Rail:** GitHub Actions → GitHub Container Registry (gh-cr) → Google VM (Ubuntu 22.04)
- **Runtime:** Docker Compose on VM; Prometheus + Grafana checking metrics and logs
- **CLI Helpers:** `gh` CLI, `make`, `cargo`

---

## 2. Branch Strategy & Security

### What strategy did we choose and how was it implemented/enforced?

We adopted the **Git Flow** branching model.

- **Core Branches:**
  - `main`: Production branch. Releases are tagged (e.g., `v1.0.0`, `v1.1.0`). Deploys to the Production environment via the `cd-prod.yml` workflow upon a `v*` tag. This branch is protected.
  - `development`: Default branch. Represents the latest development state. Deploys to the Development environment automatically on merge/push via `cd-dev.yml`. This branch is also protected.
- **Working Branches:**
  - `feature/*`: Branched from `development` for new features.
  - `release/*`: Branched from `development` to prepare for a new production release (e.g., `release-1.0.0`). Allows for stabilization before merging to `main` (and back to `development`).
  - `fix/*`: Branched from `development` for non-urgent bug fixes identified during development.
  - `hotfix/*`: Would be branched from `main` for urgent production bugs, then merged back to `main` and `development`.
    - haven't had a hotfix incident yet
- **Enforcement & Practices:**
  - **Pull Requests (PRs):** All merges into `development` and `main` (from `feature/*`, `release/*`, `hotfix/*`) are done via PRs.
  - **Reviews:** PRs require at least one reviewer from the team.
  - **Automated Bots:** PRs are annotated/reviewed by bots (e.g., CodeRabbit for summaries, DeepSource for static analysis, GitHub Copilot for suggestions).
  - **Branch Protection Rules:** Applied to `main` and `development` (e.g., require PR review, linear history, no force pushes).
  - **Templates:** Standardized Markdown templates for Issues and PRs enforce descriptions, checklists, and links to Kanban cards. (Refs: `/.github/ISSUE_TEMPLATE/`, `/.github/PULL_REQUEST_TEMPLATE.md`).
  - **Team Agreements:** Commit to PR review processes and Kanban board updates.
  - **Kanban Integration:** Issues are linked to branches, and PRs to issues, with some automation for status updates.
- **Release Management Philosophy:**
  - We follow a "proud" philosophy for semantic versioning:
    - `1.0.0` (Major): Significant new features or breaking changes.
    - `1.1.0` (Minor): New features, non-breaking changes (e.g., DB migration from SQLite to PostgreSQL).
    - `1.1.1` ("Shameful" / Patch): Small bug fixes, often post-release.
- **Security Gates:**
  - Branch protection rules (as above).
  - Secrets scanning workflow (`.github/workflows/validate.env_and_secrets.yml`).
  - Dependabot for weekly dependency checks.
  - CI/CD pipelines include stages for testing and validation before deployment (e.g., `cd.branch-test.yml`).

### Why did we choose this strategy (and not others)?

- **Chosen for:**
  - Familiarity and past positive experience within the team with Git Flow.
  - Perceived simplicity for release management, especially with planned distinct releases.
  - Clear separation of development, release preparation, and production code.
- **Why not others?**
  - Why not GitHub Flow?
    - While GitHub Flow offers simplicity for continuous deployment, we anticipated more distinct release phases where Git Flow's `release/*` branches would be beneficial for stabilization.

### What advantages and disadvantages did we experience?

- **Advantages:**
  - Improved clarity and intuition in navigating branches once PRs were consistently used.
  - Automated bot reviews on PRs provided quick feedback and caught potential issues early.
  - Clear separation of `feature/*` branches facilitated parallel development with minimal merge conflicts.
  - Integration with the Kanban board helped visualize work in progress and dependencies.
  - Protected branches (`main`, `development`) and mandatory PR reviews increased confidence when merging code and reduced accidental errors in these key branches.
- **Disadvantages:**
  - Remembering to delete stale `feature/*` branches after merging required discipline.
  - Initial learning curve for team members new to Git Flow.
  - For very small fixes, the full feature branch -> PR process sometimes felt a bit heavyweight.
  - The complexity of the CD pipeline development led to a long-lived feature branch with sub-feature branches, which was sometimes challenging to manage and keep in sync with `development`.

---

## 3. How We've Been DevOps

### Flow, Feedback, and Continual Learning and Experimentation

this has been in connection with the CALMS framework, since it has become more apparent how Culture is key driver for 'ALMS' (and DevOps' in general) success.

### CALMS Framework

This section reflects on our adoption of DevOps principles, inspired by course lectures (including the Eficode guest lecture) and the CALMS model.

| Lens            | Evidence & Reflection                                                                                                                                                                                                                        |
| --------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **C**ulture     | PR reviews for knowledge sharing & quality. Regular team syncs (Tue/Thu) & blameless retros. Good documentation. Positive, collaborative, "no blame" in-person environment.                                                                  |
| **A**utomation  | `make` targets & `gh` CLI for local dev. 3-stage GitHub Actions CI/CD (branch test → dev deploy → prod deploy). Automated DB migrations in pipelines. PR review bots. Kanban integrated with PRs/branches.                                   |
| **L**ean        | Small WIP limits (≤5/dev). Feature toggles for incomplete features. Deploy previews (branch deployments) for shorter feedback loop. Small, well-described commits.                                                                           |
| **M**easurement | Prometheus for counters/histograms. Grafana dashboards for metrics (RPS at `/`, CPU/memory, p95 latency). CI trend badges for test coverage & linter warnings.                                                                               |
| **S**haring     | `/docs/` "markdown garden" (ADRs, runbooks). Pair-review rotation for PRs. Post-merge Slack digests. PR templates & bot summaries for quick change comprehension. Prioritized documentation for independent work & avoiding knowledge silos. |

**Further Reflections on "How We've Been DevOps":**

- **General:**
  - We've made progress in adopting DevOps principles
    - but acknowledge we are not "100% DevOps,"
    - primarily due to inexperience and the learning curve with new tools and processes.
- **Continuous Improvement:**
  - A core focus.
  - We iterated on repository structure and documentation as the project grew in complexity to improve clarity.
- **Documentation:**
  - Essential for backtracking and understanding.
  - However, a challenge was keeping documentation consistently updated as the codebase evolved, leading to occasional discrepancies.
- **WIP & Batch Size:**
  - Reducing WIP and aiming for smaller commits/PRs made reviews easier and context clearer.
  - This was a habit that needed cultivation.
- **Fast Feedback (Inspired by Eficode):**
  - Implemented tools and processes (e.g., CI, deploy previews, bot reviews) to get quicker insights into code quality and deployment readiness.
- **Gaps & Areas for Improvement:**
  - **Silo Identification & Management:**
    - Better identification and management of knowledge or technical silos.
    - Using specialized branches (e.g., for `whoknows_variations`) more effectively might have reduced technical complexity earlier,
    - allowing more focus on DevOps process refinement.
  - **Metrics Coverage:**
    - this could for example be:
      - Deployment Frequency:
        - ie. how often we deploy to production.
      - Lead Time for Changes:
        - ie. the time it takes to make a change and deploy it to production.
      - Change Failure Rate:
        - ie. the rate of failed deployments.
      - MTTR:
        - ie. the time it takes to fix a failed deployment.

---

## 4. Software Quality

We have configured and utilized several tools to analyze and improve software quality:

- Copilot (no config needed),
- CodeRabbit (`.coderabbit.yml`)
- SonarCloud (`.sonar-project.properties`)
- DeepSource (`.deepsource.toml`)
- A pre-commit hook (`.pre-commit-config.yaml`) is also used locally to run some of these checks.

### Our Agreement with Tool Findings (DX (Developer Experience) of Using our Software Quality Tools (DeepSource, SonarQube, CodeRabbit, Copilot))

- The tools can get addictive but the team needs to keep in mind that it does not take business logic into consideration.
- The developer team is liable to become dependent on AI software quality tools, for security analysis, rather than using it as a complimentary tool.

### Issues We Fixed (and Why)

- (DeepSource on Rust): Implemented bots gave a smoother experience for integration and ensured verification for the PR so if the assigne was not sure of the implementation then the bot could give feedback of what has been implemented.

### Issues We Ignored (and Why)

- SonarQube: duplicates of the code in the analysis but we ignored it due to lack of experience in the new coding language.
- DeepSource (Docker): apt install - Agree with the findings but did not fix it. The system works, and it throws no errors, if it throws then it will be an easy fix. We had our focus elsewhere.
- DeepSource (JavaScript): Lack of documentation due to lack of time but will get fixed as we progress in the project.
- CodeClimate: Does not support Rust.

### Integration into CI/CD

- The described tools are part of our CI pipeline, in such way for every PR a developer makes will run the tools to check the status of the code before it gets integrated in the designated branch
  - The tools became a crucial aspect of our CI/CD pipeline. It would catch any unformatted or- unlinted text that slept through the cracks, and would point out known bugs and poor practices that were unknown to us at the time. It thus ensured that we integrated, and deployed code with much fewer errors and bugs.

---

## 5. Monitoring Realization

This section describes a specific instance where our monitoring setup provided a key realization, leading to a system improvement.

- **Our Monitoring Setup (Summary):**

  - **Exporter:** `prometheus_exporter` crate on a `/metrics` endpoint (from `suggestion.assignment.md`).
  - **Visualization:** Grafana 10. Dashboards show metrics like RPS at `/` endpoint, CPU/memory, p95 latency.
    - dashboard metrics:
      - Total Queries at `/` endpoint
  - **Alerting:** Postman daily and weekly monitoring sends mails daily and weekly to the team.
  - **Logging:**

- **The Realization & Fix:**
  - _(User to narrate the "grand realization" story here, covering:_
    - _What specific metric/system aspect were you monitoring that led to the insight?_
    - _What was the unexpected or important insight/realization?_
    - _What action/fix did you implement as a result?_
    - _What was the observable improvement or outcome, as confirmed by monitoring?)_
  - _Example placeholder: "We were monitoring [Metric X] for [System Y]. We noticed [Observation Z], which was unexpected because [Reason]. This led us to investigate [Area A], where we discovered [Problem B]. We implemented [Fix C] by [Action D]. After the fix, monitoring showed that [Metric X] improved by [Amount E], confirming the positive impact."_

---

## 6. Next Steps (Optional, but good for reflection)

- _(User to list potential next steps for improving their DevOps practices, tooling, or system based on their reflections. Examples from `suggestion.assignment.md` include: "extend dashboards (per endpoint, db, cache)", "finish log pipeline (vector → loki) + search panel", "chaos drill before final release")._

---

_This document is a living reflection and will be updated as new insights emerge._
