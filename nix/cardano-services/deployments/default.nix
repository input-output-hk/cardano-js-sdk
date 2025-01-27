# cSpell:ignore builtins cardanojs concat devs healthchecks hostnames kubeconfig pkgs stakepool stakepoolv
{
  pkgs,
  lib ? pkgs.lib,
  nix-toolbox,
  inputs,
}: let
  mkPodResources = memory: cpu: {inherit memory cpu;};
  baseUrl = "lw.iog.io";
  readJsonFile = path: builtins.fromJSON (builtins.readFile path);
  tf-outputs = {
    us-east-1 = readJsonFile ./tf-outputs/lace-dev-us-east-1.json;
    us-east-2 = readJsonFile ./tf-outputs/lace-prod-us-east-2.json;
    eu-central-1 = readJsonFile ./tf-outputs/lace-live-eu-central-1.json;
    eu-west-1 = readJsonFile ./tf-outputs/lace-dev-eu-west-1.json;
  };
  oci = inputs.self.x86_64-linux.cardano-services.oci-images.cardano-services;
  # cSpell:disable
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
  # cSpell:enable

  allowedOriginsDev =
    allowedOrigins
    ++ [
      "http://localhost/"
      "http://localhost"
    ];
in
  nix-toolbox.legacyPackages.${pkgs.system}.helm.mkHelm {
    defaults = final: let
      inherit (final) values;
    in {
      name = "${final.namespace}-cardanojs";
      chart = ./Chart.yaml;
      context = "eks-devs";
      kubeconfig = ../../local/kubeconfig + "/${final.region}";

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
          resources.requests = mkPodResources "350Mi" "1000m";
        };

        stake-pool-provider = {
          resources.requests = mkPodResources "150Mi" "700m";
          env.OVERRIDE_FUZZY_OPTIONS = builtins.toJSON (!(lib.hasPrefix "live" final.namespace));
        };

        handle-provider = {
          resources.requests = mkPodResources "150Mi" "700m";
        };

        asset-provider = {
          resources.requests = mkPodResources "512Mi" "1100m";
        };

        chain-history-provider = {
          resources.requests = mkPodResources "512Mi" "1000m";
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

        wallet-api = {
          resources.limits = mkPodResources "300Mi" "1000m";
          resources.requests = mkPodResources "150Mi" "100m";
        };

        asset = {
          resources.limits = mkPodResources "300Mi" "700m";
          resources.requests = mkPodResources "150Mi" "700m";
        };
      };

      values = {
        useAccelerator = false;
        acceleratorArn = tf-outputs.${final.region}.accelerators.${final.namespace} or null;
        postgresName = "${final.namespace}-postgresql";
        stakepool.databaseName = "stakepool";
        ingress.enabled = true;
        cardano-services = {
          nodeEnv =
            if lib.hasPrefix "live" final.namespace
            then "production"
            else null;
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

        ws-server = {
          enabled = false;
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
          # Healthcheck parameters for ALB
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
              (map (v: "/v${v}/network-info") versions.networkInfo)
              (map (v: "/v${v}/rewards") versions.rewards)
              (map (v: "/v${v}/tx-submit") versions.txSubmit)
              (map (v: "/v${v}/utxo") versions.utxo)
            ];
        };
      };
      imports = [
        ./ci.nix
        ./wallet-api.nix
        ./options.nix
        ./ws-server.deployment.nix
        ./provider.resource.nix
        ./projector.resource.nix
        ./backend.provider.nix
        ./stake-pool.nix
        ./chain-history.nix
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
              enabled = false;
            };
            stake-pool-provider = {
              enabled = true;
            };
            handle-provider.enabled = true;
            asset-provider.enabled = false;
            chain-history-provider.enabled = false;
          };

          projectors = {
            asset.enabled = false;
            handle.enabled = true;
            stake-pool.enabled = true;
            wallet-api.enabled = false;
          };

          values = {
            useAccelerator = true;
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

            # backend.allowedOrigins = lib.concatStringsSep "," allowedOriginsDev;

            blockfrost-worker.enabled = true;
            pg-boss-worker.enabled = false;
          };
        };

        "dev-mainnet@us-east-1" = final: {
          namespace = "dev-mainnet";
          network = "mainnet";
          region = "us-east-1";

          providers = {
            backend = {
              enabled = true;
              replicas = 2;
            };
            stake-pool-provider = {
              enabled = true;
            };
            handle-provider.enabled = true;
            #asset-provider.enabled = true;
            chain-history-provider = {
              enabled = true;
              replicas = 2;
            };
          };

          projectors = {
            asset.enabled = true;
            handle.enabled = true;
            stake-pool.enabled = true;
            # wallet-api.enabled = true;
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
              enabled = false;
            };
            stake-pool-provider = {
              enabled = true;
            };
            handle-provider.enabled = true;
            asset-provider.enabled = false;
            chain-history-provider.enabled = false;
          };

          projectors = {
            asset.enabled = false;
            handle.enabled = true;
            stake-pool.enabled = true;
            wallet-api.enabled = false;
          };

          values = {
            useAccelerator = true;
            stakepool.databaseName = "stakepoolv2";
            backend.allowedOrigins = lib.concatStringsSep "," allowedOriginsDev;

            pg-boss-worker.enabled = false;

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
            };
            handle-provider.enabled = true;
            asset-provider.enabled = true;
            chain-history-provider.enabled = true;
          };

          projectors = {
            asset.enabled = true;
            handle.enabled = true;
            stake-pool.enabled = true;
            wallet-api.enabled = true;
          };

          values = {
            stakepool.databaseName = "stakepoolv2";
            blockfrost-worker.enabled = true;
            pg-boss-worker.enabled = true;
            pg-boss-worker.metadata-fetch-mode = "direct";
            pg-boss-worker.queues = "pool-metadata,pool-metrics,pool-rewards";
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
              replicas = 4;
            };
            stake-pool-provider.enabled = true;
            handle-provider.enabled = true;
            chain-history-provider = {
              enabled = true;
              replicas = 2;
            };
            asset-provider.enabled = true;
          };

          projectors = {
            handle.enabled = true;
            stake-pool.enabled = true;
            asset.enabled = true;
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
              replicas = 4;
            };
            chain-history-provider = {
              enabled = true;
              replicas = 2;
            };
            stake-pool-provider.enabled = true;
            handle-provider.enabled = true;
            asset-provider.enabled = true;
          };

          projectors = {
            handle.enabled = true;
            stake-pool.enabled = true;
            asset.enabled = true;
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
            blockfrost-worker.enabled = true;
            pg-boss-worker.enabled = true;
          };
        };

        "staging-mainnet@us-east-1@v2" = final: {
          name = "${final.namespace}-cardanojs-v2";
          namespace = "staging-mainnet";
          context = "eks-devs";
          network = "mainnet";
          region = "us-east-1";

          providers = {
            backend = {
              enabled = true;
              replicas = 2;
            };
            stake-pool-provider = {
              enabled = true;
              env.OVERRIDE_FUZZY_OPTIONS = "true";
            };
            handle-provider.enabled = true;
            chain-history-provider = {
              enabled = true;
              replicas = 2;
            };
            asset-provider = {
              enabled = true;
            };
          };

          projectors = {
            asset.enabled = true;
            handle.enabled = true;
            stake-pool.enabled = true;
            wallet-api.enabled = true;
          };

          values = {
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
            backend.enabled = true;
            stake-pool-provider.enabled = true;
            handle-provider.enabled = true;
            chain-history-provider.enabled = true;
            asset-provider.enabled = true;
          };

          projectors = {
            handle.enabled = true;
            stake-pool.enabled = true;
            asset.enabled = true;
          };

          values = {
            stakepool.databaseName = "stakepoolv3";
            blockfrost-worker.enabled = true;
            pg-boss-worker.enabled = true;
            cardano-services = {
              ingresOrder = 98;
            };
          };
        };

        "live-preprod@eu-central-1@v2" = final: {
          name = "${final.namespace}-cardanojs-v2";
          namespace = "live-preprod";
          context = "eks-admin";
          network = "preprod";
          region = "eu-central-1";

          providers = {
            backend.enabled = true;
            stake-pool-provider.enabled = true;
            handle-provider. enabled = true;
            chain-history-provider.enabled = true;
            asset-provider.enabled = true;
          };

          projectors = {
            handle.enabled = true;
            stake-pool.enabled = true;
            asset.enabled = true;
          };

          values = {
            stakepool.databaseName = "stakepoolv3";
            blockfrost-worker.enabled = true;
            pg-boss-worker.enabled = true;
            cardano-services = {
              ingresOrder = 98;
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
            backend.enabled = true;
            stake-pool-provider.enabled = true;
            handle-provider.enabled = true;
            chain-history-provider.enabled = true;
            asset-provider.enabled = true;
          };

          projectors = {
            handle.enabled = true;
            stake-pool.enabled = true;
            asset.enabled = true;
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

        "live-preview@eu-central-1@v2" = final: {
          name = "${final.namespace}-cardanojs-v2";
          namespace = "live-preview";
          context = "eks-admin";
          network = "preview";
          region = "eu-central-1";

          providers = {
            backend.enabled = true;
            stake-pool-provider.enabled = true;
            handle-provider.enabled = true;
            chain-history-provider.enabled = true;
            asset-provider.enabled = true;
          };

          projectors = {
            handle.enabled = true;
            stake-pool.enabled = true;
            asset.enabled = true;
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

        "ops-preview-1@us-east-1" = final: {
          name = "${final.namespace}-cardanojs-v1";
          namespace = "ops-preview-1";
          network = "preview";
          region = "us-east-1";

          providers = {
            backend.enabled = false;
            handle-provider.enabled = true;
            chain-history-provider.enabled = false;
            stake-pool-provider.enabled = true;
          };

          projectors = {
            handle.enabled = true;
            stake-pool.enabled = true;
            wallet-api.enabled = false;
          };

          values = {
            pg-boss-worker.enabled = false;
            #pg-boss-worker.queues = "pool-delist-schedule,pool-metadata,pool-metrics,pool-rewards";
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
            useAccelerator = true;
            cardano-services = {
              ingresOrder = 99;
            };
          };
        };

        "local-network@us-east-1@v1" = final: {
          namespace = "local-network";
          name = "${final.namespace}-cardanojs-v1";
          network = "local";
          region = "us-east-1";

          providers = {
            backend = {
              enabled = true;
              env.USE_SUBMIT_API = "true";
              env.USE_BLOCKFROST = lib.mkForce "false";
              env.SUBMIT_API_URL = "http://${final.namespace}-cardano-core.${final.namespace}.svc.cluster.local:8090";
            };
            stake-pool-provider = {
              enabled = true;
            };
          };

          projectors = {
            stake-pool.enabled = true;
          };

          values = {
            blockfrost-worker.enabled = false;
            pg-boss-worker.enabled = true;

            backend.allowedOrigins = lib.concatStringsSep "," allowedOriginsDev;

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

      }
      # Convenient for cases when you need to create multiple temporary deployments with the same configuration
      // (builtins.mapAttrs (_: value: (final:
        value
        // {
          context = "eks-admin";
          projectors.asset.enabled = true;

          values = {
            ingress.enabled = false;
          };
        })) {
        #"live-mainnet@us-east-2@asset" = {
        #  name = "tmp-cardanojs";
        #  namespace = "live-mainnet";
        #  network = "mainnet";
        #  region = "us-east-2";
        #};
      });

    targetGroups = targets: {
      #ASSET = lib.filterAttrs (name: _: lib.hasSuffix "asset" name) targets;
      DEV = lib.filterAttrs (name: _: lib.hasPrefix "dev-" name) targets;
      LIVE = lib.filterAttrs (name: _: lib.hasPrefix "live-" name) targets;
      OPS = lib.filterAttrs (name: _: lib.hasPrefix "ops-" name) targets;
    };
  }
