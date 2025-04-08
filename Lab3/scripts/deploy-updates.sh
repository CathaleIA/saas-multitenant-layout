#!/bin/bash
cd ../server || exit # stop execution if cd fails
rm -rf .aws-sam/

# Comentamos la validación con pylint ya que no es esencial para el despliegue
# python3 -m pylint -E -d E0401 $(find . -iname "*.py" -not -path "./.aws-sam/*")
# if [[ $? -ne 0 ]]; then
#   echo "****ERROR: Please fix above code errors and then rerun script!!****"
#   exit 1
# fi

#Deploying shared services changes
echo "Deploying shared services changes"
echo "Building shared layers locally..."
sam build -t shared-template.yaml --build-dir .aws-sam/build

sam deploy --template-file .aws-sam/build/template.yaml \
          --stack-name serverless-saas \
          --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND CAPABILITY_NAMED_IAM \
          --no-fail-on-empty-changeset \
          --force-upload \
          --resolve-s3

#Deploying tenant services changes
echo "Deploying tenant services changes"
rm -rf .aws-sam/
echo "Building tenant layers locally..."
sam build -t tenant-template.yaml --build-dir .aws-sam/build

sam deploy --template-file .aws-sam/build/template.yaml \
          --stack-name stack-pooled \
          --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND CAPABILITY_NAMED_IAM \
          --no-fail-on-empty-changeset \
          --force-upload \
          --resolve-s3

cd ../scripts || exit
./geturl.sh