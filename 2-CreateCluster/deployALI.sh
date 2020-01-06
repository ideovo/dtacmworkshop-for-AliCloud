#!/bin/sh

export REGION=$(cat ../1-Credentials/creds.json | jq -r '.aliyunRegionId')

#create VPC
echo "Creating VPC ..."
aliyun vpc CreateVpc \
    --VpcName ACM \
    --Description "ACM Workshop" \
    --RegionId ${REGION} \
    --ZoneId ${REGION}-a \
    --CidrBlock 10.0.0.0/8 \
    > aliyun1.txt

sleep 15

VPC="$(grep -oP '(?<="VpcId": ")[^"]*' aliyun1.txt)"

#create VSwitch
echo "Creating VSwitch ..."
aliyun vpc CreateVSwitch \
    --VSwitchName ACM \
    --VpcId ${VPC} \
    --RegionId ${REGION} \
    --ZoneId ${REGION}-a \
    --Description "ACM Workshop" \
    --CidrBlock 10.0.0.0/24 \
    > aliyun2.txt

sleep 15

VSWITCH="$(grep -oP '(?<="VSwitchId": ")[^"]*' aliyun2.txt)"

#create publickey
echo "Creating public key ..."

if [ -f ~/.ssh/id_rsa.pub ]; then
   echo "Info: KeyPair already exists"
else
   ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa -q
fi

#import Key
echo "ImportKeyPair ..."
aliyun ecs ImportKeyPair \
    --KeyPairName ACM \
    --RegionId ${REGION} \
    --PublicKeyBody "$(cat ~/.ssh/id_rsa.pub)"


#create cluster configure
cat > cluster.json << EOF
{
  "name": "ACM-workshop",
  "cluster_type": "ManagedKubernetes",
  "disable_rollback": true,
  "timeout_mins": 60,
  "region_id": "${REGION}",
  "zoneid": "${REGION}-a",
  "snat_entry": true,
  "cloud_monitor_flags": false,
  "public_slb": true,
  "worker_instance_type": "ecs.g6.xlarge",
  "num_of_nodes": 3,
  "worker_system_disk_category": "cloud_efficiency",
  "worker_system_disk_size": 100,
  "worker_instance_charge_type": "PostPaid",
  "vpcid": "${VPC}",
  "vswitchid": "${VSWITCH}",
  "container_cidr": "172.20.0.0/16",
  "service_cidr": "172.21.0.0/20",
  "key_pair": "ACM"
  }
EOF

#create ACK
echo "Creating ACK ..."
aliyun cs  POST /clusters \
    --header "Content-Type=application/json" \
    --body "$(cat cluster.json)" \
    > aliyun3.txt

sleep 120

CLUSTER="$(grep -oP '(?<="instanceId": ")[^"]*' aliyun3.txt)"

#get Cluster config infomation
#aliyun cs GET /k8s/${CLUSTER}/user_config | jq -r .config > ~/.kube/config-alibaba
#export KUBECONFIG=$KUBECONFIG:~/.kube/config-alibaba