#!/bin/sh

DB=$(cat /run/secrets/postgres_db_db_sync)
PASSWORD=$(cat /run/secrets/postgres_password)
USER=$(cat /run/secrets/postgres_user)

echo "postgres:5432:${DB}:${USER}:${PASSWORD}" >/smash-config/pgpass

_term() {
  kill $CHILD
}

trap _term SIGTERM

PGPASSFILE=/smash-config/pgpass cardano-smash-server \
  --config /config/cardano-db-sync/config.json \
  --port 3100 \
  --admins /smash-config/smash-admins.txt &

CHILD=$!
wait "$CHILD"
