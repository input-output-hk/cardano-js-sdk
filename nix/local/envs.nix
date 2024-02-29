let
  inherit (inputs.nixpkgs) lib;
  inherit
    (inputs.nixpkgs)
    alejandra
    git-subrepo
    k9s
    nodejs
    shfmt
    treefmt
    yarn
    yq-go
    ;
  inherit (inputs.std.lib.dev) mkShell;
  inherit (inputs.std.std.cli) std;

  inherit (lib.stringsWithDeps) noDepEntry;

  formattingModule = {
    commands = [{package = treefmt;}];
    packages = [
      alejandra
      git-subrepo
      nodejs
      shfmt
      yq-go
    ];
  };
in {
  checks = mkShell {
    imports = [formattingModule];
  };
  main = mkShell {
    name = "Cardano JS SDK Local Env";
    imports = [formattingModule];

    packages = with inputs.nixpkgs; [
      awscli2
      kubectl
    ];

    env = with inputs.nixpkgs; [
      {
        name = "LD_LIBRARY_PATH";
        value = lib.makeLibraryPath [udev];
      }
      {
        name = "KUBECONFIG";
        eval = "$PRJ_ROOT/.kube/us-east-1";
      }
    ];

    commands = [
      {package = std;}
      {package = yarn;}
      {package = k9s;}
    ];

    devshell.startup.setup.text = ''
      source $PRJ_ROOT/.envrc.local
      kubectl config use-context $K8S_USER
      chmod 600 $PRJ_ROOT/.kube/*
    '';
  };
}
