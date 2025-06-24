# DevOpsNotes

| DevSecOps Princip  | Hvordan vores GitHub Actions workflow passer ind|
| ------------- | ------------- |
| **Security as Code**  | Workflowen tjekker automatisk om secrets og SSH-nøgler er til stede og i korrekt format – uden manuel indgriben.  |
| **Shared responsibility**  | Sikkerhedsvalidering er en del af CI/CD-pipelinen, ikke kun sikkerhedsteamets ansvar. Alle der arbejder med deploys er involveret.  |
| **Shift Left Security**  | Workflowen kører ved PR eller ved workflow dispatch, det vil sige før der sker en deployment. Det er tidligt i processen.  |
| **Automation First**  | Hele processen foregår automatisk ved PRs eller kald fra andre workflows.  |
| **Security Gate in CI/CD**  | Secrets valideres før næste trin må køres. Hvis noget mangler, afbrydes deploymenten med fejl.  |
| **Continuous Validation** | Secrets og SSH-nøgler bliver valideret ved hver PR og workflow-kald, så sikkerhed sikres løbende og ikke kun en gang. |





**Security as Code**

*Sikkerhed er skrevet som kode:*
```
- name: Ensure PROD_ENV_FILE is provided for production
  if: env.PROD_ENV_FILE_PRESENT == 'false'
  run: |
    echo "::error::Secret PROD_ENV_FILE is required..."
    exit 1
```


**Shared responsibility**

*Alle workflows aktiveres af udviklere via PRs:*

```
on:
  pull_request:
    branches: [development, main]
```

**Shift left security**

*Sikkerhedsvalidering sker tidligt – før merge, før deploy eller ved manuel test:*

```
on:
  pull_request:
  workflow_dispatch:
  workflow_call:

```

**Automation First**

*Alle valideringer kører automatisk som kode uden manuel indgriben i CI/CD-pipelinen.:*

```
jobs:
  validate-secrets:
    runs-on: ubuntu-latest
    steps:
      - name: Check secrets
        run: ./validate-secrets.sh


```

 **Continuous Validation**

 *Secrets og SSH-nøgler valideres hver gang der oprettes en PR, eller når workflowet kaldes af et andet – ikke kun ved release.*

 ```

jobs:
  validate-dev-secrets:
    if: inputs.environment == 'development'
    runs-on: ubuntu-latest


```

**Security Gate in CI/CD**

*Secrets valideres før næste trin må køres. Hvis noget mangler, afbrydes deploymenten med en fejl.*

```
- name: Test DEV SSH Key is provided for development
  if: inputs.environment == 'development' && env.DEV_SSH_KEY_PRESENT == 'false'
  run: |
    echo "::error::Secret DEV_SSH_PRIVATE_KEY is required for environment 'development' but was not provided."
    exit 1
```


**Lokal sikkerhed og konfiguration med Python**

*Vi bruger et Python-script til hurtigt at tjekke nødvendige miljøvariabler og køre Docker-containeren lokalt.
 Det sikrer, at .env-filer er på plads, og at porte og navne er korrekte, før build og run.*

 ```
if __name__ == "__main__":
   if not makefile_env_loader.check_env():
      print(" \n"
            "Error: Required environment file .env.local.frontend not found.\n"
            "-> copy and edit the template: \n"
            "  cp .env.local.frontend.template .env.local.frontend \n"
            " \n",
            file=sys.stderr)
      sys.exit(1)
      
   run_dev_docker()

```



**Sikkerhed og Static Application Security Testing (SAST)**

**SonarQube**

- Vi bruger SonarQube til statisk kodeanalyse og sikkerhedsscanning.

- SonarQube er integreret i vores CI/CD pipeline via GitHub Actions.

- Ved hver push til dev- eller test-branch eller ved pull requests kører der en SonarQube-scanning.

- Scanningen giver rapporter om kodekvalitet og potentielle sikkerhedssårbarheder, som skal rettes inden koden kan merges.

**DeepSource**

- Vi bruger DeepSource som et supplerende værktøj til statisk analyse og sikkerhedsscanning af vores kodebase.
  
- DeepSource er integreret direkte med GitHub og scanner automatisk ny kode ved hver commit og pull request.

- DeepSource fokuserer på hurtig feedback og kontinuerlig forbedring med automatiske forslag til kodeforbedringer.

- Understøtter flere sprog og teknologier, herunder Rust, YAML, Shell og Docker, som vi bruger i projektet.



