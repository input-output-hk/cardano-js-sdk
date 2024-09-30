{
  pkgs,
  lib,
  utils,
  config,
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

          volumeMounts = mkOption {
            type = types.attrsOf types.attrs;
            default = {};
          };

          volumes = mkOption {
            type = types.attrsOf types.attrs;
            default = {};
          };
        };
      });

      default = {};
      description = "Provider server definitions";
    };
  };

  config = {
    resources.deployments = lib.mapAttrs (name: value:
      mkIf value.enabled {
        metadata = {
          name = "${config.name}-${name}";
          labels = utils.appLabels name;
        };
        spec = {
          selector.matchLabels = utils.appLabels name;
          template = {
            metadata.labels = utils.appLabels name;
            spec = {
              imagePullSecrets.dockerconfigjson = {};

              containers."${name}" = {
                inherit (value) args livenessProbe image resources;
                env = utils.mkPodEnv value.env;
                ports.http.containerPort = value.port;
                securityContext = {
                  runAsUser = 0;
                  runAsGroup = 0;
                };

                volumeMounts = [
                  {
                    name = "tls";
                    mountPath = "/tls";
                  }
                ];
              };
              volumes.tls.secret.secretName = "postgresql-server-cert";
            };
          };
        };
      })
    config.providers;

    resources.services =
      lib.mapAttrs (
        name: value: {
          metadata = {
            name = "${config.name}-${name}";
            labels = utils.appLabels name;
          };
          spec = {
            ports.http = {
              protocol = "TCP";
              port = 80;
              targetPort = value.port;
            };
            selector = utils.appLabels name;
          };
        }
      )
      config.providers;

    templates =
      lib.mapAttrs' (
        name: value: {
          name = "${name}-monitor";
          value = {
            apiVersion = "monitoring.coreos.com/v1";
            kind = "ServiceMonitor";
            metadata = {
              labels = {instance = "primary";};
              name = "${config.name}-${name}-monitor";
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
        }
      )
      config.providers;
  };
}
