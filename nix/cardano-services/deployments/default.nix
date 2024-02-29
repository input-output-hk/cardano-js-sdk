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
  };
in
  nix-helm.builders.${pkgs.system}.mkHelmMultiTarget {
    defaults = final: let
      inherit (final) values;
    in {
      name = "${final.namespace}-cardanojs";
      chart = ./Chart.yaml;
      context = "eks-devs";
      kubeconfig = "$PRJ_ROOT/.kube/${values.region}";

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
          network = values.network;
        };
      };

      providers = {
        backend = {
          resources.limits = mkPodResources "512Mi" "1500m";
          resources.requests = mkPodResources "350Mi" "1000m";

          env.DISABLE_STAKE_POOL_METRIC_APY = "true";
          env.PAGINATION_PAGE_SIZE_LIMIT = "5500";
          env.USE_BLOCKFROST = "true";
          env.HANDLE_PROVIDER_SERVER_URL =
            if values.network == "mainnet"
            then "https://api.handle.me"
            else "https://${values.network}.api.handle.me";
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
          resources.limits = mkPodResources "300Mi" "500m";
          resources.requests = mkPodResources "150Mi" "100m";
        };

        asset = {
          resources.limits = mkPodResources "300Mi" "700m";
          resources.requests = mkPodResources "150Mi" "700m";
        };
      };

      values = {
        postgresName = "${final.namespace}-postgresql";
        cardano-services = {
          image = null;
          buildInfo = null;
          loggingLevel = "debug";
          tokenMetadataServerUrl = "http://${final.namespace}-cardano-stack-metadata.${final.namespace}.svc.cluster.local";
          httpPrefix = "";
          ingresOrder = 0;
          certificateArn = tf-outputs.${values.region}.acm_arn;
          additionalRoutes = [];
        };

        blockfrost-worker = {
          enabled = false;
          resources.limits = mkPodResources "300Mi" "500m";
          resources.requests = mkPodResources "150Mi" "100m";
        };

        pg-boss-worker = {
          enabled = false;
          metadata-fetch-mode = "direct";
          resources.limits = mkPodResources "300Mi" "300m";
          resources.requests = mkPodResources "150Mi" "200m";
        };

        backend = {
          routes = ["/"];
          allowedOrigins = lib.concatStringsSep "," [
            # gafhhkghbfjjkeiendhlofajokpaflmk represents Chrome production version
            "chrome-extension://gafhhkghbfjjkeiendhlofajokpaflmk"
            # efeiemlfnahiidnjglmehaihacglceia represents Edge production version
            "chrome-extension://efeiemlfnahiidnjglmehaihacglceia"
            # bjlhpephaokolembmpdcbobbpkjnoheb represents midnights version of lace
            "chrome-extension://bjlhpephaokolembmpdcbobbpkjnoheb"
            # djcdfchkaijggdjokfomholkalbffgil represents Chrome dev preview version
            "chrome-extension://djcdfchkaijggdjokfomholkalbffgil"
          ];
          url = "${final.namespace}.${baseUrl}";
          dnsId = lib.toLower "${values.region}-${final.namespace}-backend";
          ogmiosSrvServiceName = "${final.namespace}-cardano-stack.${final.namespace}.svc.cluster.local";

          wafARN = tf-outputs.${values.region}.waf_arn;
          # Healthcheck paramteres for ALB
          # For mainnet, default value of timeout of 5 is too short, so have to increase it significantly
          # Interval cannot be less than timeout
          # Note that Kubernetes healthchecks are picked up by balancer controller and reflected in the target group anyway
          albHealthcheck = {
            interval = 60;
            timeout = 30;
          };
        };
      };
      imports = [
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

    targets = {
      "dev-sanchonet@us-east-1@v1" = final: let
        oci = inputs.self.x86_64-linux.cardano-services.oci-images.cardano-services;
      in {
        namespace = "dev-sanchonet";

        providers = {
          backend = {
            enabled = true;
            env.HANDLE_POLICY_IDS = "f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a";
            env.USE_KORA_LABS = "true";
            env.USE_SUBMIT_API = "true";
            env.USE_BLOCKFROST = "false";
            env.SUBMIT_API_URL = "http://${final.namespace}-cardano-stack.${final.namespace}.svc.cluster.local:8090";
          };
          stake-pool-provider.enabled = true;
        };

        projectors = {
          stake-pool.enabled = true;
        };

        values = {
          network = "sanchonet-1";
          region = "us-east-1";

          name = "${final.namespace}-cardanojs-v1";
          blockfrost-worker.enabled = false;
          pg-boss-worker.enabled = true;

          cardano-services = {
            ingresOrder = 99;
            image = oci.image.name;
            versions = oci.meta.versions;
            httpPrefix = "/v${oci.meta.versions.root}";
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

          backend = {
            routes = let
              inherit (oci.meta) versions;
            in [
              "/v${versions.root}/health"
              "/v${versions.root}/live"
              "/v${versions.root}/meta"
              "/v${versions.root}/ready"
              "/v${versions.assetInfo}/asset"
              "/v${versions.chainHistory}/chain-history"
              "/v${versions.handle}/handle"
              "/v${versions.networkInfo}/network-info"
              "/v${versions.rewards}/rewards"
              "/v${versions.stakePool}/provider-server"
              "/v${versions.stakePool}/stake-pool-provider-server"
              "/v${versions.txSubmit}/tx-submit"
              "/v${versions.utxo}/utxo"
            ];
          };
        };
      };

      "dev-mainnet@us-east-1" = final: let
        oci = inputs.self.x86_64-linux.cardano-services.oci-images.cardano-services;
      in {
        namespace = "dev-mainnet";

        providers = {
          backend = {
            enabled = true;
            replicas = 3;
            env.HANDLE_POLICY_IDS = "f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a";
            env.USE_BLOCKFROST = "true";
            env.USE_KORA_LABS = "true";
          };
          stake-pool-provider.enabled = true;
          handle-provider.enabled = true;
          # asset-provider.enabled = true;
        };

        projectors = {
          handle.enabled = true;
          stake-pool.enabled = true;
          # asset.enabled = true;
        };

        values = {
          network = "mainnet";
          region = "us-east-1";
          cardano-services = {
            ingresOrder = 99;
            image = oci.image.name;
            buildInfo = oci.meta.buildInfo;
            versions = oci.meta.versions;
            httpPrefix = "/v${oci.meta.versions.root}";
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

          pg-boss-worker.metadata-fetch-mode = "smash";

          backend = {
            routes = let
              inherit (oci.meta) versions;
            in [
              "/v${versions.root}/health"
              "/v${versions.root}/live"
              "/v${versions.root}/meta"
              "/v${versions.root}/ready"
              "/v${versions.assetInfo}/asset"
              "/v${versions.chainHistory}/chain-history"
              "/v${versions.networkInfo}/network-info"
              "/v${versions.rewards}/rewards"
              "/v${versions.txSubmit}/tx-submit"
              "/v${versions.utxo}/utxo"
            ];
          };

          blockfrost-worker.enabled = true;
          pg-boss-worker.enabled = true;
        };
      };

      "dev-preprod@us-east-1" = final: {
        namespace = "dev-preprod";

        providers = {
          backend = {
            enabled = true;
            env.HANDLE_POLICY_IDS = "f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a";
            env.USE_BLOCKFROST = "false";
            env.USE_KORA_LABS = "true";
          };
        };

        values = {
          network = "preprod";
          region = "us-east-1";

          cardano-services = {
            ingresOrder = 100;
            image = inputs.self.x86_64-linux.cardano-services.oci-images.cardano-services.image.name;
          };

          backend = {
            env.HANDLE_POLICY_IDS = "f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a";
            env.USE_BLOCKFROST = "false";
            env.USE_KORA_LABS = "true";
          };
        };
      };

      "dev-preprod@us-east-1@v1" = final: let
        oci = inputs.self.x86_64-linux.cardano-services.oci-images.cardano-services;
      in {
        name = "${final.namespace}-cardanojs-v1";
        namespace = "dev-preprod";

        providers = {
          backend = {
            enabled = true;
            env.HANDLE_POLICY_IDS = "f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a";
            env.USE_BLOCKFROST = "false";
            env.USE_KORA_LABS = "true";
          };
          stake-pool-provider.enabled = true;
          handle-provider.enabled = true;
        };

        projectors = {
          handle.enabled = true;
          stake-pool.enabled = true;
        };

        values = {
          network = "preprod";
          region = "us-east-1";

          blockfrost-worker.enabled = true;
          pg-boss-worker.enabled = true;

          cardano-services = {
            ingresOrder = 99;
            image = oci.image.name;
            buildInfo = oci.meta.buildInfo;
            versions = oci.meta.versions;
            httpPrefix = "/v${oci.meta.versions.root}";
            additionalRoutes = [
              {
                pathType = "Prefix";
                path = "/v1.0.0/stake-pool";
                backend.service = {
                  name = "${final.namespace}-cardanojs-v1-stake-pool-provider";
                  port.name = "http";
                };
              }
            ];
          };

          backend = {
            routes = let
              inherit (oci.meta) versions;
            in [
              "/v${versions.root}/health"
              "/v${versions.root}/live"
              "/v${versions.root}/meta"
              "/v${versions.root}/ready"
              "/v${versions.assetInfo}/asset"
              "/v${versions.chainHistory}/chain-history"
              "/v${versions.networkInfo}/network-info"
              "/v${versions.rewards}/rewards"
              "/v${versions.txSubmit}/tx-submit"
              "/v${versions.utxo}/utxo"
            ];
          };
        };
      };

      "ops-preview-1@us-east-1" = final: let
        oci = inputs.self.x86_64-linux.cardano-services.oci-images.cardano-services;
      in {
        namespace = "ops-preview-1";

        providers = {
          backend = {
            enabled = true;
            env.HANDLE_POLICY_IDS = "f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a";
            env.USE_KORA_LABS = "true";
          };
        };

        values = {
          network = "preview";
          region = "us-east-1";
          cardano-services = {
            ingresOrder = 99;
            image = oci.image.name;
            buildInfo = oci.meta.buildInfo;
            versions = oci.meta.versions;
            httpPrefix = "/v${oci.meta.versions.root}";
          };
        };
      };

      "ops-preprod-1@us-east-1" = final: let
        oci = inputs.self.x86_64-linux.cardano-services.oci-images.cardano-services;
      in {
        namespace = "ops-preprod-1";

        providers = {
          backend = {
            enabled = true;
            env.HANDLE_POLICY_IDS = "f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a";
            env.USE_KORA_LABS = "true";
          };
        };

        values = {
          network = "preprod";
          region = "us-east-1";

          cardano-services = {
            ingresOrder = 99;
            image = oci.image.name;
            buildInfo = oci.meta.buildInfo;
            versions = oci.meta.versions;
            httpPrefix = "/v${oci.meta.versions.root}";
          };
        };
      };
    };
  }
