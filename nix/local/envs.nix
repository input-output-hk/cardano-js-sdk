{
  lib,
  inputs,
  ...
}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: let
    mkK9sCommand = region: {
      command = ''
        if [ -z "$K8S_USER" ]; then
          echo "To use this command you must set K8S_USER in $PRJ_ROOT/.access.local. See Readme."
        else
          ${pkgs.k9s}/bin/k9s --kubeconfig $PRJ_ROOT/.kube/${region} $@
        fi
      '';
      name = "k9s-${region}";
      category = "direct access";
    };
  in {
    devshells.default = {
      name = "Cardano JS SDK Local Env";

      packages = with pkgs; [
        awscli2
        just
        kubectl
        netcat
        postgresql_14
        tmate
        alejandra
        git-subrepo
        nodejs
        shfmt
        yq-go
      ];

      env = with pkgs; [
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
        {package = pkgs.treefmt;}
        {package = inputs.std.packages.${system}.std;}
        {package = pkgs.yarn;}
        {package = pkgs.k9s;}
        (mkK9sCommand "us-east-1")
        (mkK9sCommand "us-east-2")
        (mkK9sCommand "eu-central-1")
      ];

      devshell.startup.setup.text = ''
        [ -e $PRJ_ROOT/.envrc.local ] && source $PRJ_ROOT/.envrc.local
        rm -rf $PRJ_ROOT/.kube
        cp -R $PRJ_ROOT/nix/local/kubeconfig $PRJ_ROOT/.kube
        chmod 600 $PRJ_ROOT/.kube/*
        kubectl config use-context $K8S_USER
        kubectl config use-context $K8S_USER --kubeconfig $PRJ_ROOT/.kube/us-east-2
        kubectl config use-context $K8S_USER --kubeconfig $PRJ_ROOT/.kube/eu-central-1
      '';
    };
  };
}
