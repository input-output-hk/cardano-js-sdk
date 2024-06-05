{
  lib,
  utils,
  values,
  chart,
  config,
  ...
}: {
  templates.pgboss-deployment = lib.mkIf values.pg-boss-worker.enabled {
    apiVersion = "apps/v1";
    kind = "Deployment";
    metadata = {
      name = "${chart.name}-pg-boss-worker";
      labels = utils.appLabels "pg-boss-worker";
    };
    spec = {
      selector.matchLabels = utils.appLabels "pg-boss-worker";
      template = {
        metadata.labels = utils.appLabels "pg-boss-worker";
        spec = {
          imagePullSecrets = [
            {
              name = "dockerconfigjson";
            }
          ];
          containers = [
            {
              inherit (values.cardano-services) image;
              inherit (values.pg-boss-worker) resources;
              name = "pg-boss-worker";
              ports = [
                {
                  containerPort = 3000;
                  name = "http";
                }
              ];
              startupProbe = {
                httpGet = {
                  path = "${values.cardano-services.httpPrefix}/ready";
                  port = 3000;
                };
                initialDelaySeconds = 80;
                periodSeconds = 5;
              };
              livenessProbe = {
                httpGet = {
                  path = "${values.cardano-services.httpPrefix}/health";
                  port = 3000;
                };
              };
              securityContext = {
                runAsUser = 0;
                runAsGroup = 0;
              };
              args = ["start-pg-boss-worker"];
              env = utils.mkPodEnv ({
                  NETWORK = config.network;
                  LOGGER_MIN_SEVERITY = values.cardano-services.loggingLevel;
                  QUEUES = values.pg-boss-worker.queues;

                  METADATA_FETCH_MODE = values.pg-boss-worker.metadata-fetch-mode;

                  STAKE_POOL_PROVIDER_URL = "http://${chart.name}-backend.${chart.namespace}.svc.cluster.local";
                  NETWORK_INFO_PROVIDER_URL = "http://${chart.name}-backend.${chart.namespace}.svc.cluster.local";

                  POSTGRES_POOL_MAX_STAKE_POOL = "5";
                  POSTGRES_HOST_STAKE_POOL = values.postgresName;
                  POSTGRES_PORT_STAKE_POOL = "5432";
                  POSTGRES_DB_STAKE_POOL = values.stakepool.databaseName;
                  POSTGRES_PASSWORD_STAKE_POOL = {
                    valueFrom.secretKeyRef = {
                      name = "${values.stakepool.databaseName}-owner-user.${values.postgresName}.credentials.postgresql.acid.zalan.do";
                      key = "password";
                    };
                  };
                  POSTGRES_USER_STAKE_POOL = {
                    valueFrom.secretKeyRef = {
                      name = "${values.stakepool.databaseName}-owner-user.${values.postgresName}.credentials.postgresql.acid.zalan.do";
                      key = "username";
                    };
                  };

                  POSTGRES_POOL_MAX_DB_SYNC = "5";
                  POSTGRES_HOST_DB_SYNC = values.postgresName;
                  POSTGRES_PORT_DB_SYNC = "5432";
                  POSTGRES_DB_DB_SYNC = "cardano";
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
                }
                // lib.optionalAttrs (values.pg-boss-worker ? env) values.pg-boss-worker.env
                // lib.optionalAttrs (values.pg-boss-worker.metadata-fetch-mode == "smash") {
                  SMASH_URL = values.pg-boss-worker.smash-url;
                });
            }
          ];
        };
      };
    };
  };
}
