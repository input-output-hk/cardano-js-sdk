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
    deployment = {
      spec.template.spec.containers = dmerge.updateOn "name" [
        {
          name = "backend";
          image = cell.oci-images.cardano-services.image.name;
        }
      ];
    };
  };
}
