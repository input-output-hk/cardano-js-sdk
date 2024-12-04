{
  values,
  lib,
  utils,
  config,
  ...
}: {
  providers.stake-pool-provider = {
    inherit (values.cardano-services) image;
    args = ["start-provider-server"];
    port = 3000;
    metricsPath = "${values.cardano-services.httpPrefix}/metrics";

    livenessProbe = {
      timeoutSeconds = 5;
      httpGet = {
        path = "${values.cardano-services.httpPrefix}/health";
        port = 3000;
      };
    };

    env = {
      NETWORK = config.network;
      OGMIOS_SRV_SERVICE_NAME = values.backend.ogmiosSrvServiceName;
      LOGGER_MIN_SEVERITY = values.cardano-services.loggingLevel;
      ENABLE_METRICS = "true";
      DISABLE_STAKE_POOL_METRIC_APY = "true";
      PAGINATION_PAGE_SIZE_LIMIT = "5500";
      SERVICE_NAMES = "stake-pool";
      USE_TYPEORM_STAKE_POOL_PROVIDER = "true";
      TOKEN_METADATA_SERVER_URL = values.cardano-services.tokenMetadataServerUrl;
      NODE_ENV = values.cardano-services.nodeEnv;

      ALLOWED_ORIGINS = values.backend.allowedOrigins;

      POSTGRES_POOL_MAX_STAKE_POOL = "10";
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
    };
  };

  projectors.stake-pool = {
    inherit (values.cardano-services) image;
    livenessProbe = {
      timeoutSeconds = 5;
      httpGet = {
        path = "${values.cardano-services.httpPrefix}/health";
        port = 3000;
      };
    };

    args = ["start-projector"];
    port = 3000;

    env = {
      NETWORK = config.network;
      LOGGER_MIN_SEVERITY = values.cardano-services.loggingLevel;
      OGMIOS_SRV_SERVICE_NAME = values.backend.ogmiosSrvServiceName;
      PROJECTION_NAMES = "stake-pool,stake-pool-metadata-job,stake-pool-metrics-job,stake-pool-rewards-job";
      NODE_ENV = values.cardano-services.nodeEnv;

      POSTGRES_POOL_MAX = "2";
      POSTGRES_HOST = values.postgresName;
      POSTGRES_PORT = "5432";
      POSTGRES_DB = values.stakepool.databaseName;
      POSTGRES_PASSWORD = {
        valueFrom.secretKeyRef = {
          name = "${values.stakepool.databaseName}-owner-user.${values.postgresName}.credentials.postgresql.acid.zalan.do";
          key = "password";
        };
      };
      POSTGRES_USER = {
        valueFrom.secretKeyRef = {
          name = "${values.stakepool.databaseName}-owner-user.${values.postgresName}.credentials.postgresql.acid.zalan.do";
          key = "username";
        };
      };
    };
  };
}
