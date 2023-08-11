let
  inherit (inputs.std) dmerge;
  inherit (inputs.std.inputs) haumea;
  inherit (inputs.std.lib.ops) readYAML;

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
        }
      ];
    };
    coingecko-proxy-deployment = {
      spec.template.spec.containers = dmerge.updateOn "name" [
        {
          name = "coingecko-proxy";
          image = cell.oci-images.cardano-services.image.name;
        }
      ];
    };
    handle-projector-deployment = {
      spec.template.spec.containers = dmerge.updateOn "name" [
        {
          name = "handle-projector";
          image = cell.oci-images.cardano-services.image.name;
        }
      ];
    };
    pgboss-deployment = {
      spec.template.spec.containers = dmerge.updateOn "name" [
        {
          name = "pg-boss-worker";
          image = cell.oci-images.cardano-services.image.name;
        }
      ];
    };
    stake-pool-projector-deployment = {
      spec.template.spec.containers = dmerge.updateOn "name" [
        {
          name = "stake-pool-projector";
          image = cell.oci-images.cardano-services.image.name;
        }
      ];
    };
  };
}
