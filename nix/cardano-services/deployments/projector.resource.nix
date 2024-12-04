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
    projectors = mkOption {
      # TODO: Add proper type definition and generate docs from it
      type = types.attrsOf (types.submodule {
        options = {
          enabled = lib.mkEnableOption "Projector";

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
            default = [];
          };
        };
      });

      default = {};
      description = "Projector services definitions";
    };
  };

  config.resources.deployments =
    lib.mapAttrs' (name: value: {
      name = "${name}-projector";

      value = mkIf value.enabled {
        metadata = {
          labels = utils.appLabels "${name}-projector";
          name = "${config.name}-${name}-projector";
        };
        spec = {
          selector.matchLabels = utils.appLabels "${name}-projector";
          template = {
            metadata.labels = utils.appLabels "${name}-projector";
            spec = {
              imagePullSecrets.dockerconfigjson = {};

              containers."${name}-projector" = {
                inherit (value) args livenessProbe image resources;
                env = utils.mkPodEnv value.env;
                ports.http.containerPort = value.port;
                securityContext = {
                  runAsUser = 0;
                  runAsGroup = 0;
                };
              };
            };
          };
        };
      };
    })
    config.projectors;
}
