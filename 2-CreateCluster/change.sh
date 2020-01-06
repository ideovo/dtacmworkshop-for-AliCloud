#!/bin/bash
config=`cat ./PVname`
ordertempl=`cat ~/dtacmworkshop/6-SockshopTemp/orders-db-template.yml`
userdevtempl=`cat ~/dtacmworkshop/6-SockshopTemp/user-db-dev-template.yml`
userprotempl=`cat ~/dtacmworkshop/6-SockshopTemp/user-db-pro-template.yml`
carttempl=`cat ~/dtacmworkshop/6-SockshopTemp/carts-db-template.yml`
printf "$config\ncat << EOF\n$ordertempl\nEOF" | bash > ../manifests/backend-services/orders-db/orders-db.yml
printf "$config\ncat << EOF\n$userdevtempl\nEOF" | bash > ../manifests/backend-services/user-db/dev/user-db-dev.yml
printf "$config\ncat << EOF\n$userprotempl\nEOF" | bash > ../manifests/backend-services/user-db/production/user-db-pro.yml
printf "$config\ncat << EOF\n$carttempl\nEOF" | bash > ../manifests/backend-services/carts-db/carts-db.yml