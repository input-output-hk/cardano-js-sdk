{
  lib,
  values,
  chart,
  utils,
  config,
  ...
}: {
  templates.blockfrost-worker-deployment = lib.mkIf values.blockfrost-worker.enabled {
    apiVersion = "apps/v1";
    kind = "Deployment";
    metadata = {
      name = "${chart.name}-blockfrost-worker";
      labels = utils.appLabels "blockfrost-worker";
    };
    spec = {
      selector.matchLabels = utils.appLabels "blockfrost-worker";
      template = {
        metadata.labels = utils.appLabels "blockfrost-worker";
        spec = {
          imagePullSecrets = [
            {
              name = "dockerconfigjson";
            }
          ];
          containers = [
            {
              inherit (values.cardano-services) image;
              inherit (values.blockfrost-worker) resources;
              name = "blockfrost-worker";
              args = ["start-blockfrost-worker"];
              ports = [
                {
                  containerPort = 3000;
                  name = "http";
                }
              ];
              livenessProbe = {
                timeoutSeconds = 5;
                httpGet = {
                  path = "${values.cardano-services.httpPrefix}/health";
                  port = 3000;
                };
              };
              securityContext = {
                runAsUser = 0;
                runAsGroup = 0;
              };
              env = utils.mkPodEnv {
                NETWORK = config.network;
                LOGGER_MIN_SEVERITY = values.cardano-services.loggingLevel;

                BLOCKFROST_API_KEY = {
                  valueFrom.secretKeyRef = {
                    name = "blockfrost";
                    key = "api-key";
                  };
                };
                POSTGRES_HOST_DB_SYNC = values.postgresName;
                POSTGRES_PORT_DB_SYNC = "5432";
                POSTGRES_DB_DB_SYNC = "cardano";
                # Actually, we'd need blokfrost-owner-user (for create table)
                # and cardano-public-reader-user (for accessing dbsync source data).
                # Howerver, quoting https://postgres-operator.readthedocs.io/en/refactoring-sidecars/user/#manifest-roles:
                # > At the moment it is not possible to define membership of the manifest role in other roles.
                POSTGRES_PASSWORD_DB_SYNC = {
                  valueFrom.secretKeyRef = {
                    name = "cardano-owner-user.${values.postgresName}.credentials.postgresql.acid.zalan.do";
                    key = "password";
                  };
                };
                POSTGRES_USER_DB_SYNC = {
                  valueFrom.secretKeyRef = {
                    name = "cardano-owner-user.${values.postgresName}.credentials.postgresql.acid.zalan.do";
                    key = "username";
                  };
                };
                POSTGRES_SSL_DB_SYNC = "true";
                POSTGRES_SSL_CA_FILE_DB_SYNC = "/tls/ca.crt";
              };
              volumeMounts = [
                {
                  mountPath = "/tls";
                  name = "tls";
                }
              ];
            }
          ];
          volumes = [
            {
              name = "tls";
              secret.secretName = "postgresql-server-cert";
            }
          ];
        };
      };
    };
  };
}
