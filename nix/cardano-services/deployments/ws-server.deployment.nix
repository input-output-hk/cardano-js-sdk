{
  lib,
  utils,
  values,
  config,
  ...
}: {
  resources.services.ws-server = lib.mkIf values.ws-server.enabled {
    metadata = {
      name = "${config.name}-ws-server";
      labels = utils.appLabels "ws-server";
    };
    spec = {
      ports.http = {
        protocol = "TCP";
        port = 3000;
        targetPort = 3000;
      };
      selector = utils.appLabels "ws-server";
    };
  };

  resources.deployments.ws-server = lib.mkIf values.ws-server.enabled {
    metadata = {
      name = "${config.name}-ws-server";
      labels = utils.appLabels "ws-server";
    };
    spec = {
      selector.matchLabels = utils.appLabels "ws-server";
      template = {
        metadata.labels = utils.appLabels "ws-server";
        spec = {
          imagePullSecrets.dockerconfigjson = {};
          containers.ws-server = {
            inherit (values.cardano-services) image;
            inherit (values.ws-server) resources;
            ports.http.containerPort = 3000;
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
          };
          volumes.tls.secret.secretName = "postgresql-server-cert";
        };
      };
    };
  };
}
