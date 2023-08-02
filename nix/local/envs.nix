let
  inherit (inputs.nixpkgs) lib;
  inherit
    (inputs.nixpkgs)
    treefmt
    alejandra
    shfmt
    yq
    git-subrepo
    ;
  inherit
    (inputs.nixpkgs.nodePackages)
    prettier
    prettier-plugin-toml
    ;
  inherit (inputs.std.lib.dev) mkShell;
  inherit (inputs.std.std.cli) std;

  inherit (lib.stringsWithDeps) noDepEntry;

  formattingModule = {
    commands = [{package = treefmt;}];
    packages = [
      alejandra
      shfmt
      prettier
      prettier-plugin-toml
      yq
      git-subrepo
    ];
    devshell.startup.nodejs-setuphook = noDepEntry ''
      export NODE_PATH=${prettier-plugin-toml}/lib/node_modules:''${NODE_PATH-}
    '';
  };
in {
  checks = mkShell {
    imports = [formattingModule];
  };
  main = mkShell {
    name = "Cardano JS SDK Local Env";
    imports = [formattingModule];
    commands = [{package = std;}];
  };
}
