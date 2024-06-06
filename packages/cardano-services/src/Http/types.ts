import type { Options } from 'body-parser';
import type expressPromBundle from 'express-prom-bundle';
import type net from 'net';

export type ServiceHealth = {
  ok: boolean;
  name: string;
};

export type ServicesHealthCheckResponse = {
  ok: boolean;
  services: ServiceHealth[];
};

export type ServerMetadata = {
  lastModified?: number;
  lastModifiedDate?: string;
  rev?: string;
  shortRev?: string;
  extra?: JSON;
  startupTime: number;
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
  meta?: ServerMetadata;
  listen: net.ListenOptions;
  allowedOrigins?: string[];
};

export type BuildInfo = Omit<ServerMetadata, 'extra' | 'startupTime'>;
