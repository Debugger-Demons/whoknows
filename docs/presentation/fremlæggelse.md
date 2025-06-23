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

  After the images has been put in a container we show our result for local changes, so it has not affected the production

  We can add small changes such as changing the CSS in the background of the application

## Branch test workflow

The purpose is to ensure the feature branches can pass the workflow as the final test when the feature has been declared done.

- Add the feature branch name in cd.branch-test.yml file
- Push your changes to github, to activate the workflow
- Once the workflow has passed, it means the feature branch is done

## Pull request

Must be done using github CLI to show our template in the terminal.

- Make small changes (frontend)
- Write gh pr create -a (github username)
- Choose the correct repository
- Give it a title (You decide)
- Choose a template (Choose ours)
- Body means where you want to fill out your template. Press e to open notepad

## Dev branch

The purpose of the dev branch is to ensure all the new features can be merged together, and add its functionalities.

- After branch-test.yml make a merge pr to dev branch where you have added a small change
- Merge the changes to the dev branch

## DeepSource præsentation

The purpose is to demonstrate, and make DeepSource changes to our code.

- Make changes in the frontend, where you change the color for example to something false.
- Make a pr where you show changes in deepsource
