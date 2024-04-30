{
  config,
  values,
  lib,
  utils,
  chart,
  ...
}: {
  providers.asset-provider = {
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
      BUILD_INFO = values.cardano-services.buildInfo;
      ALLOWED_ORIGINS = values.backend.allowedOrigins;

      NETWORK = config.network;
      OGMIOS_SRV_SERVICE_NAME = values.backend.ogmiosSrvServiceName;
      LOGGER_MIN_SEVERITY = values.cardano-services.loggingLevel;
      ENABLE_METRICS = "true";
      PAGINATION_PAGE_SIZE_LIMIT = "5500";
      SERVICE_NAMES = "asset";
      TOKEN_METADATA_SERVER_URL = values.cardano-services.tokenMetadataServerUrl;
      USE_TYPEORM_ASSET_PROVIDER = "true";

      POSTGRES_POOL_MAX_ASSET = "10";
      POSTGRES_HOST_ASSET = values.postgresName;
      POSTGRES_PORT_ASSET = "5432";
      POSTGRES_DB_ASSET = "asset";
      POSTGRES_PASSWORD_ASSET = {
        valueFrom.secretKeyRef = {
          name = "asset-owner-user.${values.postgresName}.credentials.postgresql.acid.zalan.do";
          key = "password";
        };
      };
      POSTGRES_USER_ASSET = {
        valueFrom.secretKeyRef = {
          name = "asset-owner-user.${values.postgresName}.credentials.postgresql.acid.zalan.do";
          key = "username";
        };
      };
      POSTGRES_SSL_ASSET = "true";
      POSTGRES_SSL_CA_FILE_ASSET = "/tls/ca.crt";
    };
  };

  projectors.asset = {
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
      BUILD_INFO = values.cardano-services.buildInfo;

      NETWORK = config.network;
      LOGGER_MIN_SEVERITY = values.cardano-services.loggingLevel;
      OGMIOS_SRV_SERVICE_NAME = values.backend.ogmiosSrvServiceName;
      PROJECTION_NAMES = "asset";

      POSTGRES_POOL_MAX = "2";
      POSTGRES_HOST = values.postgresName;
      POSTGRES_PORT = "5432";
      POSTGRES_DB = "asset";
      POSTGRES_PASSWORD = {
        valueFrom.secretKeyRef = {
          name = "asset-owner-user.${values.postgresName}.credentials.postgresql.acid.zalan.do";
          key = "password";
        };
      };
      POSTGRES_USER = {
        valueFrom.secretKeyRef = {
          name = "asset-owner-user.${values.postgresName}.credentials.postgresql.acid.zalan.do";
          key = "username";
        };
      };
      POSTGRES_SSL = "true";
      POSTGRES_SSL_CA_FILE = "/tls/ca.crt";
    };
  };
}
