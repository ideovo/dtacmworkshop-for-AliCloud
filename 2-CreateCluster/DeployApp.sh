#!/bin/sh

export API_TOKEN=$(cat ../1-Credentials/creds.json | jq -r '.dynatraceApiToken')
export PAAS_TOKEN=$(cat ../1-Credentials/creds.json | jq -r '.dynatracePaaSToken')
export TENANTID=$(cat ../1-Credentials/creds.json | jq -r '.dynatraceTenantID')
export ENVIRONMENTID=$(cat ../1-Credentials/creds.json | jq -r '.dynatraceEnvironmentID')
export CLUSTER="$(grep -oP '(?<="instanceId": ")[^"]*' aliyun3.txt)"

use-k8s-cluster ${CLUSTER}

echo "Deploying OneAgent Operator"

../utils/deploy-dt-operator.sh

echo "Waiting for OneAgent to startup..."
sleep 120

echo "Deploying SockShop Application"

./createDisk.sh

sleep 30

/bin/bash change.sh

sleep 30

../utils/deploy-sockshop.sh

sleep 120

echo "Start Production Load"
nohup ../utils/cartsLoadTest.sh &

echo "Deployment Complete"