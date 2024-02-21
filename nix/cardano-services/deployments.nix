let
  inherit (inputs.std) dmerge;
  inherit (inputs.std.inputs) haumea;
  inherit (inputs.std.lib.ops) readYAML;

  # haumea regex matcher signature:
  # https://nix-community.github.io/haumea/api/matchers.html#matchersregex
  #   we disregard cursor value and haumea inputs here
  loadYaml = _: _: readYAML;

  baseline = with haumea.lib;
    load {
      src = ./deployments;
      loader = [(matchers.regex ''^.+\.(yaml|yml)'' loadYaml)];
    };
in {
  dev-preview = dmerge baseline {
    meta.description = "Development Environment on the Cardano Preview Chain (Frankfurt)";
    backend-deployment = {
      spec.template.spec.containers = dmerge.updateOn "name" [
        {
          name = "backend";
          image = cell.oci-images.cardano-services.image.name;
          env = dmerge.append [
            {
              name = "BUILD_INFO";
              value = cell.oci-images.cardano-services.meta.buildInfo;
            }
          ];
        }
      ];
    };
    handle-provider-deployment = {
      spec.template.spec.containers = dmerge.updateOn "name" [
        {
          name = "handle-provider";
          image = cell.oci-images.cardano-services.image.name;
          env = dmerge.append [
            {
              name = "BUILD_INFO";
              value = cell.oci-images.cardano-services.meta.buildInfo;
            }
          ];
        }
      ];
    };
    handle-projector-deployment = {
      spec.template.spec.containers = dmerge.updateOn "name" [
        {
          name = "handle-projector";
          image = cell.oci-images.cardano-services.image.name;
          env = dmerge.append [
            {
              name = "BUILD_INFO";
              value = cell.oci-images.cardano-services.meta.buildInfo;
            }
          ];
        }
      ];
    };
    pgboss-deployment = {
      spec.template.spec.containers = dmerge.updateOn "name" [
        {
          name = "pg-boss-worker";
          image = cell.oci-images.cardano-services.image.name;
          env = dmerge.append [
            {
              name = "BUILD_INFO";
              value = cell.oci-images.cardano-services.meta.buildInfo;
            }
          ];
        }
      ];
    };
    stake-pool-projector-deployment = {
      spec.template.spec.containers = dmerge.updateOn "name" [
        {
          name = "stake-pool-projector";
          image = cell.oci-images.cardano-services.image.name;
          env = dmerge.append [
            {
              name = "BUILD_INFO";
              value = cell.oci-images.cardano-services.meta.buildInfo;
            }
          ];
        }
      ];
    };
    stake-pool-provider-deployment = {
      spec.template.spec.containers = dmerge.updateOn "name" [
        {
          name = "stake-pool-provider";
          image = cell.oci-images.cardano-services.image.name;
          env = dmerge.append [
            {
              name = "BUILD_INFO";
              value = cell.oci-images.cardano-services.meta.buildInfo;
            }
          ];
        }
      ];
    };
  };
}
