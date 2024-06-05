

# Usage example:
# just db us-east-2 live-mainnet cardano
db region namespace database:
  #!/usr/bin/env bash
  export KUBECONFIG=${PRJ_ROOT}/.kube/{{region}}

  kubectl port-forward --context $K8S_USER -n {{namespace}} pods/{{namespace}}-postgresql-0 5432:5432 &
  export PGPASSWORD=$(kubectl get secrets --context $K8S_USER -n {{namespace}} readonly.{{namespace}}-postgresql.credentials.postgresql.acid.zalan.do --template=\{\{.data.password}} | base64 -d)

  # Wait for port to be open
  while ! nc -z localhost 5432; do
    sleep 0.1 # wait for 1/10 of the second before check again
  done

  psql -U readonly -h localhost {{database}}

  kill $(jobs -p)

