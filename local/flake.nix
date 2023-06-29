{
  description = "Local Development Environment";
  inputs.nosys.url = "github:divnix/nosys";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.devshell.url = "github:numtide/devshell";
  inputs.call-flake.url = "github:divnix/call-flake";
  outputs = inputs @ {
    nosys,
    call-flake,
    ...
  }:
    nosys ((call-flake ../.).inputs // inputs) (
      {
        self,
        nixpkgs,
        devshell,
        std,
        ...
      }:
        with nixpkgs.legacyPackages;
        with nixpkgs.legacyPackages.nodePackages;
        with devshell.legacyPackages; let
          inherit (lib.stringsWithDeps) noDepEntry;
          checkMod = {
            commands = [{package = treefmt;}];
            packages = [
              alejandra
              shfmt
              prettier
              prettier-plugin-toml
            ];
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
              name = "Cardano JS SDK Local Env";
              imports = [checkMod];
              commands = [
                {package = std.std.cli.std;}
              ];
            };
          };
        }
    );
}
