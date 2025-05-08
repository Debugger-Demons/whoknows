# How are you DevOps?

## Key Requirements & Prompts

- Inspiration: The document should be inspired by the guest lecture on DevOps (presumably one the students attended).
- Content - Part 1 (Affirmative):
    - Write down arguments and evidence for why your group is DevOps.
    - This implies reflecting on your practices, tools, culture, and processes and how they align with DevOps principles.
- Content - Part 2 (Reflective/Gap Analysis):
    - Write down what keeps your group from being fully DevOps.
    - This requires identifying areas where your group's practices, tools, culture, or processes do not yet align with an ideal DevOps state.
    - Crucially, you need to reflect on why these gaps exist.

## Documentation



### *calms*

| lens            | evidence                                                                                                                          |
| --------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| **culture**     | pr reviews, tried to implement tuesday and thursday meetings, (tried to implement) blameless retro                                                  |
| **automation**  | make targets (`make fmt • test • pr`) wrap gh cli; 3‑stage gha pipelines (branch → dev → prod); db migrations in pipeline         |
| **lean**        | wip≤5 per dev; feature toggles guard half‑done code; deploy preview cuts feedback loop from days→hours                            |
| **measurement** | prometheus counters & histograms; grafana dashboard (rps at `/` endpoint, cpu, p95 latency); ci trend badge (tests, clippy warns) |
| **sharing**     | `/docs/` md garden (architecture adr, runbooks); pair‑review rotation; post‑merge slack digest                                    |

---

### notes 

We have tried to follow the given devops principles during the lectures, the devops handbook and the guest lecture input from Eficode where Kasper and Sofus came with valuable input in regards to DevOps

#### Principles in DevOps

- Several principles have been followed but not to the fullest and we have not been DevOps 100% due to inexperience in the group.

- Tried to follow the principles by contionus improvement and realisting documentation was important for us. We have several md files that contains information about our stack and how it is built. That approach has made it easy to backtrack if the project became too complex to understand so we could always track back and read what we have written.

- Issues arise when we have changed the structure of the code and forgot to update the documentation, which can be a issue when we have cross referenced the .md files.

- As the project grew transparency and knowledge sharing became more important so we changed the structure of the repository several times to make it easier to read and understand it. Knowledge became easier when additional documents where added, and spoke more of the structure.

- Followed the principle to reduce WIP and avoid large commits and pushes. It became easier to review, and approve PR because you could easily understand the architecture and context of it if the whole batch is in the same context, and does not strecth out to different branches and code context.

- It has been a good approach the secure the branches which has made it easy not to be nervous to push when you are done with a branch.

#### Inspiration from Eficode

- Focused on fast feedback since it was a keyfactor from Eficode which is the reason for implementation of tools to get a quick overview of potential risks in the code.

- Wrote documentation so team could work independently without being dependent on another person. We avoided silo issues that way.

---

#### NOTER

- Continuous improvement and learning!
- Transparency, visibility, and knowledge sharing!
  Break down information and knowledge silos.
- Reduce WIP (Work In Progress) Avoid large batch sizes
- DevSecOps - Secure By design, not as an afterthought

---

### 
