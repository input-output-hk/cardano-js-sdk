#!/bin/bash

DB=`cat /run/secrets/postgres_db`
PASSWORD=`cat /run/secrets/postgres_password`
USER=`cat /run/secrets/postgres_user`

URL="postgresql://${USER}:${PASSWORD}@postgres/${DB}"

psql $URL -c "CREATE EXTENSION IF NOT EXISTS pg_stat_statements"
psql $URL -c "GRANT pg_monitor TO ${USER}"

_term() {
  kill $CHILD
}

trap _term SIGTERM

DSN="${URL}?connect_timeout=1&statement_timeout=30000&sslmode=disable" coroot-pg-agent &
CHILD=$!
wait "$CHILD"
