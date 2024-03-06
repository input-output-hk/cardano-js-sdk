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
  imports = [
    ./deployment.resource.nix
  ];
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

  config = {
    deployments =
      lib.mapAttrs' (name: value: {
        name = "${name}-projector-deployment";

        value = mkIf value.enabled {
          labels = utils.appLabels "${name}-projector";
          imagePullSecrets = ["dockerconfigjson"];
          name = "${chart.name}-${name}-projector";

          containers."${name}-projector" = {
            inherit (value) args env livenessProbe image resources;
            ports.http.containerPort = value.port;
            securityContext = {
              runAsUser = 0;
              runAsGroup = 0;
            };

            volumeMounts.tls.mountPath = "/tls";
          };
          volumes.tls.secret.secretName = "postgresql-server-cert";
        };
      })
      config.projectors;
  };
}
