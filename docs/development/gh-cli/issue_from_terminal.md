
# basic create issue from terminal using gh cli

pre-requisite: 
- gh auth logged in
- github token access to the repo and issue creation

## CLI command to create an issue

for mac/linux:

```bash
gh issue create \
  --title "Implement Docker Container for WhoKnows Rust_Actix/Backend" \
  --body-file ..\docs\operations\issues_docs\docker_implementation_issue.md \
  --project "whoknows KANBAN board"
```

for Windows (single line):
```PowerShell
gh issue create --title "Implement Docker Container for WhoKnows Rust_Actix/Backend" --body-file ..\docs\operations\issues_docs\docker_implementation_issue.md --project "whoknows KANBAN board"
```

### breakdown of the command

- `gh issue create` : command to create an issue
- `--title` : title of the issue
- `--body-file` : path to the file containing the issue description
- `--project` : project board where the issue will be added


### note

directory for issue body docs:

- path: 

```bash

..\docs\operations\issues_docs\<issue_name>.md

```
