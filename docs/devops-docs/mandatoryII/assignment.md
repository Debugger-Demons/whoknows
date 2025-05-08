# Mandatory II

## Reflection

# Mandatory II – DevOps Reflection (Debugger-Demons, Spring 2025)

> This document collates reflections for Mandatory II.
> Required headers: Meta, Branch Strategy & Security, How We've Been DevOps (CALMS), Software Quality, Monitoring Realization, and Next Steps.

---

## 0. Meta

*   **Repo:** `github.com/debugger-demons/whoknows`
*   **CI/CD Rail:** GitHub Actions → GitHub Container Registry (gh-cr) → Google VM (Ubuntu 22.04)
*   **Runtime:** Docker Compose on VM; Prometheus + Grafana checking metrics and logs
*   **CLI Helpers:** `gh` CLI, `make`, `cargo` 

---

## 1. Branch Strategy & Security

### What strategy did we choose and how was it implemented/enforced?

We adopted the **Git Flow** branching model.
*   **Core Branches:**
    *   `main`: Production branch. Releases are tagged (e.g., `v1.0.0`, `v1.1.0`). Deploys to the Production environment via the `cd-prod.yml` workflow upon a `v*` tag. This branch is protected.
    *   `development`: Default branch. Represents the latest development state. Deploys to the Development environment automatically on merge/push via `cd-dev.yml`. This branch is also protected.
*   **Working Branches:**
    *   `feature/*`: Branched from `development` for new features.
    *   `release/*`: Branched from `development` to prepare for a new production release (e.g., `release-1.0.0`). Allows for stabilization before merging to `main` (and back to `development`).
    *   `fix/*`: Branched from `development` for non-urgent bug fixes identified during development.
    *   `hotfix/*`: Would be branched from `main` for urgent production bugs, then merged back to `main` and `development`. 
        *   haven't had a hotfix incident yet
*   **Enforcement & Practices:**
    *   **Pull Requests (PRs):** All merges into `development` and `main` (from `feature/*`, `release/*`, `hotfix/*`) are done via PRs.
    *   **Reviews:** PRs require at least one reviewer from the team.
    *   **Automated Bots:** PRs are annotated/reviewed by bots (e.g., CodeRabbit for summaries, DeepSource for static analysis, GitHub Copilot for suggestions).
    *   **Branch Protection Rules:** Applied to `main` and `development` (e.g., require PR review, linear history, no force pushes).
    *   **Templates:** Standardized Markdown templates for Issues and PRs enforce descriptions, checklists, and links to Kanban cards. (Refs: `/.github/ISSUE_TEMPLATE/`, `/.github/PULL_REQUEST_TEMPLATE.md`).
    *   **Team Agreements:** Commit to PR review processes and Kanban board updates.
    *   **Kanban Integration:** Issues are linked to branches, and PRs to issues, with some automation for status updates.
*   **Release Management Philosophy:**
    *   We follow a "proud" philosophy for semantic versioning:
        *   `1.0.0` (Major): Significant new features or breaking changes.
        *   `1.1.0` (Minor): New features, non-breaking changes (e.g., DB migration from SQLite to PostgreSQL).
        *   `1.1.1` ("Shameful" / Patch): Small bug fixes, often post-release. *(User to elaborate on how "shameful" releases are branched/tagged if different from standard hotfixes or minor bumps).*
*   **Security Gates:**
    *   Branch protection rules (as above).
    *   Secrets scanning workflow (`.github/workflows/validate.env_and_secrets.yml`).
    *   Dependabot for weekly dependency checks.
    *   CI/CD pipelines include stages for testing and validation before deployment (e.g., `cd.branch-test.yml`).

### Why did we choose this strategy (and not others)?

*   **Chosen for:**
    *   Familiarity and past positive experience within the team with Git Flow.
    *   Perceived simplicity for release management, especially with planned distinct releases.
    *   Clear separation of development, release preparation, and production code.
*   **Why not others?**
    *   Why not GitHub Flow? 
        *   "While GitHub Flow offers simplicity for continuous deployment, we anticipated more distinct release phases where Git Flow's `release/*` branches would be beneficial for stabilization."

### What advantages and disadvantages did we experience?

*   **Advantages:**
    *   Improved clarity and intuition in navigating branches once PRs were consistently used.
    *   Automated bot reviews on PRs provided quick feedback and caught potential issues early.
    *   Clear separation of `feature/*` branches facilitated parallel development with minimal merge conflicts.
    *   Integration with the Kanban board helped visualize work in progress and dependencies.
    *   Protected branches (`main`, `development`) and mandatory PR reviews increased confidence when merging code and reduced accidental errors in these key branches.
*   **Disadvantages:**
    *   Remembering to delete stale `feature/*` branches after merging required discipline.
    *   Initial learning curve for team members new to Git Flow.
    *   For very small fixes, the full feature branch -> PR process sometimes felt a bit heavyweight.
    *   The complexity of the CD pipeline development led to a long-lived feature branch with sub-feature branches, which was sometimes challenging to manage and keep in sync with `development`.

---

## 2. How We've Been DevOps – CALMS Framework

This section reflects on our adoption of DevOps principles, inspired by course lectures (including the Eficode guest lecture) and the CALMS model.

| Lens            | Evidence & Reflection                                                                                                                                                                                                                                                                                                                                                        |
| --------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **C**ulture     | Actively used PR reviews for knowledge sharing and quality control. Attempted regular team sync meetings (Tuesdays/Thursdays) and blameless retrospectives. Maintained good documentation. Fostered a positive, collaborative environment in person, with a "no blame" approach to issues.                                                                     |
| **A**utomation  | Leveraged `make` targets and `gh` CLI for local dev tasks. Implemented 3-stage GitHub Actions CI/CD pipelines (branch testing → dev deployment → prod deployment). Automated database migrations within pipelines. Utilized PR review bots. Integrated Kanban board with PRs and branches.                                                                                      |
| **L**ean        | Aimed for small Work-In-Progress (WIP) limits (e.g., ≤5 per dev). Used feature toggles to guard incomplete features in shared branches. Employed deploy previews (branch deployments) to significantly shorten the feedback loop. Strived for small, well-described commits.                                                                                                     |
| **M**easurement | Implemented Prometheus for counters and histograms. Utilized Grafana dashboards to visualize metrics (e.g., RPS at `/` endpoint, CPU/memory usage, p95 latency). CI trend badges provided insights into test coverage and linter warnings.                                                                                                     |
| **S**haring     | Maintained a `/docs/` "markdown garden" including Architecture Decision Records (ADRs) and runbooks. Practiced pair-review rotation for PRs. Used post-merge Slack digests for team awareness. PR templates and bot summaries aided in quick understanding of changes. Ensured documentation was a priority to enable independent work and avoid knowledge silos.                               |

**Further Reflections on "How We've Been DevOps":**
*   **General:** We've made progress in adopting DevOps principles but acknowledge we are not "100% DevOps," primarily due to inexperience and the learning curve with new tools and processes.
*   **Continuous Improvement:** A core focus. We iterated on repository structure and documentation as the project grew in complexity to improve clarity.
*   **Documentation:** Essential for backtracking and understanding. However, a challenge was keeping documentation consistently updated as the codebase evolved, leading to occasional discrepancies.
*   **WIP & Batch Size:** Reducing WIP and aiming for smaller commits/PRs made reviews easier and context clearer. This was a habit that needed cultivation.
*   **Fast Feedback (Inspired by Eficode):** Implemented tools and processes (e.g., CI, deploy previews, bot reviews) to get quicker insights into code quality and deployment readiness.
*   **Gaps & Areas for Improvement:**
    *   **Silo Identification & Management:** Better identification and management of knowledge or technical silos. Using specialized branches (e.g., for `whoknows_variations`) more effectively might have reduced technical complexity earlier, allowing more focus on DevOps process refinement.     
    *   **Metrics Coverage:** *(User to reflect: What key DevOps metrics, e.g., DORA metrics like Deployment Frequency, Lead Time for Changes, Change Failure Rate, MTTR, are we not tracking? Why not? What would be the benefit of tracking them?)*

---

## 3. Software Quality

We have configured and utilized several tools to analyze and improve software quality: CodeRabbit (`.coderabbit.yml`), SonarCloud (`.sonar-project.properties`), and DeepSource (`.deepsource.toml`). A pre-commit hook (`.pre-commit-config.yaml`) is also used locally to run some of these checks.

*(The following subsections need to be filled based on the team's detailed reflection, addressing the four key questions from the assignment requirements.)*

### Our Agreement with Tool Findings
*   *(User to elaborate: Overall, did the team agree with the types of issues flagged? Were there categories of findings that were consistently accurate or consistently off-base/false positives? Any surprising or particularly insightful findings?)*
*   The existing `assignment.md` notes: "Does not take business logic in to context. The static tools can check for patterns, and lack of variables but sometimes the context is more important to understand such as 'Does it solve the need of the customer?'" - This is a good point for critical reflection.

### Issues We Fixed (and Why)
*   From existing `assignment.md` (DeepSource on Rust - needs more detail): "Implemented bots gave a smoother experience for integration and ensured verification for the PR so if the assigne was not sure of the implementation then the bot could give feedback of what has been implemented." (This sounds more like a benefit of bots in general, rather than a specific fix prompted by a quality tool).

### Issues We Ignored (and Why)
*   From existing `assignment.md`:
    *   SonarQube: "duplicates of the code in the analysis but we ignored it due to lack of experience in the new coding language." *(User to elaborate: What kind of duplicates? Was it a conscious decision that refactoring was too risky/time-consuming given inexperience?)*
    *   DeepSource (Docker): "apt install - Agree with the findings but did not fix it. The system works, and it throws no errors, if it throws then it will be an easy fix. We had our focus elsewhere." *(Good reflection on prioritization).*
    *   DeepSource (JavaScript): "Lack of documentation", "Bug risk" *(User to elaborate: Were these ignored? If so, why? Or were they fixed?)*.
    *   CodeClimate: "Does not support Rust." (Valid reason for not using it for Rust code).
*   From `suggestion.assignment.md` subjective audit: "ignored: 3 "duplicate code" flags in actix handlers (intentional inline optimization)" - *This is a good example of a reasoned ignore.*

### Integration into CI/CD
*   *(User to describe how these tools are integrated into the CI/CD pipeline beyond local pre-commit hooks. Do they run in GitHub Actions? Do they provide reports or alerts on PRs or merges? Do they affect the build/deployment if quality metrics drop?)*

---

## 4. Monitoring Realization

This section describes a specific instance where our monitoring setup provided a key realization, leading to a system improvement.

*   **Our Monitoring Setup (Summary):**
    *   **Exporter:** `prometheus_exporter` crate on a `/metrics` endpoint (from `suggestion.assignment.md`).
    *   **Visualization:** Grafana 10. Dashboards show metrics like RPS at `/` endpoint, CPU/memory, p95 latency.
        *  dashboard metrics: 
           *  Total Queries at `/` endpoint
    *   **Alerting:** Postman daily and weekly monitoring sends mails daily and weekly to the team.
    *   **Logging:** 

*   **The Realization & Fix:**
    *   *(User to narrate the "grand realization" story here, covering:*
        *   *What specific metric/system aspect were you monitoring that led to the insight?*
        *   *What was the unexpected or important insight/realization?*
        *   *What action/fix did you implement as a result?*
        *   *What was the observable improvement or outcome, as confirmed by monitoring?)*
    *   *Example placeholder: "We were monitoring [Metric X] for [System Y]. We noticed [Observation Z], which was unexpected because [Reason]. This led us to investigate [Area A], where we discovered [Problem B]. We implemented [Fix C] by [Action D]. After the fix, monitoring showed that [Metric X] improved by [Amount E], confirming the positive impact."*

---

## 5. Next Steps (Optional, but good for reflection)

*   *(User to list potential next steps for improving their DevOps practices, tooling, or system based on their reflections. Examples from `suggestion.assignment.md` include: "extend dashboards (per endpoint, db, cache)", "finish log pipeline (vector → loki) + search panel", "chaos drill before final release").*

---
*This document is a living reflection and will be updated as new insights emerge.*
