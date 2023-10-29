#!/bin/bash

RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [[ -z "$1" ]];
then

echo -e "\n${YELLOW}backuped servers list:${NC}"

mc ls minio/${MINIO_BACKET}

else

echo -e "\n${YELLOW}full backup list for $1:${NC}"

barman-cloud-backup-list --endpoint-url ${MINIO_ENDPOINT_URL} s3://${MINIO_BACKET} $1

fi
