#!/usr/bin/env bash
usage() {
  cat << EOF

Usage:
just db environment network [region] [database]

environment - allowwed values:
  d dev
  l live
  s staging

network - allowwed values:
  m mainnet
  p preprod
  s sanchonet
  v preview

region - allowwed values:
  e eu-central-1
  u us-east-2

database - allowwed values:
  a asset
  c cardano db-sync (default)
  h handle
  s stakepool

When "environment" is "dev" or "staging" the only avaible region is "us-east-1" and there is no need to specify it.

Examples:
- connect to dev-mainnet db-sync DB
$ scripts/deployed-db.sh d m

- connect to us-east-2 live-preprod stakepool DB
$ scripts/deployed-db.sh live p us-east-2 stakepool
EOF
  exit 1
}

case $1 in
  d | dev)
    ENV=dev
    ;;

  l | live)
    ENV=live
    ;;

  s | staging)
    ENV=staging
    ;;

  *)
    echo Unknown environemnt "\"$1\""
    usage
    ;;
esac

case $2 in
  m | mainnet)
    NETWORK=mainnet
    ;;

  p | preprod)
    NETWORK=preprod
    ;;

  s | sanchonet)
    NETWORK=sanchonet
    ;;

  v | preview)
    NETWORK=preview
    ;;

  *)
    echo Unknown network "\"$2\""
    usage
    ;;
esac

if [[ $ENV == live ]] ; then
  INPUT_DB=$4

  case $3 in
    e | eu-central-1)
      REGION=eu-central-1
      ;;

    u | us-east-2)
      REGION=us-east-2
      ;;

    *)
      echo Unknown region "\"$3\""
      usage
      ;;

  esac
else
  INPUT_DB=$3

  if [[ $ENV == dev ]] ; then
    REGION=us-east-1
  else
    REGION=eu-west-1
  fi

fi

case $INPUT_DB in
  a | asset)
    DATABASE=asset
    ;;

  c | cardano | db-sync | "")
    DATABASE=cardano
    ;;

  h | handle)
    DATABASE=handle
    ;;

  s | stakepool)
    DATABASE=stakepool
    ;;

  *)
    echo Unknown database "\"$INPUT_DB\""
    usage
    ;;
esac

NAMESPACE=$ENV-$NETWORK

echo Connecting to $NAMESPACE $REGION $DATABASE ...

export KUBECONFIG=$PRJ_ROOT/.kube/$REGION

kubectl config use-context $K8S_USER
kubectl port-forward --context eks-readonly -n $NAMESPACE pods/$NAMESPACE-postgresql-0 5440:5432 &
export PGPASSWORD=$(kubectl get secrets --context eks-readonly -n $NAMESPACE readonly.$NAMESPACE-postgresql.credentials.postgresql.acid.zalan.do --template=\{\{.data.password}} | base64 -d)

# Wait for port to be open
while ! nc -z localhost 5440; do
  sleep 0.1 # wait for 1/10 of the second before check again
done

psql -U readonly -h localhost -p 5440 $DATABASE

kill $(jobs -p)
