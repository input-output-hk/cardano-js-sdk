let
  inherit (inputs.std) dmerge;
  inherit (inputs.std.inputs) haumea;
  inherit (inputs.std.lib.ops) readYAML;

  # haumea regex matcher signature:
  # https://nix-community.github.io/haumea/api/matchers.html#matchersregex
  #   we disregard cursor value and haumea inputs here
  loadYaml = _: _: readYAML;

  baseline = with haumea.lib;
    load {
      src = ./deployments;
      loader = [(matchers.regex ''^.+\.(yaml|yml)'' loadYaml)];
    };
in rec {
  dev-preview = dmerge baseline {
    meta.description = "Development Environment on the Cardano Preview Chain (Frankfurt) for every merge to main branch";
    backend-deployment = {
      spec.template.spec.containers = dmerge.updateOn "name" [
        {
          name = "backend";
          image = cell.oci-images.cardano-services.image.name;
        }
      ];
    };
    handle-projector-deployment = {
      spec.template.spec.containers = dmerge.updateOn "name" [
        {
          name = "handle-projector";
          image = cell.oci-images.cardano-services.image.name;
        }
      ];
    };
    pgboss-deployment = {
      spec.template.spec.containers = dmerge.updateOn "name" [
        {
          name = "pg-boss-worker";
          image = cell.oci-images.cardano-services.image.name;
        }
      ];
    };
    stake-pool-projector-deployment = {
      spec.template.spec.containers = dmerge.updateOn "name" [
        {
          name = "stake-pool-projector";
          image = cell.oci-images.cardano-services.image.name;
        }
      ];
    };
    stake-pool-provider-deployment = {
      spec.template.spec.containers = dmerge.updateOn "name" [
        {
          name = "stake-pool-provider";
          image = cell.oci-images.cardano-services.image.name;
        }
      ];
    };
  };

  dev-preprod = let
    namespace = "dev-preprod";
    ogmiosServiceName = [
      {
        name = "OGMIOS_SRV_SERVICE_NAME";
        value = "${namespace}-cardano-stack";
      }
    ];
    tokenMetadataServerUrl = [
      {
        name = "TOKEN_METADATA_SERVER_URL";
        value = "http://${namespace}-cardano-stack-metadata";
      }
    ];
    stakePoolProviderUrl = [
      # Stake Pool service
      {
        name = "STAKE_POOL_PROVIDER_URL";
        value = "https://${namespace}-stake-pool/stake-pool";
      }
    ];
    dbSyncDbAccess = [
      # DB Sync database access
      {
        name = "POSTGRES_HOST_DB_SYNC";
        value = "${namespace}-dbsync-db";
      }
      {
        name = "POSTGRES_PASSWORD_DB_SYNC";
        valueFrom.secretKeyRef.name = "cardano-owner-user.${namespace}-dbsync-db.credentials.postgresql.acid.zalan.do";
      }
      {
        name = "POSTGRES_USER_DB_SYNC";
        valueFrom.secretKeyRef.name = "cardano-owner-user.${namespace}-dbsync-db.credentials.postgresql.acid.zalan.do";
      }
    ];
    stakePoolDbAccess' = [
      # Stake Pool database access
      {
        name = "POSTGRES_HOST_STAKE_POOL";
        value = "${namespace}-dbsync-db";
      }
      {
        name = "POSTGRES_PASSWORD_STAKE_POOL";
        valueFrom.secretKeyRef.name = "stakepool-owner-user.${namespace}-dbsync-db.credentials.postgresql.acid.zalan.do";
      }
      {
        name = "POSTGRES_USER_STAKE_POOL";
        valueFrom.secretKeyRef.name = "stakepool-owner-user.${namespace}-dbsync-db.credentials.postgresql.acid.zalan.do";
      }
    ];
    stakePoolDbAccess = [
      # Stake Pool database access (variant)
      {
        name = "POSTGRES_HOST";
        value = "${namespace}-dbsync-db";
      }
      {
        name = "POSTGRES_PASSWORD";
        valueFrom.secretKeyRef.name = "stakepool-owner-user.${namespace}-dbsync-db.credentials.postgresql.acid.zalan.do";
      }
      {
        name = "POSTGRES_USER";
        valueFrom.secretKeyRef.name = "stakepool-owner-user.${namespace}-dbsync-db.credentials.postgresql.acid.zalan.do";
      }
    ];
    handleDbAccess = [
      # Stake Pool database access (variant)
      {
        name = "POSTGRES_HOST";
        value = "${namespace}-dbsync-db";
      }
      {
        name = "POSTGRES_PASSWORD";
        valueFrom.secretKeyRef.name = "handle-owner-user.${namespace}-dbsync-db.credentials.postgresql.acid.zalan.do";
      }
      {
        name = "POSTGRES_USER";
        valueFrom.secretKeyRef.name = "handle-owner-user.${namespace}-dbsync-db.credentials.postgresql.acid.zalan.do";
      }
    ];
  in
    dmerge dev-preview {
      meta.description = "Development Environment on the Cardano Preprod Chain (Frankfurt) for every release";
      kustomization = {
        namespace = "dev-preprod";
        namePrefix = "dev-preprod-";
        commonLabels = {
          network = "preprod";
        };
      };

      # Ingress overlays
      coingecko-proxy-ingress = {
        metadata.annotations = {
          "external-dns.alpha.kubernetes.io/set-identifier" = "eu-central-1-${namespace}-proxy";
        };
        spec.rules = dmerge.update [0] [
          {host = "coingecko.${namespace}.eks.lw.iog.io";}
        ];
        spec.tls = dmerge.update [0] [
          {host = "coingecko.${namespace}.eks.lw.iog.io";}
        ];
      };
      backend-ingress = {
        metadata.annotations = {
          "external-dns.alpha.kubernetes.io/set-identifier" = "eu-central-1-${namespace}-backend";
        };
        spec.rules = dmerge.update [0] [
          {host = "backend.${namespace}.eks.lw.iog.io";}
        ];
        spec.tls = dmerge.update [0] [
          {host = "backend.${namespace}.eks.lw.iog.io";}
        ];
      };

      # Deployment overlays
      # # Stake Pool Projector + Provider
      stake-pool-projector-deployment.spec.template.spec.containers = dmerge.updateOn "name" [
        {
          name = "stake-pool-projector";
          env = dmerge.updateOn "name" (
            ogmiosServiceName
            ++ stakePoolDbAccess'
          );
        }
      ];
      stake-pool-provider-deployment.spec.template.spec.containers = dmerge.updateOn "name" [
        {
          name = "stake-pool-provider";
          env = dmerge.updateOn "name" (
            ogmiosServiceName
            ++ tokenMetadataServerUrl
            ++ stakePoolDbAccess' # variant
          );
        }
      ];
      # # Handle Projector + Provider
      handle-projector-deployment.spec.template.spec.containers = dmerge.updateOn "name" [
        {
          name = "handle-projector";
          env = dmerge.updateOn "name" (
            ogmiosServiceName
            ++ handleDbAccess
          );
        }
      ];
      handle-provider-deployment.spec.template.spec.containers = dmerge.updateOn "name" [
        {
          name = "handle-provider";
          env = dmerge.updateOn "name" (
            ogmiosServiceName
            ++ handleDbAccess
          );
        }
      ];
      # # Backend (?)
      backend-deployment.spec.template.spec.containers = dmerge.updateOn "name" [
        {
          name = "backend";
          env = dmerge.updateOn "name" (
            ogmiosServiceName
            ++ tokenMetadataServerUrl
            ++ dbSyncDbAccess
          );
        }
      ];
      # # PgBoss Worker
      pgboss-deployment.spec.template.spec.containers = dmerge.updateOn "name" [
        {
          name = "pg-boss-worker";
          env = dmerge.updateOn "name" (
            stakePoolProviderUrl
            ++ dbSyncDbAccess
            ++ stakePoolDbAccess' # variant
          );
        }
      ];
    };
}
