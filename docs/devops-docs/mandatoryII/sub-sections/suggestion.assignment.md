# mandatory ii – devops reflection

*(kea dat devops, spring 2025 – group debugger‑demons)*

> quick‑fire exam notes – terse, lowercase, logic‑tree.
> required headers: branch strategy & security · how have we been devops · software quality · monitoring realization.

---

## 0. meta

* repo: `github.com/debugger-demons/whoknows`
* ci/cd rail: github actions → gh‑cr container → google compute engine vm (ubuntu 22.04)
* runtime: docker compose on vm · prometheus + grafana sidecars
* cli helpers: gh cli · make · cargo

---

## 1. branch strategy & security

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

---

## 2. how have we been devops – *calms*

| lens            | evidence                                                                                                                          |
| --------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| **culture**     | pr reviews, tried to implement tuesday and thursday meetings, (tried to implement) blameless retro                                                  |
| **automation**  | make targets (`make fmt • test • pr`) wrap gh cli; 3‑stage gha pipelines (branch → dev → prod); db migrations in pipeline         |
| **lean**        | wip≤5 per dev; feature toggles guard half‑done code; deploy preview cuts feedback loop from days→hours                            |
| **measurement** | prometheus counters & histograms; grafana dashboard (rps at `/` endpoint, cpu, p95 latency); ci trend badge (tests, clippy warns) |
| **sharing**     | `/docs/` md garden (architecture adr, runbooks); pair‑review rotation; post‑merge slack digest                                    |

---

## 3. software quality

* **static gates**: rustfmt (diff=error), clippy (deny warnings), deepsource 
* **SAST**: static  
* **dynamic gates**: `cargo test` (≈82 % line cov via tarpaulin) runs on every push
* **subjective audit**:

  * agreed with all correctness & security findings
  * fixed: unused mut, panic‑on‑unwrap, missing error handling
  * ignored: 3 “duplicate code” flags in actix handlers (intentional inline optimization)
* **why**: trade value > effort; kept false‑positive duplications; everything else patched same day

---

## 4. monitoring realization

* exporter: `prometheus_exporter` crate on `/metrics`
* grafana 10: dashboard currently shows **only rps @ '/'** + cpu/mem + latency; backlog ticket to chart per‑endpoint, db pool
* alerting: grafana alert → telegram if p95 >300 ms or 5xx/s >1 %
* logs: journald (todo→ vector → loki)

---

## 5. next steps

* extend dashboards (per endpoint, db, cache)
* finish log pipeline (vector → loki) + search panel
* chaos drill before final release
