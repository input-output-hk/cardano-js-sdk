{
  pkgs,
  lib ? pkgs.lib,
  nix-helm,
  inputs,
}: let
  mkPodResources = memory: cpu: {inherit memory cpu;};
  baseUrl = "lw.iog.io";
  readJsonFile = path: builtins.fromJSON (builtins.readFile path);
  tf-outputs = {
    us-east-1 = readJsonFile ./tf-outputs/lace-dev-us-east-1.json;
    us-east-2 = readJsonFile ./tf-outputs/lace-prod-us-east-2.json;
    eu-central-1 = readJsonFile ./tf-outputs/lace-live-eu-central-1.json;
  };
  oci = inputs.self.x86_64-linux.cardano-services.oci-images.cardano-services;
  allowedOrigins = [
    # Represents Chrome production version
    "chrome-extension://gafhhkghbfjjkeiendhlofajokpaflmk"
    # Represents Edge production version
    "chrome-extension://efeiemlfnahiidnjglmehaihacglceia"
    # Represents midnights version of lace
    "chrome-extension://bjlhpephaokolembmpdcbobbpkjnoheb"
    # Represents Chrome dev preview version
    "chrome-extension://djcdfchkaijggdjokfomholkalbffgil"
  ];

  allowedOriginsDev =
    allowedOrigins
    ++ [
      "http://localhost/"
      "http://localhost"
    ];
in
  nix-helm.builders.${pkgs.system}.mkHelmMultiTarget {
    defaults = final: let
      inherit (final) values;
    in {
      name = "${final.namespace}-cardanojs";
      chart = ./Chart.yaml;
      context = "eks-devs";
      kubeconfig = "$PRJ_ROOT/.kube/${final.region}";

      utils = {
        mkPodEnv = lib.mapAttrsToList (
          name: value:
            if (builtins.isString value) || (builtins.isNull value)
            then lib.nameValuePair name value
            else if builtins.isAttrs value
            then value // {inherit name;}
            else throw "Environment variable value can be either string or attribute set"
        );

        appLabels = app: {
          inherit app;
          release = values.releaseName or final.name;
          network = final.network;
        };
      };

      providers = {
        backend = {
          resources.limits = mkPodResources "512Mi" "1500m";
          resources.requests = mkPodResources "350Mi" "1000m";
        };

        stake-pool-provider = {
          resources.limits = mkPodResources "300Mi" "500m";
          resources.requests = mkPodResources "150Mi" "100m";
        };

        handle-provider = {
          resources.limits = mkPodResources "300Mi" "500m";
          resources.requests = mkPodResources "150Mi" "100m";
        };

        asset-provider = {
          resources.limits = mkPodResources "300Mi" "500m";
          resources.requests = mkPodResources "150Mi" "100m";
        };
      };

      projectors = {
        stake-pool = {
          resources.limits = mkPodResources "300Mi" "700m";
          resources.requests = mkPodResources "150Mi" "700m";
        };

        handle = {
          resources.limits = mkPodResources "300Mi" "1000m";
          resources.requests = mkPodResources "150Mi" "100m";
        };

        asset = {
          resources.limits = mkPodResources "300Mi" "700m";
          resources.requests = mkPodResources "150Mi" "700m";
        };
      };

      values = {
        postgresName = "${final.namespace}-postgresql";
        stakepool.databaseName = "stakepool";
        ingress.enabled = true;
        cardano-services = {
          image = oci.image.name;
          buildInfo = oci.meta.buildInfo;
          versions = oci.meta.versions;
          httpPrefix = "/v${lib.last (lib.sort lib.versionOlder oci.meta.versions.root)}";

          loggingLevel = "info";
          tokenMetadataServerUrl = "http://${final.namespace}-cardano-stack-metadata.${final.namespace}.svc.cluster.local";
          ingresOrder = 0;
          certificateArn = tf-outputs.${final.region}.acm_arn;
          additionalRoutes = [];
        };

        blockfrost-worker = {
          enabled = false;
          resources.limits = mkPodResources "300Mi" "500m";
          resources.requests = mkPodResources "150Mi" "100m";
        };
        pg-boss-worker = {
          enabled = false;
          queues = "pool-delist-schedule,pool-metadata,pool-metrics,pool-rewards";
          metadata-fetch-mode = "smash";
          smash-url =
            if final.network == "mainnet"
            then "https://smash.cardano-mainnet.iohk.io/api/v1"
            else "https://${final.network}-smash.world.dev.cardano.org/api/v1";
          resources.limits = mkPodResources "300Mi" "300m";
          resources.requests = mkPodResources "150Mi" "200m";
        };

        backend = {
          allowedOrigins = lib.concatStringsSep "," allowedOrigins;
          passHandleDBArgs = true;
          hostnames = ["${final.namespace}.${baseUrl}" "${final.namespace}.${final.region}.${baseUrl}"];
          dnsId = lib.toLower "${final.region}-${final.namespace}-backend";
          ogmiosSrvServiceName = "${final.namespace}-cardano-core.${final.namespace}.svc.cluster.local";

          wafARN = tf-outputs.${final.region}.waf_arn;
          # Healthcheck paramteres for ALB
          # For mainnet, default value of timeout of 5 is too short, so have to increase it significantly
          # Interval cannot be less than timeout
          # Note that Kubernetes healthchecks are picked up by balancer controller and reflected in the target group anyway
          albHealthcheck = {
            interval = 60;
            timeout = 30;
          };
          routes = let
            inherit (oci.meta) versions;
          in
            lib.concatLists [
              (map (v: "/v${v}/health") versions.root)
              (map (v: "/v${v}/live") versions.root)
              (map (v: "/v${v}/meta") versions.root)
              (map (v: "/v${v}/ready") versions.root)
              (map (v: "/v${v}/asset") versions.assetInfo)
              (map (v: "/v${v}/chain-history") versions.chainHistory)
              (map (v: "/v${v}/network-info") versions.networkInfo)
              (map (v: "/v${v}/rewards") versions.rewards)
              (map (v: "/v${v}/tx-submit") versions.txSubmit)
              (map (v: "/v${v}/utxo") versions.utxo)
            ];
        };
      };
      imports = [
        ./options.nix
        ./provider.resource.nix
        ./projector.resource.nix
        ./backend.provider.nix
        ./stake-pool.nix
        ./handle.nix
        ./asset.nix
        ./backend-ingress.nix
        ./pg-boss-worker-deployment.nix
        ./blockfrost-worker-deployment.nix
      ];
    };

    targets =
      {
        "dev-preview@us-east-1" = final: {
          namespace = "dev-preview";
          network = "preview";
          region = "us-east-1";

          providers = {
            backend = {
              enabled = true;
            };
            stake-pool-provider = {
              enabled = true;
              env.OVERRIDE_FUZZY_OPTIONS = "true";
            };
            handle-provider.enabled = true;
          # asset-provider.enabled = true;
          };

          projectors = {
            handle.enabled = true;
            stake-pool.enabled = true;
            asset.enabled = true;
          };

          values = {
            stakepool.databaseName = "stakepoolv2";
            cardano-services = {
              ingresOrder = 99;
              additionalRoutes = [
                {
                  pathType = "Prefix";
                  path = "/v1.0.0/stake-pool";
                  backend.service = {
                    name = "${final.namespace}-cardanojs-stake-pool-provider";
                    port.name = "http";
                  };
                }
              ];
            };

            backend.allowedOrigins = lib.concatStringsSep "," allowedOriginsDev;

            blockfrost-worker.enabled = true;
            pg-boss-worker.enabled = true;
          };
        };

        "dev-sanchonet@us-east-1@v1" = final: {
          namespace = "dev-sanchonet";
          name = "${final.namespace}-cardanojs-v1";
          network = "sanchonet";
          region = "us-east-1";

          providers = {
            backend = {
              enabled = true;
              env.USE_SUBMIT_API = "true";
              env.USE_BLOCKFROST = lib.mkForce "false";
              env.SUBMIT_API_URL = "http://${final.namespace}-cardano-stack.${final.namespace}.svc.cluster.local:8090";
            };
            stake-pool-provider = {
              enabled = true;
              env.OVERRIDE_FUZZY_OPTIONS = "true";
            };
          };

          projectors = {
            stake-pool.enabled = true;
          };

          values = {
            blockfrost-worker.enabled = false;
            pg-boss-worker.enabled = true;

            backend.allowedOrigins = lib.concatStringsSep "," allowedOriginsDev;
            backend.routes = let
              inherit (oci.meta) versions;
            in
              lib.concatLists [
                (map (v: "/v${v}/health") versions.root)
                (map (v: "/v${v}/live") versions.root)
                (map (v: "/v${v}/meta") versions.root)
                (map (v: "/v${v}/ready") versions.root)
                (map (v: "/v${v}/asset") versions.assetInfo)
                (map (v: "/v${v}/chain-history") versions.chainHistory)
                (map (v: "/v${v}/network-info") versions.networkInfo)
                (map (v: "/v${v}/rewards") versions.rewards)
                (map (v: "/v${v}/tx-submit") versions.txSubmit)
                (map (v: "/v${v}/utxo") versions.utxo)
                (map (v: "/v${v}/handle") versions.handle)
                (map (v: "/v${v}/provider-server") versions.stakePool)
                (map (v: "/v${v}/stake-pool-provider-server") versions.stakePool)
              ];

            cardano-services = {
              ingresOrder = 99;
              additionalRoutes = [
                {
                  pathType = "Prefix";
                  path = "/v1.0.0/stake-pool";
                  backend.service = {
                    name = "${final.namespace}-cardanojs-v1-stake-pool-provider";
                    port.name = "http";
                  };
                }
                {
                  pathType = "Prefix";
                  path = "/v3.0.0/chain-history";
                  backend.service = {
                    name = "${final.namespace}-cardanojs-v1-backend";
                    port.name = "http";
                  };
                }
              ];
            };
          };
        };

        "dev-sanchonet@us-east-1@v2" = final: {
          name = "${final.namespace}-cardanojs-v2";
          namespace = "dev-sanchonet";
          network = "sanchonet";
          region = "us-east-1";

          projectors = {
            stake-pool.enabled = true;
          };

          providers = {
            backend = {
              enabled = true;
            };
            stake-pool-provider = {
              enabled = false;
            };
          };

          values = {
            ingress.enabled = false;
            pg-boss-worker.enabled = true;
            stakepool.databaseName = "stakepoolv2";
          };
        };

        "dev-mainnet@us-east-1" = final: {
          namespace = "dev-mainnet";
          network = "mainnet";
          region = "us-east-1";

          providers = {
            backend = {
              enabled = true;
              replicas = 3;
            };
            stake-pool-provider = {
              enabled = true;
              env.OVERRIDE_FUZZY_OPTIONS = "true";
            };
            handle-provider.enabled = true;
          # asset-provider.enabled = true;
          };

          projectors = {
            handle.enabled = true;
            stake-pool.enabled = true;
          # asset.enabled = true;
          };

          values = {
            cardano-services = {
              ingresOrder = 99;
              additionalRoutes = [
                {
                  pathType = "Prefix";
                  path = "/v1.0.0/stake-pool";
                  backend.service = {
                    name = "${final.namespace}-cardanojs-stake-pool-provider";
                    port.name = "http";
                  };
                }
              ];
            };
            backend.allowedOrigins = lib.concatStringsSep "," allowedOriginsDev;
            stakepool.databaseName = "stakepoolv2";

            blockfrost-worker.enabled = true;
            pg-boss-worker.enabled = true;
          };
        };

        "dev-preprod@us-east-1@v2" = final: {
          name = "${final.namespace}-cardanojs-v2";
          namespace = "dev-preprod";
          context = "eks-devs";
          network = "preprod";
          region = "us-east-1";

          providers = {
            backend = {
              enabled = true;
            };
            stake-pool-provider = {
              enabled = true;
              env.OVERRIDE_FUZZY_OPTIONS = "true";
            };
            handle-provider.enabled = true;
          # asset-provider.enabled = true;
          };

          projectors = {
            handle.enabled = true;
            stake-pool.enabled = true;
            asset.enabled = true;
          };

          values = {
            stakepool.databaseName = "stakepoolv2";
            backend.allowedOrigins = lib.concatStringsSep "," allowedOriginsDev;

            pg-boss-worker.enabled = true;

            blockfrost-worker.enabled = true;
            cardano-services = {
              ingresOrder = 98;
            };
          };
        };

        "staging-preprod@us-east-1@v2" = final: {
          name = "${final.namespace}-cardanojs-v2";
          namespace = "staging-preprod";
          context = "eks-devs";
          network = "preprod";
          region = "us-east-1";

          providers = {
            backend = {
              enabled = true;
            };
            stake-pool-provider = {
              enabled = true;
              env.OVERRIDE_FUZZY_OPTIONS = "true";
            };
            handle-provider.enabled = true;
            # asset-provider.enabled = true;
          };

          projectors = {
            handle.enabled = true;
            stake-pool.enabled = true;
            # asset.enabled = true;
          };

          values = {
            stakepool.databaseName = "stakepoolv2";
            blockfrost-worker.enabled = true;
            pg-boss-worker.enabled = true;
            cardano-services = {
              ingresOrder = 98;
            };
          };
        };

        "live-mainnet@us-east-2@v2" = final: {
          name = "${final.namespace}-cardanojs-v2";
          namespace = "live-mainnet";
          context = "eks-admin";
          network = "mainnet";
          region = "us-east-2";

          providers = {
            backend = {
              enabled = true;
              replicas = 3;
              env.NODE_ENV = "production";
            };
            stake-pool-provider = {
              enabled = true;
              env.OVERRIDE_FUZZY_OPTIONS = "true";
              env.NODE_ENV = "production";
            };
            handle-provider.enabled = true;
            # asset-provider = {
            #   enabled = true;
            #   env.NODE_ENV = "production";
            # };
          };

          projectors = {
            handle.enabled = true;
            stake-pool = {
              enabled = true;
            };
            # asset.enabled = true;
          };

          values = {
            stakepool.databaseName = "stakepoolv3";
            cardano-services = {
              ingresOrder = 98;
              additionalRoutes = [
                {
                  pathType = "Prefix";
                  path = "/v1.0.0/stake-pool";
                  backend.service = {
                    name = "${final.namespace}-cardanojs-stake-pool-provider";
                    port.name = "http";
                  };
                }
              ];
            };
            backend.allowedOrigins = lib.concatStringsSep "," allowedOrigins;
            backend.routes = let
              inherit (oci.meta) versions;
            in
              lib.concatLists [
                (map (v: "/v${v}/health") versions.root)
                (map (v: "/v${v}/live") versions.root)
                (map (v: "/v${v}/meta") versions.root)
                (map (v: "/v${v}/ready") versions.root)
                (map (v: "/v${v}/asset") versions.assetInfo)
                (map (v: "/v${v}/chain-history") versions.chainHistory)
                (map (v: "/v${v}/network-info") versions.networkInfo)
                (map (v: "/v${v}/rewards") versions.rewards)
                (map (v: "/v${v}/tx-submit") versions.txSubmit)
                (map (v: "/v${v}/utxo") versions.utxo)
                (map (v: "/v${v}/handle") versions.handle)
              ];

            blockfrost-worker.enabled = true;
            pg-boss-worker.enabled = true;
          };
        };

        "live-mainnet@eu-central-1@v2" = final: {
          name = "${final.namespace}-cardanojs-v2";
          namespace = "live-mainnet";
          context = "eks-admin";
          network = "mainnet";
          region = "eu-central-1";

          providers = {
            backend = {
              enabled = true;
              replicas = 3;
              env.NODE_ENV = "production";
            };
            stake-pool-provider = {
              enabled = true;
              env.OVERRIDE_FUZZY_OPTIONS = "true";
              env.NODE_ENV = "production";
            };
            handle-provider.enabled = true;
            #asset-provider = {
            #  enabled = true;
            #  env.NODE_ENV = "production";
            #};
          };

          projectors = {
            handle.enabled = true;
            stake-pool.enabled = true;
            # asset.enabled = true;
          };

          values = {
            stakepool.databaseName = "stakepoolv3";

            cardano-services = {
              ingresOrder = 98;
              additionalRoutes = [
                {
                  pathType = "Prefix";
                  path = "/v1.0.0/stake-pool";
                  backend.service = {
                    name = "${final.namespace}-cardanojs-stake-pool-provider";
                    port.name = "http";
                  };
                }
              ];
            };
            backend.allowedOrigins = lib.concatStringsSep "," allowedOrigins;
            backend.routes = let
              inherit (oci.meta) versions;
            in
              lib.concatLists [
                (map (v: "/v${v}/health") versions.root)
                (map (v: "/v${v}/live") versions.root)
                (map (v: "/v${v}/meta") versions.root)
                (map (v: "/v${v}/ready") versions.root)
                (map (v: "/v${v}/asset") versions.assetInfo)
                (map (v: "/v${v}/chain-history") versions.chainHistory)
                (map (v: "/v${v}/network-info") versions.networkInfo)
                (map (v: "/v${v}/rewards") versions.rewards)
                (map (v: "/v${v}/tx-submit") versions.txSubmit)
                (map (v: "/v${v}/utxo") versions.utxo)
                (map (v: "/v${v}/handle") versions.handle)
              ];

            blockfrost-worker.enabled = true;
            pg-boss-worker.enabled = true;
          };
        };

        "live-preprod@us-east-2@v2" = final: {
          name = "${final.namespace}-cardanojs-v2";
          namespace = "live-preprod";
          context = "eks-admin";
          network = "preprod";
          region = "us-east-2";

          providers = {
            backend = {
              enabled = true;
              env.NODE_ENV = "production";
            };
            stake-pool-provider = {
              enabled = true;
              env.OVERRIDE_FUZZY_OPTIONS = "true";
              env.NODE_ENV = "production";
            };
            handle-provider = {
              enabled = true;
              env.NODE_ENV = "production";
            };
            #asset-provider = {
            #  enabled = true;
            #  env.NODE_ENV = "production";
            #};
          };

          projectors = {
            handle.enabled = true;
            stake-pool = {
              enabled = true;
            };
            # asset.enabled = true;
          };

          values = {
            stakepool.databaseName = "stakepoolv3";
            blockfrost-worker.enabled = true;
            pg-boss-worker.enabled = true;
            cardano-services = {
              ingresOrder = 98;
            };
            backend.routes = let
              inherit (oci.meta) versions;
            in
              lib.concatLists [
                (map (v: "/v${v}/health") versions.root)
                (map (v: "/v${v}/live") versions.root)
                (map (v: "/v${v}/meta") versions.root)
                (map (v: "/v${v}/ready") versions.root)
                (map (v: "/v${v}/asset") versions.assetInfo)
                (map (v: "/v${v}/chain-history") versions.chainHistory)
                (map (v: "/v${v}/network-info") versions.networkInfo)
                (map (v: "/v${v}/rewards") versions.rewards)
                (map (v: "/v${v}/tx-submit") versions.txSubmit)
                (map (v: "/v${v}/utxo") versions.utxo)
                (map (v: "/v${v}/handle") versions.handle)
              ];
          };
        };

        "live-preprod@eu-central-1@v2" = final: {
          name = "${final.namespace}-cardanojs-v2";
          namespace = "live-preprod";
          context = "eks-admin";
          network = "preprod";
          region = "eu-central-1";

          providers = {
            backend = {
              enabled = true;
              env.NODE_ENV = "production";
            };
            stake-pool-provider = {
              enabled = true;
              env.OVERRIDE_FUZZY_OPTIONS = "true";
              env.NODE_ENV = "production";
            };
            handle-provider = {
              enabled = true;
              env.NODE_ENV = "production";
            };
            #asset-provider = {
            #  enabled = true;
            #  env.NODE_ENV = "production";
            #};
          };

          projectors = {
            handle.enabled = true;
            stake-pool = {
              enabled = true;
            };
            # asset.enabled = true;
          };

          values = {
            stakepool.databaseName = "stakepoolv3";
            blockfrost-worker.enabled = true;
            pg-boss-worker.enabled = true;
            cardano-services = {
              ingresOrder = 98;
            };
            backend.routes = let
              inherit (oci.meta) versions;
            in
              lib.concatLists [
                (map (v: "/v${v}/health") versions.root)
                (map (v: "/v${v}/live") versions.root)
                (map (v: "/v${v}/meta") versions.root)
                (map (v: "/v${v}/ready") versions.root)
                (map (v: "/v${v}/asset") versions.assetInfo)
                (map (v: "/v${v}/chain-history") versions.chainHistory)
                (map (v: "/v${v}/network-info") versions.networkInfo)
                (map (v: "/v${v}/rewards") versions.rewards)
                (map (v: "/v${v}/tx-submit") versions.txSubmit)
                (map (v: "/v${v}/utxo") versions.utxo)
                (map (v: "/v${v}/handle") versions.handle)
              ];
          };
        };

        "live-preview@us-east-2@v1" = final: {
          name = "${final.namespace}-cardanojs-v1";
          namespace = "live-preview";
          context = "eks-admin";
          network = "preview";
          region = "us-east-2";

          providers = {
            backend = {
              enabled = true;
              env.NODE_ENV = "production";
            };
          };

          values = {
            backend.hostnames = ["backend.${final.namespace}.eks.${baseUrl}" "${final.namespace}.${baseUrl}"];
            backend.passHandleDBArgs = false;
            backend.routes = [
              "/v1.0.0/health"
              "/v1.0.0/live"
              "/v1.0.0/meta"
              "/v1.0.0/ready"
              "/v1.0.0/asset"
              "/v2.0.0/chain-history"
              "/v1.0.0/handle"
              "/v1.0.0/network-info"
              "/v1.0.0/rewards"
              "/v1.0.0/stake-pool"
              "/v2.0.0/tx-submit"
              "/v2.0.0/utxo"
            ];
            # blockfrost-worker.enabled = true;
            cardano-services = {
              ingresOrder = 99;
              image = "926093910549.dkr.ecr.us-east-1.amazonaws.com/cardano-services:s8j5nx9x2naar194pr58kpmlr5s4xn7b";
            };
          };
        };

        "live-preview@us-east-2@v2" = final: {
          name = "${final.namespace}-cardanojs-v2";
          namespace = "live-preview";
          context = "eks-admin";
          network = "preview";
          region = "us-east-2";

          providers = {
            backend = {
              enabled = true;
              env.NODE_ENV = "production";
            };
            stake-pool-provider = {
              enabled = true;
              env.OVERRIDE_FUZZY_OPTIONS = "true";
              env.NODE_ENV = "production";
            };
            handle-provider = {
              enabled = true;
              env.NODE_ENV = "production";
            };
            #asset-provider = {
            #  enabled = true;
            #  env.NODE_ENV = "production";
            #};
          };

          projectors = {
            handle.enabled = true;
            stake-pool = {
              enabled = true;
            };
            # asset.enabled = true;
          };

          values = {
            stakepool.databaseName = "stakepoolv3";
            blockfrost-worker.enabled = true;
            pg-boss-worker.enabled = true;
            cardano-services = {
              ingresOrder = 98;
            };
            backend.routes = let
              inherit (oci.meta) versions;
            in
              lib.concatLists [
                (map (v: "/v${v}/health") versions.root)
                (map (v: "/v${v}/live") versions.root)
                (map (v: "/v${v}/meta") versions.root)
                (map (v: "/v${v}/ready") versions.root)
                (map (v: "/v${v}/asset") versions.assetInfo)
                (map (v: "/v${v}/chain-history") versions.chainHistory)
                (map (v: "/v${v}/network-info") versions.networkInfo)
                (map (v: "/v${v}/rewards") versions.rewards)
                (map (v: "/v${v}/tx-submit") versions.txSubmit)
                (map (v: "/v${v}/utxo") versions.utxo)
                (map (v: "/v${v}/handle") versions.handle)
              ];
          };
        };

        "live-preview@eu-central-1@v1" = final: {
          name = "${final.namespace}-cardanojs-v1";
          namespace = "live-preview";
          context = "eks-admin";
          network = "preview";
          region = "eu-central-1";

          providers = {
            backend = {
              enabled = true;
              env.NODE_ENV = "production";
            };
          };

          values = {
            backend.hostnames = ["backend.${final.namespace}.eks.${baseUrl}" "${final.namespace}.${baseUrl}"];
            backend.passHandleDBArgs = false;
            backend.routes = [
              "/v1.0.0/health"
              "/v1.0.0/live"
              "/v1.0.0/meta"
              "/v1.0.0/ready"
              "/v1.0.0/asset"
              "/v2.0.0/chain-history"
              "/v1.0.0/handle"
              "/v1.0.0/network-info"
              "/v1.0.0/rewards"
              "/v1.0.0/stake-pool"
              "/v2.0.0/tx-submit"
              "/v2.0.0/utxo"
            ];
            # blockfrost-worker.enabled = true;
            cardano-services = {
              ingresOrder = 99;
              image = "926093910549.dkr.ecr.us-east-1.amazonaws.com/cardano-services:s8j5nx9x2naar194pr58kpmlr5s4xn7b";
            };
          };
        };

        "live-preview@eu-central-1@v2" = final: {
          name = "${final.namespace}-cardanojs-v2";
          namespace = "live-preview";
          context = "eks-admin";
          network = "preview";
          region = "eu-central-1";

          providers = {
            backend = {
              enabled = true;
              env.NODE_ENV = "production";
            };
            stake-pool-provider = {
              enabled = true;
              env.OVERRIDE_FUZZY_OPTIONS = "true";
              env.NODE_ENV = "production";
            };
            handle-provider = {
              enabled = true;
              env.NODE_ENV = "production";
            };
            # asset-provider = {
            #   enabled = true;
            #   env.NODE_ENV = "production";
            # };
          };

          projectors = {
            handle.enabled = true;
            stake-pool = {
              enabled = true;
            };
            # asset.enabled = true;
          };

          values = {
            stakepool.databaseName = "stakepoolv3";
            blockfrost-worker.enabled = true;
            pg-boss-worker.enabled = true;
            cardano-services = {
              ingresOrder = 98;
            };
            backend.routes = let
              inherit (oci.meta) versions;
            in
              lib.concatLists [
                (map (v: "/v${v}/health") versions.root)
                (map (v: "/v${v}/live") versions.root)
                (map (v: "/v${v}/meta") versions.root)
                (map (v: "/v${v}/ready") versions.root)
                (map (v: "/v${v}/asset") versions.assetInfo)
                (map (v: "/v${v}/chain-history") versions.chainHistory)
                (map (v: "/v${v}/network-info") versions.networkInfo)
                (map (v: "/v${v}/rewards") versions.rewards)
                (map (v: "/v${v}/tx-submit") versions.txSubmit)
                (map (v: "/v${v}/utxo") versions.utxo)
                (map (v: "/v${v}/handle") versions.handle)
              ];
          };
        };

        "ops-preview-1@us-east-1" = final: {
          namespace = "ops-preview-1";
          network = "preview";
          region = "us-east-1";

          providers = {
            backend = {
              enabled = true;
            };
          };

          values = {
            stakepool.databaseName = "stakepoolv2";
            cardano-services = {
              ingresOrder = 99;
            };
          };
        };

        "ops-preprod-1@us-east-1" = final: {
          namespace = "ops-preprod-1";
          network = "preprod";
          region = "us-east-1";

          providers = {
            backend = {
              enabled = true;
            };
          };

          values = {
            cardano-services = {
              ingresOrder = 99;
            };
          };
        };

        "live-sanchonet@us-east-2@v1" = final: {
          namespace = "live-sanchonet";
          name = "${final.namespace}-cardanojs-v1";
          network = "sanchonet";
          region = "us-east-2";

          providers = {
            backend = {
              enabled = true;
              env.USE_SUBMIT_API = "true";
              env.USE_BLOCKFROST = lib.mkForce "false";
              env.SUBMIT_API_URL = "http://${final.namespace}-cardano-stack.${final.namespace}.svc.cluster.local:8090";
              env.NODE_ENV = "production";
            };
            stake-pool-provider.enabled = true;
          };

          projectors = {
            stake-pool = {
              enabled = true;
              env.PROJECTION_NAMES = lib.mkForce "stake-pool,stake-pool-metadata-job,stake-pool-metrics-job";
            };
          };

          values = {
            blockfrost-worker.enabled = false;
            pg-boss-worker.enabled = true;
            pg-boss-worker.queues = "pool-metadata,pool-metrics";
            backend.routes = let
              inherit (oci.meta) versions;
            in
              lib.concatLists [
                (map (v: "/v${v}/health") versions.root)
                (map (v: "/v${v}/live") versions.root)
                (map (v: "/v${v}/meta") versions.root)
                (map (v: "/v${v}/ready") versions.root)
                (map (v: "/v${v}/asset") versions.assetInfo)
                (map (v: "/v${v}/chain-history") versions.chainHistory)
                (map (v: "/v${v}/network-info") versions.networkInfo)
                (map (v: "/v${v}/rewards") versions.rewards)
                (map (v: "/v${v}/tx-submit") versions.txSubmit)
                (map (v: "/v${v}/utxo") versions.utxo)
                (map (v: "/v${v}/handle") versions.handle)
                (map (v: "/v${v}/provider-server") versions.stakePool)
                (map (v: "/v${v}/stake-pool-provider-server") versions.stakePool)
              ];

            cardano-services = {
              ingresOrder = 99;
              additionalRoutes = [
                {
                  pathType = "Prefix";
                  path = "/v1.0.0/stake-pool";
                  backend.service = {
                    name = "${final.namespace}-cardanojs-v1-stake-pool-provider";
                    port.name = "http";
                  };
                }
                {
                  pathType = "Prefix";
                  path = "/v3.0.0/chain-history";
                  backend.service = {
                    name = "${final.namespace}-cardanojs-v1-backend";
                    port.name = "http";
                  };
                }
              ];
            };
          };
        };

        "live-sanchonet@us-east-2@v2" = final: {
          name = "${final.namespace}-cardanojs-v2";
          namespace = "live-sanchonet";
          network = "sanchonet";
          region = "us-east-2";
          context = "eks-admin";

          projectors = {
            stake-pool.enabled = true;
          };

          providers = {
            backend = {
              enabled = true;
            };
            stake-pool-provider = {
              enabled = false;
            };
          };

          values = {
            ingress.enabled = false;
            pg-boss-worker.enabled = true;
            stakepool.databaseName = "stakepoolv2";
          };
        };

        "live-sanchonet@eu-central-1@v2" = final: {
          name = "${final.namespace}-cardanojs-v2";
          namespace = "live-sanchonet";
          network = "sanchonet";
          region = "eu-central-1";
          context = "eks-admin";

          projectors = {
            stake-pool = {
              enabled = true;
              env.PROJECTION_NAMES = lib.mkForce "stake-pool,stake-pool-metadata-job,stake-pool-metrics-job";
            };
          };

          providers = {
            backend = {
              enabled = true;
            };
            stake-pool-provider = {
              enabled = false;
            };
          };

          values = {
            ingress.enabled = false;
            pg-boss-worker.enabled = true;
            stakepool.databaseName = "stakepoolv2";
          };
        };
      }
      # Convenient for cases when you need to create multiple temporary deployments with the same configuration
      // (builtins.mapAttrs (_: value: (final:
        value
        // {
          projectors = {
            stake-pool.enabled = true;
          };

          providers = {
            backend = {
              enabled = true;
            };
          };

          values = {
            stakepool.databaseName = "stakepoolv3";
            ingress.enabled = false;
            pg-boss-worker.enabled = true;
          };
        })) {
        #"live-preview@us-east-2@tmp" = {
        #  name = "tmp-cardanojs";
        #  namespace = "live-preview";
        #  network = "preview";
        #  region = "us-east-2";
        #  context = "eks-admin";
        #};
      });

    targetGroups = targets: {
      DEV = lib.filterAttrs (name: _: lib.hasPrefix "dev-" name) targets;
      LIVE = lib.filterAttrs (name: _: lib.hasPrefix "live-" name) targets;
      OPS = lib.filterAttrs (name: _: lib.hasPrefix "ops-" name) targets;
    };
  }
