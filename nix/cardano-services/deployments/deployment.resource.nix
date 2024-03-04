{
  pkgs,
  lib,
  utils,
  config,
  chart,
  ...
}: let
  inherit (lib) types mkOption mkIf;
  mkIfList = list: mkIf (list != []) list;
  mkIfAttrs = attrs: mkIf (attrs != {}) attrs;

  attrsToK8sList = attrs: mkIfList (lib.mapAttrsToList (name: value: value // {inherit name;}) attrs);
in {
  options = {
    deployments = mkOption {
      # TODO: Autogenerate this somehow
      type = types.attrsOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
          };

          labels = mkOption {
            type = types.attrsOf types.str;
          };

          replicas = mkOption {
            type = types.number;
            default = 1;
          };

          imagePullSecrets = mkOption {
            type = types.listOf types.string;
            default = [];
          };

          volumes = mkOption {
            type = types.attrsOf types.anything;
            default = {};
          };

          containers = mkOption {
            type = types.attrsOf (types.submodule {
              options = {
                image = mkOption {
                  type = types.str;
                };

                resources = mkOption {
                  type = types.anything;
                  default = {};
                };

                env = mkOption {
                  type = types.attrsOf types.anything;
                  default = {};
                };

                ports = mkOption {
                  type = types.attrsOf types.anything;
                  default = {};
                };

                args = mkOption {
                  type = types.listOf types.str;
                  default = [];
                };

                command = mkOption {
                  type = types.listOf types.str;
                  default = [];
                };

                securityContext = mkOption {
                  type = types.anything;
                  default = {};
                };

                livenessProbe = mkOption {
                  type = types.anything;
                  default = {};
                };

                readinessProbe = mkOption {
                  type = types.anything;
                  default = {};
                };

                startupProbe = mkOption {
                  type = types.anything;
                  default = {};
                };

                volumeMounts = mkOption {
                  type = types.anything;
                };
              };
            });
          };
        };
      });

      default = {};
      description = "Provider server definitions";
    };
  };

  config = {
    templates =
      lib.mapAttrs (name: value: {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          inherit (value) name;
          labels = mkIfAttrs value.labels;
        };
        spec = {
          replicas = mkIf (value.replicas != 1) value.replicas;
          selector.matchLabels = mkIfAttrs value.labels;
          template = {
            metadata.labels = mkIfAttrs value.labels;
            spec = {
              imagePullSecrets = mkIfList (map (it: {name = it;}) value.imagePullSecrets);
              containers =
                lib.mapAttrsToList (name: value: {
                  inherit name;
                  inherit (value) image;

                  args = mkIfList value.args;
                  command = mkIfList value.command;

                  resources = mkIfAttrs value.resources;
                  securityContext = mkIfAttrs value.securityContext;
                  env = mkIfAttrs (utils.mkPodEnv value.env);
                  livenessProbe = mkIfAttrs value.livenessProbe;
                  readinessProbe = mkIfAttrs value.readinessProbe;
                  startupProbe = mkIfAttrs value.startupProbe;

                  ports = attrsToK8sList value.ports;
                  volumeMounts = attrsToK8sList value.volumeMounts;
                })
                value.containers;
              volumes = attrsToK8sList value.volumes;
            };
          };
        };
      })
      config.deployments;
  };
}
