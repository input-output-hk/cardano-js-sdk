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
  mkK9sCommand = region: {
    command = ''
      if [ -z "$K8S_USER" ]; then
        echo "To use this command you must set K8S_USER in $PRJ_ROOT/.access.local. See Readme."
      else
        ${k9s}/bin/k9s --kubeconfig $PRJ_ROOT/.kube/${region} $@
      fi
    '';
    name = "k9s-${region}";
    category = "direct access";
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
      (mkK9sCommand "us-east-1")
      (mkK9sCommand "us-east-2")
    ];

    devshell.startup.setup.text = ''
      [ -e $PRJ_ROOT/.envrc.local ] && source $PRJ_ROOT/.envrc.local
      kubectl config use-context $K8S_USER
      chmod 600 $PRJ_ROOT/.kube/*
    '';
  };
}
