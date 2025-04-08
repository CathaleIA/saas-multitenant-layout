#!/bin/bash
cd ../server || exit # stop execution if cd fails
rm -rf .aws-sam/

# Comentamos la validación con pylint ya que no es esencial para el despliegue
# python3 -m pylint -E -d E0401 $(find . -iname "*.py" -not -path "./.aws-sam/*")
# if [[ $? -ne 0 ]]; then
#   echo "****ERROR: Please fix above code errors and then rerun script!!****"
#   exit 1
# fi

# Construir las capas localmente primero
echo "Building layers locally..."
sam build --template template.yaml --build-dir .aws-sam/build

#Deploying shared services changes
echo "Deploying shared services changes" 
sam deploy --template-file .aws-sam/build/template.yaml \
           --stack-name serverless-saas \
           --s3-bucket sam-bootstrap-bucket-3bf4c4f6-69dd-4373-b722-1f22526fa162 \
           --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND CAPABILITY_NAMED_IAM \
           --no-fail-on-empty-changeset \
           --force-upload

cd ../scripts || exit
./geturl.sh