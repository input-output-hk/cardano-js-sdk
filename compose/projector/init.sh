#!/bin/bash

DB=$(cat ${POSTGRES_DB_FILE})
PASSWORD=$(cat ${POSTGRES_PASSWORD_FILE})
USER=$(cat ${POSTGRES_USER_FILE})

# To init a postgres container db, the initdb.d can be used.
# Ref: "Initialization scripts" in https://hub.docker.com/_/postgres
# The problem using this clean and built-in approach is this is executed only once,
# when the database is created the first time.
# In order to apply changes to the db schemas using this approach would require an
# explicit DROP of all the databases by the user with two great drawbacks:
# a) it requires an opartion by hand
# b) it would require to resync from genesis

# The custom approach adopted doesn't requires any actions by the user and allows
# changes between versions of the SDK.

psql "postgresql://${USER}:${PASSWORD}@postgres/" -c "CREATE DATABASE ${DB}"
psql "postgresql://${USER}:${PASSWORD}@postgres/" -c "CREATE DATABASE ${DB}_test"

_term() {
  kill $CHILD
}

trap _term SIGTERM

cd /app/packages/cardano-services
../../node_modules/.bin/tsx watch --clear-screen=false --conditions=development src/cli start-projector &

CHILD=$!
wait "$CHILD"
