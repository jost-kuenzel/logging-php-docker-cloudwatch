#!/bin/bash

set -e 

[ -z "${AWS_PROFILE}" ] && echo -e "Please set an AWS_PROFILE like so:\n  AWS_PROFILE=my-profile ${0}" && exit 1
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

IAM_USER_NAME=$(cat ${DIR}/../conf.json|jq -r .iam_user_name)
AWS_REGION=$(cat ${DIR}/../conf.json|jq -r .aws_region)
STACK_PREFIX=$(cat ${DIR}/../conf.json|jq -r .stack_prefix)

echo "Checking for deployer stack now"
set +e
DEPLOYER_STACK_DESCRIBE=$(sh $DIR/stack-deployer.sh describe)
[ ${?} -ne 0 ] && echo "Please run 'sh stack-deployer.sh create' first." && exit 1
set -e 

DEPLOYER_STACK_STATUS=$(echo $DEPLOYER_STACK_DESCRIBE | jq -r .StackStatus)
[ "${DEPLOYER_STACK_STATUS}" != "CREATE_COMPLETE" ] && [ "${DEPLOYER_STACK_STATUS}" != "UPDATE_COMPLETE" ] && echo "Please wait until deployer stack is finished and try again." && exit 1

echo "Creating access token for ${IAM_USER_NAME}"
TEMP_ACCESS_KEY=$(aws iam create-access-key --user-name ${IAM_USER_NAME})

echo "Configure AWS profile"
AWS_ACCESS_KEY_ID=$(echo $TEMP_ACCESS_KEY | jq -r .AccessKey.AccessKeyId)
AWS_SECRET_ACCESS_KEY=$(echo $TEMP_ACCESS_KEY | jq -r .AccessKey.SecretAccessKey)
aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID} --profile ${IAM_USER_NAME}
aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY} --profile ${IAM_USER_NAME}
aws configure set region ${AWS_REGION} --profile ${IAM_USER_NAME}

echo "Set GH Secrets"
gh secret set STACK_PREFIX -b ${STACK_PREFIX}
gh secret set AWS_REGION -b ${AWS_REGION}
gh secret set AWS_ROLE -b ${STACK_PREFIX}-deployer
gh secret set AWS_ACCESS_KEY_ID -b ${AWS_ACCESS_KEY_ID}
gh secret set AWS_SECRET_ACCESS_KEY -b ${AWS_SECRET_ACCESS_KEY}

echo "Done"