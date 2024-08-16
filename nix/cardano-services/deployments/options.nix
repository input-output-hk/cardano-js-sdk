{lib, ...}: let
  inherit (lib) types;
in {
  options = {
    region = lib.mkOption {
      type = types.enum ["us-east-1" "us-east-2" "eu-central-1" "eu-west-1"];
      description = "Region of the deployment";
    };

    network = lib.mkOption {
      type = types.enum ["mainnet" "preprod" "preview" "sanchonet" "local"];
      description = "Network of the deployment";
    };
  };
}
