#!/bin/bash
# Call it like so:
# $(AWS_PROFILE=github ./assume-role.sh)
# Unset the exported env vars like so:
# unset AWS_ACCESS_KEY_ID; unset AWS_SECRET_ACCESS_KEY; unset AWS_SESSION_TOKEN

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
STACK_PREFIX=$(cat ${DIR}/../conf.json|jq -r .stack_prefix)
ROLE_NAME=${STACK_PREFIX}-deployer

ACCOUNT_ID=$(aws sts get-caller-identity|jq -r .Account)
TEMP_ROLE=$(aws sts assume-role --role-arn arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME} --role-session-name cli)

echo export AWS_ACCESS_KEY_ID=$(echo $TEMP_ROLE | jq -r .Credentials.AccessKeyId)
echo export AWS_SECRET_ACCESS_KEY=$(echo $TEMP_ROLE | jq -r .Credentials.SecretAccessKey)
echo export AWS_SESSION_TOKEN=$(echo $TEMP_ROLE | jq -r .Credentials.SessionToken)
