import { Bootstrap } from '@cardano-sdk/projection';
import { CommonProgramOptions, OgmiosProgramOptions, PosgresProgramOptions } from '../options';
import { DnsResolver, createDnsResolver } from '../utils';
import { HttpServer, HttpServerConfig } from '../../Http';
import { Logger } from 'ts-log';
import { ProjectionHttpService, ProjectionName, createTypeormProjection } from '../../Projection';
import { SrvRecord } from 'dns';
import { TypeormStabilityWindowBuffer } from '@cardano-sdk/projection-typeorm';
import { URL } from 'url';
import { UnknownServiceName } from '../errors';
import { createLogger } from 'bunyan';
import { getConnectionConfig, getOgmiosObservableCardanoNode } from '../services';

export const PROJECTOR_API_URL_DEFAULT = new URL('http://localhost:3002');

export type ProjectorArgs = CommonProgramOptions &
  PosgresProgramOptions &
  OgmiosProgramOptions & {
    projectionNames: ProjectionName[];
    dropSchema: boolean;
    dryRun: boolean;
  };
export interface LoadProjectorDependencies {
  dnsResolver?: (serviceName: string) => Promise<SrvRecord>;
  logger?: Logger;
}

interface ProjectionMapFactoryOptions {
  args: ProjectorArgs;
  dnsResolver: DnsResolver;
  logger: Logger;
}

const createProjectionHttpService = async (options: ProjectionMapFactoryOptions) => {
  const { args, dnsResolver, logger } = options;
  const cardanoNode = getOgmiosObservableCardanoNode(dnsResolver, logger, {
    ogmiosSrvServiceName: args.ogmiosSrvServiceName,
    ogmiosUrl: args.ogmiosUrl
  });
  const connectionConfig$ = getConnectionConfig(dnsResolver, args);
  const buffer = new TypeormStabilityWindowBuffer({ logger });
  const projection$ = createTypeormProjection({
    buffer,
    connectionConfig$,
    devOptions: args.dropSchema ? { dropSchema: true, synchronize: true } : undefined,
    logger,
    projectionSource$: Bootstrap.fromCardanoNode({
      buffer,
      cardanoNode,
      logger
    }),
    projections: args.projectionNames
  });
  return new ProjectionHttpService(
    { dryRun: args.dryRun, projection$, projectionNames: args.projectionNames },
    { logger }
  );
};

export const loadProjector = async (args: ProjectorArgs, deps: LoadProjectorDependencies = {}): Promise<HttpServer> => {
  const supportedProjections = Object.values(ProjectionName);
  for (const projectionName of args.projectionNames) {
    if (!supportedProjections.includes(projectionName)) {
      throw new UnknownServiceName(projectionName, Object.values(ProjectionName));
    }
  }
  const logger =
    deps?.logger ||
    createLogger({
      level: args.loggerMinSeverity,
      name: 'projector'
    });
  const dnsResolver =
    deps?.dnsResolver ||
    createDnsResolver(
      {
        factor: args.serviceDiscoveryBackoffFactor,
        maxRetryTime: args.serviceDiscoveryTimeout
      },
      logger
    );
  const service = await createProjectionHttpService({ args, dnsResolver, logger });
  const config: HttpServerConfig = {
    listen: {
      host: args.apiUrl.hostname,
      port: args.apiUrl ? Number.parseInt(args.apiUrl.port) : undefined
    },
    meta: { ...args.buildInfo, startupTime: Date.now() }
  };
  if (args.enableMetrics) {
    config.metrics = { enabled: args.enableMetrics };
  }
  return new HttpServer(config, { logger, services: [service] });
};
