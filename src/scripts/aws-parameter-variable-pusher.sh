#!/bin/bash	

for i in ${PARAM_CIRCLECI_VARIABLE//,/ }
do
if [[ -z $(aws ssm describe-parameters --output text --parameter-filters "Key=Name,Values=/${CIRCLE_PROJECT_REPONAME}/${PARAM_AWS_ENVIROMENT}/${i}") ]]; then
  echo "AWS parameter not found"
  if [[ ${PARAM_STRING_TYPE} == "SecureString" ]]; then

    aws ssm put-parameter --type "${PARAM_STRING_TYPE}" --name "/${CIRCLE_PROJECT_REPONAME}/${PARAM_AWS_ENVIROMENT}/${i}" --value $"${!i}" --key-id "${PARAM_AWS_KMS_KEY}"

  else

    aws ssm put-parameter --type "${PARAM_STRING_TYPE}" --name "/${CIRCLE_PROJECT_REPONAME}/${PARAM_AWS_ENVIROMENT}/${i}" --value $"${!i}"

  fi
  
  aws ssm add-tags-to-resource --resource-type "Parameter" --resource-id "/${CIRCLE_PROJECT_REPONAME}/${PARAM_AWS_ENVIROMENT}/${i}" --tags Key=Enviroment,Value="${AWS_ACCOUNT_NAME}"
  aws ssm add-tags-to-resource --resource-type "Parameter" --resource-id "/${CIRCLE_PROJECT_REPONAME}/${PARAM_AWS_ENVIROMENT}/${i}" --tags Key=Owner,Value="${CIRCLE_PROJECT_USERNAME}"
  aws ssm add-tags-to-resource --resource-type "Parameter" --resource-id "/${CIRCLE_PROJECT_REPONAME}/${PARAM_AWS_ENVIROMENT}/${i}" --tags Key=GitRepository,Value="${CIRCLE_PROJECT_REPONAME}"
  aws ssm add-tags-to-resource --resource-type "Parameter" --resource-id "/${CIRCLE_PROJECT_REPONAME}/${PARAM_AWS_ENVIROMENT}/${i}" --tags Key=DeploymentTool,Value="CircleCI"

  continue
fi
done



for i in ${PARAM_CIRCLECI_VARIABLE//,/ }
do
if [[ "$(aws ssm get-parameter --with-decryption --name "/${CIRCLE_PROJECT_REPONAME}/${PARAM_AWS_ENVIROMENT}/${i}" | jq --raw-output .Parameter.Type)" != "${PARAM_STRING_TYPE}" ]]; then

  echo "Parameter store StringType (String or SecureString) is different on AWS compared with what you want to do, please manually delete the partameter store variable, or use the same StringType"
  echo "ABORTING!!"

  exit 1
fi
done


for i in ${PARAM_CIRCLECI_VARIABLE//,/ }
do
if [[ "$(aws ssm get-parameter --with-decryption --name "/${CIRCLE_PROJECT_REPONAME}/${PARAM_AWS_ENVIROMENT}/${i}" | jq --raw-output .Parameter.Value)" == $"${!i}" ]]; then
  echo "Variable is still the same on AWS"
  continue
else
  echo "Variable changed, updating on AWS"

  if [[ ${PARAM_STRING_TYPE} == "SecureString" ]]; then

    aws ssm put-parameter --overwrite --type "${PARAM_STRING_TYPE}" --name "/${CIRCLE_PROJECT_REPONAME}/${PARAM_AWS_ENVIROMENT}/${i}" --value $"${!i}" --key-id "${PARAM_AWS_KMS_KEY}"

  else

    aws ssm put-parameter --overwrite --type "${PARAM_STRING_TYPE}" --name "/${CIRCLE_PROJECT_REPONAME}/${PARAM_AWS_ENVIROMENT}/${i}" --value $"${!i}"

  fi
  
  aws ssm add-tags-to-resource --resource-type "Parameter" --resource-id "/${CIRCLE_PROJECT_REPONAME}/${PARAM_AWS_ENVIROMENT}/${i}" --tags Key=Enviroment,Value="${AWS_ACCOUNT_NAME}"
  aws ssm add-tags-to-resource --resource-type "Parameter" --resource-id "/${CIRCLE_PROJECT_REPONAME}/${PARAM_AWS_ENVIROMENT}/${i}" --tags Key=Owner,Value="${CIRCLE_PROJECT_USERNAME}"
  aws ssm add-tags-to-resource --resource-type "Parameter" --resource-id "/${CIRCLE_PROJECT_REPONAME}/${PARAM_AWS_ENVIROMENT}/${i}" --tags Key=GitRepository,Value="${CIRCLE_PROJECT_REPONAME}"
  aws ssm add-tags-to-resource --resource-type "Parameter" --resource-id "/${CIRCLE_PROJECT_REPONAME}/${PARAM_AWS_ENVIROMENT}/${i}" --tags Key=DeploymentTool,Value="CircleCI"

fi
done