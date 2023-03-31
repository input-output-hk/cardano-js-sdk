FROM ghcr.io/coroot/coroot-pg-agent

RUN apt-get update
RUN apt-get install -y postgresql-client

COPY init.sh .
RUN chmod 755 init.sh

ENTRYPOINT ["/init.sh"]
