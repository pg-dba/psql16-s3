# psql-s3

<B>version:</B><BR>
<BR>
psql 16.0<BR>
barman-cli 3.9.0<BR>
awscli 1.18.69<BR>
mc RELEASE.2023-10-24T21-42-22Z
<BR><BR>
<B>examples:</B><BR>
<BR>
docker build -t psql-s3:16 .

docker run --rm --network host --name psql-s3 --hostname psql-s3 -it \\<BR>
 -e MINIO_BUCKET=mybackups \\<BR>
 -e MINIO_ACCESS_KEY_ID=minioadmin \\<BR>
 -e MINIO_SECRET_ACCESS_KEY=P@ssw0rd \\<BR>
 -e MINIO_ENDPOINT_URL=http://u20d1h4:9000 \\<BR>
 -v /data/postgres:/var/lib/postgresql/data \\<BR>
 psql-s3:16 bash

docker run --rm --network host --name psql-s3 --hostname psql-s3 -it \\<BR>
 -e MINIO_BUCKET=backups \\<BR>
 -e MINIO_ACCESS_KEY_ID=minioadmin \\<BR>
 -e MINIO_SECRET_ACCESS_KEY=P@ssw0rd \\<BR>
 -e MINIO_ENDPOINT_URL=http://172.27.172.91:30000 \\<BR>
 -v /data/pg1/data:/var/lib/postgresql/data \\<BR>
 psql-s3:16 bash

