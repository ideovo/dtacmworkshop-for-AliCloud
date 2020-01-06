#!/bin/sh

export REGION=$(cat ../1-Credentials/creds.json | jq -r '.aliyunRegionId')

#disk-1
aliyun ecs CreateDisk \
         --RegionId ${REGION} \
         --ZoneId ${REGION}-a \
         --Size 20 \
         --DiskCategory cloud_ssd \
         > disk1.txt

DISKID1="$(grep -oP '(?<="DiskId": ")[^"]*' disk1.txt)"
echo DISKID1=${DISKID1} > PVname

sleep 10

#disk-2
aliyun ecs CreateDisk \
         --RegionId ${REGION} \
         --ZoneId ${REGION}-a \
         --Size 20 \
         --DiskCategory cloud_ssd \
         > disk2.txt

DISKID2="$(grep -oP '(?<="DiskId": ")[^"]*' disk2.txt)"
echo DISKID2=${DISKID2} >> PVname

sleep 10

#disk-3
aliyun ecs CreateDisk \
         --RegionId ${REGION} \
         --ZoneId ${REGION}-a \
         --Size 20 \
         --DiskCategory cloud_ssd \
         > disk3.txt

DISKID3="$(grep -oP '(?<="DiskId": ")[^"]*' disk3.txt)"
echo DISKID3=${DISKID3} >> PVname

sleep 10

#disk-4
aliyun ecs CreateDisk \
         --RegionId ${REGION} \
         --ZoneId ${REGION}-a \
         --Size 20 \
         --DiskCategory cloud_ssd \
         > disk4.txt

DISKID4="$(grep -oP '(?<="DiskId": ")[^"]*' disk4.txt)"
echo DISKID4=${DISKID4} >> PVname

sleep 10

#disk-5
aliyun ecs CreateDisk \
         --RegionId ${REGION} \
         --ZoneId ${REGION}-a \
         --Size 20 \
         --DiskCategory cloud_ssd \
         > disk5.txt

DISKID5="$(grep -oP '(?<="DiskId": ")[^"]*' disk5.txt)"
echo DISKID5=${DISKID5} >> PVname

sleep 10

#disk-6
aliyun ecs CreateDisk \
         --RegionId ${REGION} \
         --ZoneId ${REGION}-a \
         --Size 20 \
         --DiskCategory cloud_ssd \
         > disk6.txt

DISKID6="$(grep -oP '(?<="DiskId": ")[^"]*' disk6.txt)"
echo DISKID6=${DISKID6} >> PVname