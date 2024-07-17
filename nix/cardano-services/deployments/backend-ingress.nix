{
  lib,
  values,
  chart,
  config,
  utils,
  ...
}: {
  templates.accelerator = lib.mkIf (values.useAccelerator && values.ingress.enabled)  {
    apiVersion = "operator.h3poteto.dev/v1alpha1";
    kind = "EndpointGroupBinding";
    metadata.name = "${chart.name}-main";
    spec = {
      endpointGroupArn = values.acceleratorArn;
      ingressRef.name = "${chart.name}-backend";
    };
  };

  templates.backend-ingress = lib.mkIf values.ingress.enabled {
    apiVersion = "networking.k8s.io/v1";
    kind = "Ingress";
    metadata = {
      name = "${chart.name}-backend";
      labels = utils.appLabels "backend";
      annotations = if values.useAccelerator then {
        "service.beta.kubernetes.io/aws-load-balancer-backend-protocol" = "tcp";
        "service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled" = "true";
        "service.beta.kubernetes.io/aws-load-balancer-type" = "external";
        "alb.ingress.kubernetes.io/scheme" = "internet-facing";
        "service.beta.kubernetes.io/aws-load-balancer-scheme" = "internet-facing";
        "alb.ingress.kubernetes.io/target-type" = "ip";
        "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type" = "ip";
        "service.beta.kubernetes.io/aws-load-balancer-proxy-protocol" = "*";
        "service.beta.kubernetes.io/aws-load-balancer-target-group-attributes" = "proxy_protocol_v2.enabled=true,preserve_client_ip.enabled=true";

        "alb.ingress.kubernetes.io/listen-ports" = builtins.toJSON [{HTTP = 80;} {HTTPS = 443;}];
        #"alb.ingress.kubernetes.io/wafv2-acl-arn" = values.backend.wafARN;
        "alb.ingress.kubernetes.io/healthcheck-path" = "${values.cardano-services.httpPrefix}/health";
        "alb.ingress.kubernetes.io/healthcheck-interval-seconds" = toString values.backend.albHealthcheck.interval;
        "alb.ingress.kubernetes.io/healthcheck-timeout-seconds" = toString values.backend.albHealthcheck.timeout;
        "alb.ingress.kubernetes.io/group.order" = toString values.cardano-services.ingresOrder;
      } else {
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
        "external-dns.alpha.kubernetes.io/aws-region" = config.region;
        "external-dns.alpha.kubernetes.io/set-identifier" = values.backend.dnsId;
        "alb.ingress.kubernetes.io/group.name" = chart.namespace;
        "alb.ingress.kubernetes.io/group.order" = toString values.cardano-services.ingresOrder;
      };
    };
    spec = {
      ingressClassName = "alb";
      rules =
        map (hostname: {
          host = hostname;
          http.paths =
            (lib.optionals config.providers.asset-provider.enabled [
              {
                pathType = "Prefix";
                path = "/v${lib.last (lib.sort lib.versionOlder values.cardano-services.versions.handle)}/asset";
                backend.service = {
                  name = "${chart.name}-asset-provider";
                  port.name = "http";
                };
              }
            ])
            ++ (lib.optionals config.providers.handle-provider.enabled [
              {
                pathType = "Prefix";
                path = "/v${lib.last (lib.sort lib.versionOlder values.cardano-services.versions.handle)}/handle";
                backend.service = {
                  name = "${chart.name}-handle-provider";
                  port.name = "http";
                };
              }
            ])
            ++ (lib.optionals config.providers.chain-history-provider.enabled (
              map (version: {
                pathType = "Prefix";
                path = "/v${version}/chain-history";
                backend.service = {
                  name = "${chart.name}-chain-history-provider";
                  port.name = "http";
                };
              })
              values.cardano-services.versions.chainHistory
            ))
            ++ [
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
            ++ lib.optionals values.ws-server.enabled [
              {
                pathType = "Exact";
                path = "/ws";
                backend.service = {
                  name = "${chart.name}-ws-server";
                  port.name = "http";
                };
              }
            ]
            ++ values.cardano-services.additionalRoutes;
        })
        values.backend.hostnames;
    };
  };
}
