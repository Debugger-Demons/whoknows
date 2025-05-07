# Mandatory II

## Reflection

### Branch Strategy & security

Since the start of the project we used is Git Flow.
It was decided on that branch due to past experience, and the simplicity for release management.

The strategy has almost been followed so for every feature that has been built is a feature branch from the development branch, and will only be merged if another developer from the team approves the PR so we can ensure that the code has been read through and makes sense for the other developer.

It has ensured that unwanted code and bugs will not reach the development branch accidently, and therefore made the team more courageus when working across teams with these safety measures.

### Documentation and knowledge sharing

In the beginning of the projecct documentation and knowledge sharing was essential when we worked however as we advanced throughout the semester documentation fell behind which made knowledge sharing only verbal. That lead to issues in the project because as we advanced it became more problematic for the other members to follow with additional features as the project got more complex.

## How have we been DevOps

We have tried to follow the given devops principles during the lectures, the devops handbook and the guest lecture input from Eficode where Kasper and Sofus came with valuable input in regards to DevOps

### Principles in DevOps

- Several principles have been followed but not to the fullest and we have not been DevOps 100% due to inexperience in the group.

- Tried to follow the principles by contionus improvement and realisting documentation was important for us. We have several md files that contains information about our stack and how it is built. That approach has made it easy to backtrack if the project became too complex to understand so we could always track back and read what we have written.

- Issues arise when we have changed the structure of the code and forgot to update the documentation, which can be a issue when we have cross referenced the .md files.

- As the project grew transparency and knowledge sharing became more important so we changed the structure of the repository several times to make it easier to read and understand it. Knowledge became easier when additional documents where added, and spoke more of the structure.

- Followed the principle to reduce WIP and avoid large commits and pushes. It became easier to review, and approve PR because you could easily understand the architecture and context of it if the whole batch is in the same context, and does not strecth out to different branches and code context.

- It has been a good approach the secure the branches which has made it easy not to be nervous to push when you are done with a branch.

### Inspiration from Eficode

- Focused on fast feedback since it was a keyfactor from Eficode which is the reason for implementation of tools to get a quick overview of potential risks in the code.

- Wrote documentation so team could work independently without being dependent on another person. We avoided silo issues that way.

---

NOTER

- Continuous improvement and learning!
- Transparency, visibility, and knowledge sharing!
  Break down information and knowledge silos.
- Reduce WIP (Work In Progress) Avoid large batch sizes
- DevSecOps - Secure By design, not as an afterthought

---

## Software Quality

---

NOTES

After you have setup a these code quality tools and gone through the issues, your group should create a brief document that answers the following questions:

- Do you agree with the findings?

- Which ones did you fix?

- Which ones did you ignore?

- Why?

---

### Issue with these tools

- Does not take business logic in to context. The static tools can check for patterns, and lack of variables but sometimes the context is more important to understand such as "Does it solve the need of the customer?"

### Impact of technology value stream

- Technology value stream became important in software quality as we progressed

- Implemented several technologies to ensure a smooth and even flow for the developers in the project for every new implementation in the project.

- Better experience for further development of the project.

- Implemented bots gave a smoother experience for integration and ensured verification for the PR so if the assigne was not sure of the implementation then the bot could give feedback of what has been implemented.

### Implementation of SonarCube

- There are duplicates of the code in the analysis but we ignored it due to lack of experience in the new coding language

### Implementation of DeepSource

#### Docker

- apt install
  - Agree with the findings but did not fix it. The system works, and it throws no errors, if it throws then it will be an easy fix. We had our focus elsewhere

#### JavaScript

- Lack of documentation
- Bug risk

#### Rust

### Implementation of CodeClime

- Does not support Rust

---

CALMS

---

## Monitoring Quality

### Prometheus

- Great for finding numeric values and time stamp but cannot be used for searching arbituary text

### Grafana
