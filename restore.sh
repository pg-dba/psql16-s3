#!/bin/bash

RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [[ ! -z "$1" && ! -z "$2" ]];
then

mc du --recursive minio/${MINIO_BACKET}/${1}/base/${2}
RC=$?

if [[ ${RC} == 0 ]];
then

rm -rf /var/lib/postgresql/data/*
rm -rf /var/lib/postgresql/data/.barman-recover.info 
echo -e "\n${YELLOW}directory must be empty before restore${NC}"
ls -la /var/lib/postgresql/data/

echo -e "\n${RED}full backup $1 restoring...${NC}"
barman-cloud-restore --endpoint-url ${MINIO_ENDPOINT_URL} s3://${MINIO_BACKET} $1 $2 /var/lib/postgresql/data/

echo -e "\n${YELLOW}prepare for WAL restore:${NC}"

rm -f /var/lib/postgresql/data/recovery.done

echo -e "\n${YELLOW}disable archiving at time restoring WAL${NC}"
sed -i 's/DEBUG=1/DEBUG=0/' /var/lib/postgresql/data/archive_wal.sh 
sed -i 's/LOG=1/LOG=0/' /var/lib/postgresql/data/archive_wal.sh 
sed -i 's/ARCHIVE=1/ARCHIVE=0/' /var/lib/postgresql/data/archive_wal.sh 
cat /var/lib/postgresql/data/archive_wal.sh | grep -v -P '^\s*(#|;|$)' | grep "DEBUG=\|LOG=\|ARCHIVE="

echo -e "\n${YELLOW}command for restoring WAL${NC}"
echo "restore_command = 'barman-cloud-wal-restore --endpoint-url ${MINIO_ENDPOINT_URL} s3://${MINIO_BACKET} $1 %f %p'" > /var/lib/postgresql/data/recovery.conf
if [[ -z "$3" ]]; then
echo "recovery_target_timeline = 'latest'" >> /var/lib/postgresql/data/recovery.conf
else
echo "recovery_target_time = '$3'" >> /var/lib/postgresql/data/recovery.conf
echo "recovery_target_action = 'promote'" >> /var/lib/postgresql/data/recovery.conf

fi

chown 999:999 /var/lib/postgresql/data/recovery.conf
cat /var/lib/postgresql/data/recovery.conf
chown 999:999 /var/lib/postgresql/data/backup_label
# chown -R 999:999 /var/lib/postgresql/data/*
# find /var/lib/postgresql/data/* \( ! -user 999 -or ! -group 999 \) -exec echo {} \;
# find /var/lib/postgresql/data/* \( ! -user 999 -or ! -group 999 \) -exec chown 999:999 {} \;

echo -e "\n${YELLOW}completed:${NC}"
ls -la /var/lib/postgresql/data/

echo -e "\n${RED}You must start the container. And control:${NC}"
echo 'cat $(ls -tr /var/lib/postgresql/data/log/*.csv | tail -n1) | grep "archive recovery complete\|database system is ready to accept connections" | tail -n2'
echo -e "\n${RED}Then run:${NC}"
echo 'sed -i "s/ARCHIVE=0/ARCHIVE=1/" /var/lib/postgresql/data/archive_wal.sh'
echo -e '\n'

else

echo -e "\n${RED}backup for server $1 not found!!!${NC}\n"

fi

else

echo -e "\n${RED}must be 2 parameters${NC}\n"

fi
