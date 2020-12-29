# logging-php-docker-cloudwatch

A Docker container that runs PHP-FPM, NGINX and demonstrates logging in JSON format 
to stdout in an AWS ECS environment.

And for fun and out of curiosity the docker container can be build and deployed to AWS ECS using GitHub Actions 🚀.

## Prerequisites

- Building the container on your machine requires `docker` and `docker-compose` (https://docs.docker.com/get-docker/ and https://docs.docker.com/compose/install/).
- Deploying the container to AWS ECS requires an AWS account. [You can create an AWS account here](https://portal.aws.amazon.com/billing/signup#/start).

## Getting started

In the further course it is assumed you want to have it all and would like GitHub Actions to deploy the container in your own AWS account. 

### Fork and Checkout
Simply said, fork this repo and clone your fork to your machine.

### Create an IAM user 

There is a small stack `cloudformation/deployer.yml` that will create an IAM user for use by GitHub Actions.
```bash
aws cloudformation create-stack --stack-name log-docker-deployer --template-body file://./cloudformation/deployer.yml --parameters ParameterKey=UserName,ParameterValue=github-actions --capabilities CAPABILITY_NAMED_IAM
```

### Create an Access Key for the user
```bash
aws iam create-access-key --user-name github-actions
```
The result of the command will output i.a. `AccessKeyId` and `SecretAccessKey`. Please note the values for later use with your GitHub Secrets.

### Add Github Secrets
Some secrets will be used by GitHub Actions. Either add them using the GitHub webpage (https://docs.github.com/en/free-pro-team@latest/actions/reference/encrypted-secrets) or use the GitHub CLI (https://cli.github.com/):
```bash
gh secret set AWS_REGION -r <this/repository-name> -b <aws region e.g. us-east-1>

gh secret set AWS_ROLE -r <this/repository-name> -b <name of the deployer role>

gh secret set AWS_ACCESS_KEY_ID -r <this/repository-name> -b <the AccessKeyId>

gh secret set AWS_SECRET_ACCESS_KEY -r <this/repository-name> -b <the SecretAccessKey>
```

### Run Workflow

The workflow `.github/workflows/deploy-aws-ecs.yml` builds the container and runs the deployment.