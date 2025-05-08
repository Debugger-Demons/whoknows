# Version Control Reflection - Key Requirements & Prompts:
- Core Expectation (for Exam): The group must have:
    - Selected a specific version control workflow and branching strategy.
    - All members should be able to discuss this strategy and its pros and cons.
- Documentation Content (based on "Choose a git branching strategy"): The document must answer these specific questions:
    - What & How:
        - What version control strategy (workflow and branching model) did your group choose?
        - How did you actually implement or enforce this strategy in your project? (e.g., branch protection rules, PR templates, team agreements).
    - Why This One?
        - Why did your group select this particular strategy?
        - Why did you decide against other common strategies (e.g., GitFlow, GitHub Flow, Trunk-Based Development, if not chosen)?
    - Pros & Cons Experienced:
        - What advantages did your group experience while using this strategy during the course?
        - What disadvantages or challenges did you encounter?
- Iterative Document: The document can be revised even after the initial deadline if new insights are gained throughout the course.
- Inspiration: While the choose_a_git_branching_strategy.md provides the core questions, the reflection should also incorporate learnings from "other Git / Github related assignments."


---
(notes form two files: ../assignment.md and ../suggestion.assignment.md)

## assignment.md

### Branch Strategy & security

Since the start of the project we used is Git Flow.
It was decided on that branch due to past experience, and the simplicity for release management.

The strategy has almost been followed so for every feature that has been built is a feature branch from the development branch, and will only be merged if another developer from the team approves the PR so we can ensure that the code has been read through and makes sense for the other developer.

It has ensured that unwanted code and bugs will not reach the development branch accidently, and therefore made the team more courageus when working across teams with these safety measures.



## suggestion.assignment.md

### Branch Strategy & security

* **default branch**: `development`

  * `cd‑dev.yml` → auto‑deploys dev stack on merge/push
* **release branch**: `main` (✱ protected)

  * release tag `v*` → `cd‑prod.yml` runs build · push · migrate · health‑check · slack notify
* **working branches**: `feature/*`, `hotfix/*`, `release/*` (short‑lived)
  merge via pr → requires ≥1 reviewer · bots (deepsource, coderabbit, copilot) annotate diffs
* **templates**: issue/pr markdown enforce description, checklist, linked kanban card
* **security gates**:

  * branch protection rules (linear history, no force‑push)
  * secrets‑scan in `.github\workflows\validate.env_and_secrets.yml`
  * dependabot weekly


## Reflection

### Branch Strategy & security

#### branch strategy:

**branches**
- main
- development
- feature
- hotfix
- release

**branch protection rules**
- linear history
- no force push
- no direct pushes to main

**PR templates**
ref: 
- issue templates:
  - [devops](../../../../.github/ISSUE_TEMPLATE/devops.yml)
  - [rust_devving](../../../../.github/ISSUE_TEMPLATE/rust_devving.yml)

- pull request template:
  - [pull_request_template](../../../../.github/PULL_REQUEST_TEMPLATE.md)

content of templates: 
- description
- checklist
- linked kanban card

**team agreements**
- pr reviews
- pr completion -> move to done
- pr creation -> create issue if not present in `in-progress`

**kanban board automation**
- issues connected to branches
- PRs connected to issues

**secrets scan**
- [validate.env_and_secrets.yml](../../../../.github/workflows/validate.env_and_secrets.yml)

**dependabot**
- weekly

**release management**
- release branches
- release tags
- release notes

**cd pipelines for branch testing**

- [cd.branch-test.yml](../../../../.github/workflows/cd.branch-test.yml)

**cd pipelines connected to development**
- [cd.dev.yml](../../../../.github/workflows/cd.dev.yml)

**for release to production (main branch)**
- [cd.prod.yml](../../../../.github/workflows/cd.prod.yml)



























#### how implemented:

- branch protection rules
- PR templates
- team agreements
- kanban board automation
   - issues connected to branches
   - PRs connected to issues
     - pr completion -> move to done
     - pr creation -> create issue if not present in `in-progress`
- 







