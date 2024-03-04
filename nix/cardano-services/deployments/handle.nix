{
  config,
  values,
  lib,
  utils,
  chart,
  ...
}: {
  providers.handle-provider = {
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
      ENABLE_METRICS = "true";
      HANDLE_POLICY_IDS = "f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a";
      LOGGER_MIN_SEVERITY = values.cardano-services.loggingLevel;
      NETWORK = values.network;
      OGMIOS_SRV_SERVICE_NAME = values.backend.ogmiosSrvServiceName;
      SERVICE_NAMES = "handle";

      BUILD_INFO = lib.mkIf (values.cardano-services.buildInfo != null) values.cardano-services.buildInfo;
      ALLOWED_ORIGINS = lib.mkIf (values.backend.allowedOrigins != null) values.backend.allowedOrigins;

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
      POSTGRES_SSL_HANDLE = "true";
      POSTGRES_SSL_CA_FILE_HANDLE = "/tls/ca.crt";
    };
  };

  projectors.handle = {
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
      NETWORK = values.network;
      LOGGER_MIN_SEVERITY = values.cardano-services.loggingLevel;
      OGMIOS_SRV_SERVICE_NAME = values.backend.ogmiosSrvServiceName;
      PROJECTION_NAMES = "handle";
      HANDLE_POLICY_IDS = "f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a";

      BUILD_INFO = lib.mkIf (values.cardano-services.buildInfo != null) values.cardano-services.buildInfo;

      POSTGRES_POOL_MAX = "2";
      POSTGRES_HOST = values.postgresName;
      POSTGRES_PORT = "5432";
      POSTGRES_DB = "handle";
      POSTGRES_PASSWORD = {
        valueFrom.secretKeyRef = {
          name = "handle-owner-user.${values.postgresName}.credentials.postgresql.acid.zalan.do";
          key = "password";
        };
      };
      POSTGRES_USER = {
        valueFrom.secretKeyRef = {
          name = "handle-owner-user.${values.postgresName}.credentials.postgresql.acid.zalan.do";
          key = "username";
        };
      };
      POSTGRES_SSL = "true";
      POSTGRES_SSL_CA_FILE = "/tls/ca.crt";
    };
  };
}
