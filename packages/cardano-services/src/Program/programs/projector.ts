import { HandlePolicyIdsOptionDescriptions, handlePolicyIdsFromFile } from '../options/policyIds.js';
import { HttpServer } from '../../Http/index.js';
import { MissingProgramOption, UnknownServiceName } from '../errors/index.js';
import {
  ProjectionHttpService,
  ProjectionName,
  createTypeormProjection,
  storeOperators
} from '../../Projection/index.js';
import { createDnsResolver } from '../utils.js';
import { createLogger } from 'bunyan';
import { createStorePoolMetricsUpdateJob, createStoreStakePoolMetadataJob } from '@cardano-sdk/projection-typeorm';
import { getConnectionConfig, getOgmiosObservableCardanoNode } from '../services/index.js';
import type { Cardano } from '@cardano-sdk/core';
import type { CommonProgramOptions, OgmiosProgramOptions, PosgresProgramOptions } from '../options/index.js';
import type { DnsResolver } from '../utils.js';
import type { HandlePolicyIdsProgramOptions } from '../options/policyIds.js';
import type { HttpServerConfig } from '../../Http/index.js';
import type { Logger } from 'ts-log';
import type { SrvRecord } from 'dns';

export const BLOCKS_BUFFER_LENGTH_DEFAULT = 10;
export const PROJECTOR_API_URL_DEFAULT = new URL('http://localhost:3002');

export type ProjectorArgs = CommonProgramOptions &
  PosgresProgramOptions<''> &
  HandlePolicyIdsProgramOptions &
  OgmiosProgramOptions & {
    blocksBufferLength: number;
    dropSchema: boolean;
    dryRun: boolean;
    exitAtBlockNo: Cardano.BlockNo;
    metadataJobRetryDelay: number;
    poolsMetricsInterval: number;
    projectionNames: ProjectionName[];
    synchronize: boolean;
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
  storeOperators.storePoolMetricsUpdateJob = createStorePoolMetricsUpdateJob(args.poolsMetricsInterval)();
  storeOperators.storeStakePoolMetadataJob = createStoreStakePoolMetadataJob(args.metadataJobRetryDelay)();
  const cardanoNode = getOgmiosObservableCardanoNode(dnsResolver, logger, {
    ogmiosSrvServiceName: args.ogmiosSrvServiceName,
    ogmiosUrl: args.ogmiosUrl
  });
  const connectionConfig$ = getConnectionConfig(dnsResolver, 'projector', '', args);
  const { blocksBufferLength, dropSchema, dryRun, exitAtBlockNo, handlePolicyIds, projectionNames, synchronize } = args;
  const projection$ = createTypeormProjection({
    blocksBufferLength,
    cardanoNode,
    connectionConfig$,
    devOptions: { dropSchema, synchronize },
    exitAtBlockNo,
    logger,
    projectionOptions: {
      handlePolicyIds
    },
    projections: projectionNames
  });
  return new ProjectionHttpService({ dryRun, projection$, projectionNames }, { logger });
};

export const loadProjector = async (args: ProjectorArgs, deps: LoadProjectorDependencies = {}): Promise<HttpServer> => {
  const supportedProjections = Object.values(ProjectionName);

  await handlePolicyIdsFromFile(args);

  const {
    apiUrl,
    buildInfo,
    enableMetrics,
    handlePolicyIds,
    loggerMinSeverity,
    projectionNames,
    serviceDiscoveryBackoffFactor,
    serviceDiscoveryTimeout
  } = args;

  for (const projectionName of projectionNames) {
    if (!supportedProjections.includes(projectionName)) {
      throw new UnknownServiceName(projectionName, Object.values(ProjectionName));
    }
    if (projectionName === ProjectionName.Handle && !handlePolicyIds) {
      throw new MissingProgramOption(ProjectionName.Handle, [
        HandlePolicyIdsOptionDescriptions.HandlePolicyIds,
        HandlePolicyIdsOptionDescriptions.HandlePolicyIdsFile
      ]);
    }
  }
  const logger =
    deps?.logger ||
    createLogger({
      level: loggerMinSeverity,
      name: 'projector'
    });
  const dnsResolver =
    deps?.dnsResolver ||
    createDnsResolver(
      {
        factor: serviceDiscoveryBackoffFactor,
        maxRetryTime: serviceDiscoveryTimeout
      },
      logger
    );
  const service = await createProjectionHttpService({ args, dnsResolver, logger });
  const config: HttpServerConfig = {
    listen: {
      host: apiUrl.hostname,
      port: apiUrl ? Number.parseInt(apiUrl.port) : undefined
    },
    meta: { ...buildInfo, startupTime: Date.now() }
  };
  if (enableMetrics) {
    config.metrics = { enabled: enableMetrics };
  }
  return new HttpServer(config, { logger, services: [service] });
};
