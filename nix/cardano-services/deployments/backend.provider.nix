{
  config,
  values,
  lib,
  ...
}: {
  providers.backend = {
    inherit (values.cardano-services) image;
    args = ["start-provider-server"];
    port = 3000;
    metricsPath = "${values.cardano-services.httpPrefix}/metrics";

    livenessProbe = {
      timeoutSeconds = 5;
      periodSeconds = 10;
      httpGet = {
        path = "${values.cardano-services.httpPrefix}/ready";
        port = 3000;
      };
    };

    env =
      {
        NETWORK = config.network;
        ENABLE_METRICS = "true";
        SERVICE_NAMES = "asset,network-info,rewards,stake-pool,tx-submit,utxo";
        OGMIOS_SRV_SERVICE_NAME = values.backend.ogmiosSrvServiceName;
        LOGGER_MIN_SEVERITY = values.cardano-services.loggingLevel;
        TOKEN_METADATA_SERVER_URL = values.cardano-services.tokenMetadataServerUrl;
        HANDLE_POLICY_IDS = "f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a";
        USE_BLOCKFROST = builtins.toJSON values.blockfrost-worker.enabled;
        USE_KORA_LABS = "true";
        DISABLE_STAKE_POOL_METRIC_APY = "true";
        PAGINATION_PAGE_SIZE_LIMIT = "5500";
        NODE_ENV = values.cardano-services.nodeEnv;

        HANDLE_PROVIDER_SERVER_URL =
          if config.network == "mainnet"
          then "https://api.handle.me"
          else "https://${config.network}.api.handle.me";

        BUILD_INFO = values.cardano-services.buildInfo;
        ALLOWED_ORIGINS = values.backend.allowedOrigins;

        POSTGRES_POOL_MAX_DB_SYNC = "50";
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
      // lib.optionalAttrs values.backend.passHandleDBArgs {
        POSTGRES_POOL_MAX_HANDLE = "10";
        POSTGRES_HOST_HANDLE = values.postgresName;
        POSTGRES_PORT_HANDLE = "5432";
        POSTGRES_DB_HANDLE = "handle";
        POSTGRES_PASSWORD_HANDLE = {
          valueFrom.secretKeyRef = {
            name = "handle-owner-user.${values.postgresName}.credentials.postgresql.acid.zalan.do";
            key = "password";
          };
        };
        POSTGRES_USER_HANDLE = {
          valueFrom.secretKeyRef = {
            name = "handle-owner-user.${values.postgresName}.credentials.postgresql.acid.zalan.do";
            key = "username";
          };
        };
      };
  };
}
