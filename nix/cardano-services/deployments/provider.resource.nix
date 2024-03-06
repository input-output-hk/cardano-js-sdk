{
  pkgs,
  lib,
  utils,
  config,
  chart,
  ...
}: let
  inherit (lib) types mkOption mkIf;
in {
  options = {
    providers = mkOption {
      # TODO: Add proper type definition and generate docs from it
      type = types.attrsOf (types.submodule {
        options = {
          enabled = lib.mkEnableOption "Provider";

          port = mkOption {
            type = types.number;
          };

          replicas = mkOption {
            type = types.number;
            default = 1;
          };

          image = mkOption {
            type = types.str;
          };

          metricsPath = mkOption {
            type = types.str;
          };

          resources = mkOption {
            type = types.anything;
          };

          livenessProbe = mkOption {
            type = types.anything;
          };

          env = mkOption {
            type = types.attrsOf types.anything;
          };

          args = mkOption {
            type = types.listOf types.str;
          };
        };
      });

      default = {};
      description = "Provider server definitions";
    };
  };

  config = {
    templates = lib.mkMerge (lib.mapAttrsToList (name: value:
      mkIf value.enabled {
        "${name}-monitor" = {
          apiVersion = "monitoring.coreos.com/v1";
          kind = "ServiceMonitor";
          metadata = {
            labels = {instance = "primary";};
            name = "${chart.name}-${name}-monitor";
          };
          spec = {
            endpoints = [
              {
                honorLabels = true;
                interval = "60s";
                path = value.metricsPath;
                port = "http";
              }
            ];
            namespaceSelector.any = false;
            selector.matchLabels.app = name;
          };
        };

        "${name}-service" = {
          apiVersion = "v1";
          kind = "Service";
          metadata = {
            name = "${chart.name}-${name}";
            labels = utils.appLabels name;
          };
          spec = {
            ports = [
              {
                name = "http";
                protocol = "TCP";
                port = 80;
                targetPort = value.port;
              }
            ];
            selector = utils.appLabels name;
          };
        };

        "${name}-deployment" = {
          apiVersion = "apps/v1";
          kind = "Deployment";
          metadata = {
            name = "${chart.name}-${name}";
            labels = utils.appLabels name;
          };
          spec = {
            replicas = mkIf (value.replicas != 1) value.replicas;
            selector.matchLabels = utils.appLabels name;
            template = {
              metadata.labels = utils.appLabels name;
              spec = {
                imagePullSecrets = [
                  {
                    name = "dockerconfigjson";
                  }
                ];
                containers = [
                  {
                    inherit name;
                    inherit (value) image resources args livenessProbe;
                    ports = [
                      {
                        containerPort = value.port;
                        name = "http";
                      }
                    ];
                    securityContext = {
                      runAsUser = 0;
                      runAsGroup = 0;
                    };
                    env = utils.mkPodEnv value.env;

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
      })
    config.providers);
  };
}
