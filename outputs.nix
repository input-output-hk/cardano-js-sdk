{
  std,
  self,
  nix-helm,
  ...
} @ inputs:
inputs.flake-parts.lib.mkFlake {inherit inputs;} {
  imports = with inputs; [
    std.flakeModule
    devshell.flakeModule
  ];
  systems = ["x86_64-linux" "aarch64-linux"];

  std.grow = {
    cellsFrom = ./nix;
    cellBlocks = with std.blockTypes; [
      # Software Delivery Lifecycle (Local Development Environment)
      (devshells "envs")
      (runnables "jobs")
      # Software Delivery Lifecycle (Packaging Layers)
      # For deeper context, please consult:
      #   https://std.divnix.com/patterns/four-packaging-layers.html
      (installables "packages" {ci.build = true;})
      (runnables "operables")
      (containers "oci-images" {ci.publish = true;})
    ];
  };

  std.harvest = {
    packages = [["local" "packages"] ["local" "jobs"]];
    devShells = [["local" "envs"] ["desktop" "envs"]];
    hydraJobs = ["desktop" "hydraJobs"];
  };

  perSystem = {
    pkgs,
    system,
    ...
  }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };

    legacyPackages.cardano-services = import ./nix/cardano-services/deployments {inherit pkgs nix-helm inputs;};

    devshells.default = {
      name = "cardano-js-sdk";

      env = [
        {
          name = "KUBECONFIG";
          eval = "$PRJ_ROOT/.kube/us-east-1";
        }
        {
          name = "TF_VAR_PRJ_ROOT";
          eval = "$PRJ_ROOT";
        }
      ];

      packages = with pkgs; [
        # Add packages that should be available in the devshell
      ];

      devshell.startup.source.text = ''
        source $PRJ_ROOT/.envrc.local
        kubectl config use-context $K8S_USER
        kubectl config use-context $K8S_USER --kubeconfig $PRJ_ROOT/.kube/us-east-2
        kubectl config use-context $K8S_USER --kubeconfig $PRJ_ROOT/.kube/eu-central-1
        chmod 600 $PRJ_ROOT/.kube/*
      '';

      commands = let
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
      in [
        {package = pkgs.jq;}
        {package = pkgs.treefmt;}
        {package = pkgs.just;}
        {package = pkgs.yq-go;}
        {
          package = pkgs.sops;
          name = "sops";
          category = "cloud";
        }
        {
          package = pkgs.awscli2;
          name = "aws";
          category = "cloud";
        }
        {
          package = pkgs.eksctl;
          category = "cloud";
        }
        {
          package = pkgs.k9s;
          category = "kubernetes";
        }
        {
          package = pkgs.kubectl;
          category = "kubernetes";
        }
        {
          package = pkgs.kubernetes-helm;
          category = "kubernetes";
        }
        (mkK9sCommand "us-east-1")
        (mkK9sCommand "us-east-2")
        (mkK9sCommand "eu-central-1")
      ];
    };
  };
}
