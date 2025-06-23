# Presentation

## Local presentation

- Run make script

  We do this to illustrate how we test our application locally before we send it further for workflow test

      - make stop-compose
        - docker ps -a
            To ensure the containers are stopped
      - make run-compose
        - docker ps -a
            To ensure the containers are running

  After the images has been put in a container we show our result for local changes

  We can add small changes such as changing the CSS in the background of the applicaiton

## Branch test workflow

The purpose is to ensure the feature branches can pass the workflow as the final test when the feature has been declared done.

Must be done using github CLI to show our template in the terminal.

- Add the feature branch name in cd.branch-test.yml file
- Push your changes to github, to activate the workflow
- Once the workflow has passed, it means the feature branch is done

## Dev branch

The purpose of the dev branch is to ensure all the new features can be merged together, and add its functionalities.

- After branch-test.yml make a merge pr to dev branch where you have added a small change
- Merge the changes to the dev branch
