#!/bin/bash

export REGION=$(cat ../1-Credentials/creds.json | jq -r '.aliyunRegionId')

#disk-7
aliyun ecs CreateDisk \
         --RegionId ${REGION} \
         --ZoneId ${REGION}-a \
         --Size 20 \
         --DiskCategory cloud_ssd \
         > disk7.txt

DISKID7="$(grep -oP '(?<="DiskId": ")[^"]*' disk7.txt)"
echo DISKID7=${DISKID7} > JenkinsPV

sleep 10

#disk-8
aliyun ecs CreateDisk \
         --RegionId ${REGION} \
         --ZoneId ${REGION}-a \
         --Size 20 \
         --DiskCategory cloud_ssd \
         > disk8.txt

DISKID8="$(grep -oP '(?<="DiskId": ")[^"]*' disk8.txt)"
echo DISKID8=${DISKID8} >> JenkinsPV

sleep 10

#disk-9
aliyun ecs CreateDisk \
         --RegionId ${REGION} \
         --ZoneId ${REGION}-a \
         --Size 20 \
         --DiskCategory cloud_ssd \
         > disk9.txt

DISKID9="$(grep -oP '(?<="DiskId": ")[^"]*' disk9.txt)"
echo DISKID9=${DISKID9} >> JenkinsPV

sleep 10

config=`cat ./JenkinsPV`
Jenkinstempl=`cat ../manifests/jenkins/k8s-jenkins-pvcs-template.yaml`
printf "$config\ncat << EOF\n$Jenkinstempl\nEOF" | bash > ../manifests/jenkins/k8s-jenkins-pvcs.yaml

sleep 10

kubectl create -f ../manifests/jenkins/k8s-jenkins-ns.yaml
kubectl create -f ../manifests/jenkins/k8s-jenkins-pvcs.yaml
kubectl create -f ../manifests/jenkins/k8s-jenkins-deployment.yaml
kubectl create -f ../manifests/jenkins/k8s-jenkins-rbac.yaml
kubectl create -f ../manifests/jenkins/k8s-jenkins-secret.yaml

echo "Waiting for Jenkins to start..."

sleep 120

export JENKINS_URL=$(kubectl describe svc jenkins -n cicd | grep "LoadBalancer Ingress:" | sed 's~LoadBalancer Ingress:[ \t]*~~')
export JENKINS_URL_PORT=24711
export JENKINS_USERNAME=$(kubectl get secret jenkins-secret -n cicd -o yaml | grep "username:" | sed 's~username:[ \t]*~~')
export JENKINS_USERNAME_DECODE=$(echo $JENKINS_USERNAME | base64 --decode)
export JENKINS_PASSWORD=$(kubectl get secret jenkins-secret -n cicd -o yaml | grep "password:" | sed 's~password:[ \t]*~~')
export JENKINS_PASSWORD_DECODE=$(echo $JENKINS_PASSWORD | base64 --decode)
export K8S_MASTER=$(kubectl config view --minify | grep server | cut -f 2- -d ":" | tr -d " " | sed 's/https\?:\/\///')
export POD_IP=$(kubectl get pods -n cicd -o yaml | grep "podIP" | sed 's~podIP:[ /t]*~~' | sed -e 's/^[ \t]*//')
export JENKINS_POD=$(kubectl get po -n cicd --no-headers=true -o custom-columns=:metadata.name)

kubectl exec -it -n cicd $JENKINS_POD -- sed -i "s/JENKINS_SERVER_PLACEHOLDER/https:\/\/$K8S_MASTER/g" /var/jenkins_home/config.xml
kubectl exec -it -n cicd $JENKINS_POD -- sed -i "s/JENKINS_URL_PLACEHOLDER/http:\/\/$POD_IP:8080/g" /var/jenkins_home/config.xml

curl -s -XPOST http://$JENKINS_URL:$JENKINS_URL_PORT/createItem?name=DeploySockShop -u $JENKINS_USERNAME_DECODE:$JENKINS_PASSWORD_DECODE --data-binary @config.xml -H "Content-Type:text/xml"

#Restart Jenkins
curl -X POST http://$JENKINS_URL:$JENKINS_URL_PORT/restart -u $JENKINS_USERNAME_DECODE:$JENKINS_PASSWORD_DECODE

#Wait for Jenkins to restart
sleep 60

echo "----------------------------------------------------"
echo "Jenkins is running at : http://$JENKINS_URL:$JENKINS_URL_PORT"
echo "Username is :" $(echo $JENKINS_USERNAME | base64 --decode)
echo "Password is :" $(echo $JENKINS_PASSWORD | base64 --decode)
#echo "Kubernetes Master URL :" "https://"$K8S_MASTER""
#echo "Jenkins URL :" "http://"$POD_IP":8080"
echo "----------------------------------------------------"
