import { Options } from 'body-parser';
import expressPromBundle from 'express-prom-bundle';
import net from 'net';

export type ServiceHealth = {
  ok: boolean;
  name: string;
};

export type ServicesHealthCheckResponse = {
  ok: boolean;
  services: ServiceHealth[];
};

export type HttpServerConfig = {
  metrics?: {
    enabled: boolean;
    options?: expressPromBundle.Opts;
  };
  bodyParser?: {
    limit?: Options['limit'];
  };
  name?: string;
  listen: net.ListenOptions;
};
