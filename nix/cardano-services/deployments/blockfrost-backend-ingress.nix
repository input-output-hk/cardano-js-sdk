{
  lib,
  values,
  config,
  utils,
  ...
}: {
  templates.accelerator = lib.mkIf (values.blockfrost-backend.useAccelerator && values.ingress.enabled) {
    apiVersion = "operator.h3poteto.dev/v1alpha1";
    kind = "EndpointGroupBinding";
    metadata.name = "${config.name}-blockfrost";
    spec = {
      endpointGroupArn = values.acceleratorArn;
      ingressRef.name = "${config.name}-blockfrost";
    };
  };

  templates.blockfrost-backend-ingress = lib.mkIf values.ingress.enabled {
    apiVersion = "networking.k8s.io/v1";
    kind = "Ingress";
    metadata = {
      name = "${config.name}-blockfrost";
      labels = utils.appLabels "blockfrost";
      annotations =
        if values.blockfrost-backend.useAccelerator
        then {
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
          "alb.ingress.kubernetes.io/healthcheck-path" = "${values.cardano-services.httpPrefix}/health";
          "alb.ingress.kubernetes.io/healthcheck-interval-seconds" = toString values.blockfrost-backend.albHealthcheck.interval;
          "alb.ingress.kubernetes.io/healthcheck-timeout-seconds" = toString values.blockfrost-backend.albHealthcheck.timeout;
          "alb.ingress.kubernetes.io/group.order" = toString values.cardano-services.ingresOrder;
          "external-dns.alpha.kubernetes.io/disabled" = "true";
        }
        else {
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
          # Use latency routing policy
          "external-dns.alpha.kubernetes.io/aws-region" = config.region;
          "external-dns.alpha.kubernetes.io/set-identifier" = values.blockfrost-backend.dnsId;
          "alb.ingress.kubernetes.io/group.name" = config.namespace;
          "alb.ingress.kubernetes.io/group.order" = toString values.cardano-services.ingresOrder;
        };
    };
    spec = {
      ingressClassName = "alb";
      rules =
        map (hostname: {
          host = hostname;
          http.paths =[
              {
                pathType = "Prefix";
                path = "/";
                backend.service = {
                  name = "${config.name}-blockfrost-backend";
                  port.name = "http";
                };
              }
            ];
        })
        values.blockfrost-backend.hostnames;
    };
  };
}
