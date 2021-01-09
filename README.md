# logging-php-docker-cloudwatch

A Docker image that runs PHP-FPM, NGINX and demonstrates logging in JSON format 
to stdout in an AWS ECS environment.

And for fun and out of curiosity the docker container can be build and deployed to AWS ECS using GitHub Actions 🚀.

## _Work in Progress_


## Prerequisites

- Building the container on your machine requires `docker` and `docker-compose` (https://docs.docker.com/get-docker/ and https://docs.docker.com/compose/install/).
- `jq` is used extensively in shell scripts.
- Deploying the container to AWS ECS requires an AWS account. [You can create an AWS account here](https://portal.aws.amazon.com/billing/signup#/start).

## Getting started

In the further course it is assumed you want to have it all and would like GitHub Actions to deploy the container in your own AWS account. 

### Fork and Checkout
Simply said, fork this repo and clone your fork to your machine.

### Add config.json ###

```bash
cp config.dist.json config.json
```

Open config.json and adjust settings:


| Field | Meaning |
|-------|---------|
| `aws_region` | AWS region where you would like to deploy infrastructure |
| `iam_user_name` | Name of the IAM user that is created for GitHub Actions to use e.g. 'gh-actions' |
| `stack_prefix` | A prefix to for all stacks that will be created e.g. 'log-docker'. It is also used to name creates resources. To avoid name length limitations of some AWS services it should not be longer than 12 characters. |

### Create the deployer

The following will create an IAM user and role for  GitHub Actions to use when deploying to AWS:
```bash
./scripts/stack-deployer.sh create
```
*Note: you might preprend above line with `AWS_PROFILE=<your-profile> ` to use a certain AWS profile.*

### Install AWS credentials and GitHub secrets
Once the deployer stack is created run the following to create AWS credentials for that user and save some as GitHub secrets to your fork:
```bash
./scripts/get-started.sh
```
*Note: you might preprend above line with `AWS_PROFILE=<your-profile> ` to use a certain AWS profile.*
### Run Workflow
Activate GitHub Actions in your fork.
The workflow "Deploy to AWS ECS" defined in `.github/workflows/deploy-aws-ecs.yml` is visible in the Actions tab. Start it, and it will build the image an cloudformation stacks..

## Deploy stacks manually ##
The folder `scripts` contains helper scripts to create, update, delete, describe cloudformation stacks.
### Assume deployer role ###
```bash
$(AWS_PROFILE=gh-actions ./scripts/assume-deployer.sh)
```
Replace 'github' with the user name you defined in `config.json`. The 'deployer' stack must have alredy been 
created (see "Create the deployer").

The command above sets `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN` env variables. You can unset them again like so:
```bash
unset AWS_ACCESS_KEY_ID; unset AWS_SECRET_ACCESS_KEY; unset AWS_SESSION_TOKEN
```
### Use stack scripts ###
```bash
./scripts/stack-(vpc|ecr|fargate).sh (create|update|delete|describe)
```
*Note: make sure you assumed the deployer role before.*

### Cleanup ###
The stacks depend on each other. Delete in the following sequence, but wait for each deletion to be completed.
```bash
./scripts/stack-fargate delete
./scripts/stack-ecr delete
./scripts/stack-vpc delete
./scripts/stack-deployer delete
```

## Simple demo of container
Simply use docker-compose to build and run the container:
```bash
docker-compose up
curl -v http://localhost
```
