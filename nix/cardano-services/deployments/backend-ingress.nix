{
  lib,
  values,
  chart,
  config,
  utils,
  ...
}: {
  templates.backend-ingress = {
    apiVersion = "networking.k8s.io/v1";
    kind = "Ingress";
    metadata = {
      name = "${chart.name}-backend";
      labels = utils.appLabels "backend";
      annotations =
        {
          "alb.ingress.kubernetes.io/actions.ssl-redirect" = builtins.toJSON {
            Type = "redirect";
            RedirectConfig = {
              Protocol = "HTTPS";
              Port = "443";
              StatusCode = "HTTP_301";
            };
          };
          "alb.ingress.kubernetes.io/listen-ports" = builtins.toJSON [{HTTP = 80;} {HTTPS = 443;}];
          "alb.ingress.kubernetes.io/target-type" = "ip";
          "alb.ingress.kubernetes.io/scheme" = "internet-facing";
          "alb.ingress.kubernetes.io/wafv2-acl-arn" = values.backend.wafARN;
          "alb.ingress.kubernetes.io/healthcheck-path" = "${values.cardano-services.httpPrefix}/health";
          "alb.ingress.kubernetes.io/healthcheck-interval-seconds" = toString values.backend.albHealthcheck.interval;
          "alb.ingress.kubernetes.io/healthcheck-timeout-seconds" = toString values.backend.albHealthcheck.timeout;
          # Use latency routing policy
          "external-dns.alpha.kubernetes.io/aws-region" = values.region;
          "external-dns.alpha.kubernetes.io/set-identifier" = values.backend.dnsId;
          "alb.ingress.kubernetes.io/group.name" = chart.namespace;
          # ACM
          "alb.ingress.kubernetes.io/certificate-arn" = values.cardano-services.certificateArn;
          "alb.ingress.kubernetes.io/group.order" =  toString values.cardano-services.ingresOrder;
        };
    };
    spec = {
      ingressClassName = "alb";
      rules = [
        {
          host = values.backend.url;
          http.paths =
            [
              {
                pathType = "Prefix";
                path = "/";
                backend.service = {
                  name = "ssl-redirect";
                  port.name = "use-annotation";
                };
              }
            ]
            ++ (map (
                it: {
                  pathType = "Prefix";
                  path = it;
                  backend.service = {
                    name = "${chart.name}-backend";
                    port.name = "http";
                  };
                }
              )
              values.backend.routes)
            ++ lib.optionals config.providers.stake-pool-provider.enabled [
              {
                pathType = "Prefix";
                path = "/v${lib.last (lib.sort lib.versionOlder values.cardano-services.versions.stakePool)}/stake-pool";
                backend.service = {
                  name = "${chart.name}-stake-pool-provider";
                  port.name = "http";
                };
              }
            ]
            ++ lib.optionals config.providers.handle-provider.enabled [
              {
                pathType = "Prefix";
                path = "/v${lib.last (lib.sort lib.versionOlder values.cardano-services.versions.handle)}/handle";
                backend.service = {
                  name = "${chart.name}-handle-provider";
                  port.name = "http";
                };
              }
            ]
            ++ lib.optionals config.providers.asset-provider.enabled [
              {
                pathType = "Prefix";
                path = "/v${lib.last (lib.sort lib.versionOlder values.cardano-services.versions.handle)}/asset";
                backend.service = {
                  name = "${chart.name}-asset-provider";
                  port.name = "http";
                };
              }
            ]
            ++ values.cardano-services.additionalRoutes;
        }
      ];
    };
  };
}
