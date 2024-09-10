{
  lib,
  utils,
  values,
  chart,
  config,
  ...
}: {
  templates.ws-server-service = lib.mkIf values.ws-server.enabled {
    apiVersion = "v1";
    kind = "Service";
    metadata = {
      name = "${chart.name}-ws-server";
      labels = utils.appLabels "ws-server";
    };
    spec = {
      ports = [
        {
          name = "http";
          protocol = "TCP";
          port = 3000;
          targetPort = 3000;
        }
      ];
      selector = utils.appLabels "ws-server";
    };
  };

  templates.ws-server-deployment = lib.mkIf values.ws-server.enabled {
    apiVersion = "apps/v1";
    kind = "Deployment";
    metadata = {
      name = "${chart.name}-ws-server";
      labels = utils.appLabels "ws-server";
    };
    spec = {
      selector.matchLabels = utils.appLabels "ws-server";
      template = {
        metadata.labels = utils.appLabels "ws-server";
        spec = {
          imagePullSecrets = [
            {
              name = "dockerconfigjson";
            }
          ];
          containers = [
            {
              inherit (values.cardano-services) image;
              inherit (values.ws-server) resources;
              name = "ws-server";
              ports = [
                {
                  containerPort = 3000;
                  name = "http";
                }
              ];
              livenessProbe = {
                httpGet = {
                  path = "/health";
                  port = 3000;
                };
              };
              securityContext = {
                runAsUser = 0;
                runAsGroup = 0;
              };
              args = ["start-ws-server"];
              env = utils.mkPodEnv {
                NETWORK = config.network;
                DB_CACHE_TTL = "7200";
                OGMIOS_URL = "ws://${config.namespace}-cardano-core.${config.namespace}.svc.cluster.local:1337";

                POSTGRES_POOL_MAX_DB_SYNC = "2";
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
