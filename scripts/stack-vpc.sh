#!/bin/bash

set -e

CMD=$1
[ "${CMD}" != "create" ] && \
[ "${CMD}" != "update" ] && \
[ "${CMD}" != "delete" ] && \
[ "${CMD}" != "describe" ] && \
echo "Argument must be one of 'create', 'update', 'delete', 'describe'" && \
exit 1

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export AWS_REGION=$(cat ${DIR}/../conf.json|jq -r .aws_region)
STACK_PREFIX=$(cat ${DIR}/../conf.json|jq -r .stack_prefix)
STACK=vpc

STACK_NAME="--stack-name ${STACK_PREFIX}-${STACK}"
TEMPLATE_BODY="--template-body file://./cloudformation/${STACK}.yml"
PARAMETERS="--parameters ParameterKey=AvailabilityZone1,ParameterValue=${AWS_REGION}a ParameterKey=AvailabilityZone2,ParameterValue=${AWS_REGION}b"
CAPABILITIES="--capabilities CAPABILITY_NAMED_IAM"

if [[ "${CMD}" = "delete" ]]; then
  aws cloudformation ${CMD}-stack \
  ${STACK_NAME}
elif [[ "${CMD}" = "describe" ]]; then
  aws cloudformation ${CMD}-stacks \
  ${STACK_NAME} \
  --query "Stacks[0].{StackId:StackId, StackStatus:StackStatus}"
else 
  aws cloudformation ${CMD}-stack \
  ${STACK_NAME} \
  ${TEMPLATE_BODY} \
  ${PARAMETERS} \
  ${CAPABILITIES}
fi