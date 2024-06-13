FROM ubuntu:20.04

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && apt-get install -y lsb-release gnupg2 apt-utils wget && \
    sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update && \
    mkdir /var/lib/postgresql && \
    groupadd -g 999 postgres && \
    useradd -u 999 -g 999 postgres -d /var/lib/postgresql -s /bin/bash && \
    chown 999:999 /var/lib/postgresql && \
    apt-get -y install postgresql-client-16 postgresql-contrib-16 perl barman-cli awscli gosu nano mutt iputils-ping dnsutils telnet && \
    apt-get clean all && \
    unset DEBIAN_FRONTEND

RUN wget --quiet https://dl.min.io/client/mc/release/linux-amd64/mc && \
    chmod 700 mc && \
    mv mc /usr/bin/

RUN rm -rf /var/lib/postgresql/16
RUN mkdir -p /var/lib/postgresql/data

VOLUME /var/lib/postgresql/data

COPY s3-entrypoint.sh /s3-entrypoint.sh
RUN chmod 700 /s3-entrypoint.sh

COPY help-restore.sh /root/help-restore.sh
RUN chmod 700 /root/help-restore.sh

COPY list-backups.sh /root/list-backups.sh
RUN chmod 700 /root/list-backups.sh

COPY restore.sh /root/restore.sh
RUN chmod 700 /root/restore.sh

WORKDIR /root

RUN echo 'alias nocomments="sed -e :a -re '"'"'s/<\!--.*?-->//g;/<\!--/N;//ba'"'"' | sed -e :a -re '"'"'s/\/\*.*?\*\///g;/\/\*/N;//ba'"'"' | grep -v -P '"'"'^\s*(#|;|--|//|$)'"'"'"' >> ~/.bashrc

ENTRYPOINT ["/s3-entrypoint.sh"]

CMD ["/bin/bash"]
