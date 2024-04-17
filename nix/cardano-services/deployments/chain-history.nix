{
  config,
  values,
  lib,
  utils,
  chart,
  ...
}: {
  providers.chain-history-provider = {
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
      NETWORK = values.network;
      OGMIOS_SRV_SERVICE_NAME = values.backend.ogmiosSrvServiceName;
      LOGGER_MIN_SEVERITY = values.cardano-services.loggingLevel;
      ENABLE_METRICS = "true";
      DISABLE_STAKE_POOL_METRIC_APY = "true";
      PAGINATION_PAGE_SIZE_LIMIT = "5500";
      SERVICE_NAMES = "chain-history";
      USE_TYPEORM_STAKE_POOL_PROVIDER = "true";
      TOKEN_METADATA_SERVER_URL = values.cardano-services.tokenMetadataServerUrl;
      USE_BLOCKFROST = "true";

      BUILD_INFO = values.cardano-services.buildInfo;
      ALLOWED_ORIGINS = values.backend.allowedOrigins;

      POSTGRES_POOL_MAX_STAKE_POOL = "10";
      POSTGRES_HOST_STAKE_POOL = values.postgresName;
      POSTGRES_PORT_STAKE_POOL = "5432";
      POSTGRES_DB_STAKE_POOL = "stakepool";
      POSTGRES_PASSWORD_STAKE_POOL = {
        valueFrom.secretKeyRef = {
          name = "stakepool-owner-user.${values.postgresName}.credentials.postgresql.acid.zalan.do";
          key = "password";
        };
      };
      POSTGRES_USER_STAKE_POOL = {
        valueFrom.secretKeyRef = {
          name = "stakepool-owner-user.${values.postgresName}.credentials.postgresql.acid.zalan.do";
          key = "username";
        };
      };
      POSTGRES_SSL_STAKE_POOL = "true";
      POSTGRES_SSL_CA_FILE_STAKE_POOL = "/tls/ca.crt";
    };
  };
}
