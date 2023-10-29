#!/bin/bash

if [[ ! -z ${MINIO_BACKET+x} ]]; then 

aws configure --profile minio set aws_access_key_id "${AWS_ACCESS_KEY_ID}"
aws configure --profile minio set aws_secret_access_key "${AWS_SECRET_ACCESS_KEY}"
mc config --quiet host add minio ${MINIO_ENDPOINT_URL} ${AWS_ACCESS_KEY_ID} ${AWS_SECRET_ACCESS_KEY}

#cat /root/.aws/credentials 
#cat /var/lib/postgresql/.aws/credentials 

echo "echo ''" >> /root/.bashrc
echo "source /root/help-restore.sh" >> /root/.bashrc
echo "echo ''" >> /root/.bashrc

else

echo "IF YOU WANT TO USE minio, THAT YOU MUST DEFINE ENVIRONMENT."

fi

if [[ "$(cat /etc/passwd | grep ^postgres: | wc -l)" == "0" ]]; then
groupadd -g 999 postgres
useradd -u 999 -g 999 postgres -d /var/lib/postgresql -s /bin/bash
fi

if [[ "$(cat /etc/resolv.conf | grep '169.254.169.250' | wc -l)" == "0" ]]; then
echo "nameserver 169.254.169.250" > /etc/resolv.conf
fi

"$@"
