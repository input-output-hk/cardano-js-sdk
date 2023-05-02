{
  description = "Local Development Environment";
  inputs.nosys.url = "github:divnix/nosys";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.devshell.url = "github:numtide/devshell";
  inputs.flake-compat.url = "github:edolstra/flake-compat?ref=refs/pull/55/head";
  outputs = inputs @ {
    nosys,
    flake-compat,
    ...
  }:
    nosys ((flake-compat ../.).inputs // inputs) (
      {
        self,
        nixpkgs,
        devshell,
        yarnpnp2nix,
        ...
      }:
        with nixpkgs.legacyPackages;
        with nixpkgs.legacyPackages.nodePackages;
        with devshell.legacyPackages; let
          inherit (lib.stringsWithDeps) noDepEntry;
          checkMod = {
            commands = [{package = treefmt;}];
            packages = [alejandra shfmt prettier prettier-plugin-toml];
            devshell.startup.nodejs-setuphook = noDepEntry ''
              export NODE_PATH=${prettier-plugin-toml}/lib/node_modules:$NODE_PATH
            '';
          };
        in {
          devShells = {
            check = mkShell {
              imports = [checkMod];
            };
            default = mkShell {
              name = "Hello My Friend";
              imports = [checkMod];
              commands = [
                {
                  package = nodejs;
                }
                {
                  package = yarnpnp2nix.packages.yarn-plugin;
                }
              ];
            };
          };
        }
    );
}
