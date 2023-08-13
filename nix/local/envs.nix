let
  inherit (inputs.nixpkgs) lib;
  inherit
    (inputs.nixpkgs)
    treefmt
    alejandra
    shfmt
    yq-go
    git-subrepo
    yarn
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
      yq-go
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
    packages = [
      git-subrepo
      yarn
    ];
  };
}
