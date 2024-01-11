let
  inherit (inputs.nixpkgs) lib;
  inherit
    (inputs.nixpkgs)
    treefmt
    alejandra
    shfmt
    nodejs
    yq-go
    git-subrepo
    yarn
    ;
  inherit (inputs.std.lib.dev) mkShell;
  inherit (inputs.std.std.cli) std;

  inherit (lib.stringsWithDeps) noDepEntry;

  formattingModule = {
    commands = [{package = treefmt;}];
    packages = [
      alejandra
      shfmt
      nodejs
      yq-go
      git-subrepo
    ];
  };
in {
  checks = mkShell {
    imports = [formattingModule];
  };
  main = mkShell {
    name = "Cardano JS SDK Local Env";
    imports = [formattingModule];

    env = with inputs.nixpkgs; [
      {
        name = "LD_LIBRARY_PATH";
        value = lib.makeLibraryPath [udev];
      }
    ];

    commands = [
      {package = std;}
      {package = yarn;}
    ];
  };
}
