# Monitoring tools

This page contains the tools we are using for monitoring our appliciation,
and how we are using them.

## Postman

We are using postman as our API platform to check our whether our endpoints works as intended,
and also their health status.

### Collection

We are using a collection folder that contains our HTTP requests for our application. We test if the endpoints are alive when we create them.

#### Test

We have created several tests for our endpoints. So far we have 2 different tests for each endpoint

- Status code

We created test for each endpoint to ensure they respond with a specific http status code to ensure if they work as intended.

- Response time

We created tests for each endpoint to ensure that the response time is below a certain threshold. The test checks whether or not the the response time is less than 200ms so we can be sure that our application response quickly when a user interacts with it.

### Health Monitor

In collection we have to manually test our endpoints but that can be a hassle in the long run.
Therefore we have implemented a health monitor that can check our endpoints, and give a periodic report to see if our server is alive, and the endpoints are still operational.
