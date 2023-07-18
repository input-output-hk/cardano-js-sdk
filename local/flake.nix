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
      }: let
        inherit
          (nixpkgs.legacyPackages)
          lib
          treefmt
          alejandra
          shfmt
          ;
        inherit
          (nixpkgs.legacyPackages.nodePackages)
          prettier
          prettier-plugin-toml
          ;
        inherit (devshell.legacyPackages) mkShell;
        inherit (lib.stringsWithDeps) noDepEntry;
        formattingModule = {
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
            imports = [formattingModule];
          };
          default = mkShell {
            name = "Cardano JS SDK Local Env";
            imports = [formattingModule];
            commands = [
              {package = std.std.cli.std;}
            ];
          };
        };
      }
    );
}
