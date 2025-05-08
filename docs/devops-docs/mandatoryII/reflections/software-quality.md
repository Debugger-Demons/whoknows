# Software Quality - Key Requirements & Prompts

- Core Task: Set up code quality analysis tools (like SonarCloud, Code Climate, DeepSource) for your project(s).
- Process:
    - Analyze the code with these tools to get a maintainability index, technical debt estimation, and identified potential problems.
    - Discuss the findings as a group.
    - Fix prominent issues that the group agrees on.
    - Integrate these tools into your CI pipeline to maintain high quality metrics for new code.

- Reflection (Critical Thinking): The learning goal is to think critically about these tools, not just accept their output as absolute truth.
- Documentation Requirements (for Mandatory II): Create a brief document that answers the following questions:
    - Do you (the group) agree with the findings from the tools?
    - Which specific issues/findings did you fix?
    - Which specific issues/findings did you ignore?
    - Why did you choose to fix or ignore each of these? (This is key for showing critical reflection).
- Exam Context: Simply showcasing the tools as the source of truth during an exam is not the correct approach. The documented reflections are crucial.

---


# Reflections

- all the code quality tools have been setup and configured for the project.

- additionaly, we have 
  - code rabbit [code rabbit config](../../.coderabbit.yml) 
  - sonar cloud [sonar cloud config](../../.sonar-project.properties)
  - deepsource [deepsource config](../../.deepsource.toml)

- pre commit hook [pre commit hook config](../../.pre-commit-config.yaml)
   - this pre commit hook is configured to run the code quality tools and check the code quality metrics.


## Documentation for the code quality tools

