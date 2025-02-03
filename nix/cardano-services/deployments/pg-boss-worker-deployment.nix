{
  lib,
  utils,
  values,
  config,
  ...
}: {
  resources.deployments.pgboss = lib.mkIf values.pg-boss-worker.enabled {
    metadata = {
      name = "${config.name}-pg-boss-worker";
      labels = utils.appLabels "pg-boss-worker";
    };
    spec = {
      selector.matchLabels = utils.appLabels "pg-boss-worker";
      template = {
        metadata.labels = utils.appLabels "pg-boss-worker";
        spec = {
          imagePullSecrets.dockerconfigjson = {};
          containers.pg-boss-worker = {
            inherit (values.cardano-services) image;
            inherit (values.pg-boss-worker) resources;
            ports.http.containerPort = 3000;
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
                NODE_ENV = values.cardano-services.nodeEnv;

                METADATA_FETCH_MODE = values.pg-boss-worker.metadata-fetch-mode;
                BLOCKFROST_API_KEY = {
                  valueFrom.secretKeyRef = {
                    name = "blockfrost";
                    key = "api-key";
                  };
                };

                STAKE_POOL_PROVIDER_URL = "https://cardano-mainnet.blockfrost.io/api/v0";
                NETWORK_INFO_PROVIDER_URL = "https://cardano-mainnet.blockfrost.io/api/v0";

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
          };
        };
      };
    };
  };
}
