/* eslint-disable max-len */
/* eslint-disable promise/no-nesting */
/* eslint-disable @typescript-eslint/no-explicit-any */
import { ClientConfig, Pool, QueryConfig } from 'pg';
import { CommonOptionDescriptions, CommonProgramOptions } from '../ProgramsCommon';
import { HttpServerOptions } from './loadHttpServer';
import { InvalidArgsCombination, MissingProgramOption } from './errors';
import { Logger } from 'ts-log';
import { Ogmios, OgmiosCardanoNode, ogmiosTxSubmitProvider, urlToConnectionConfig } from '@cardano-sdk/ogmios';
import { ProgramOptionDescriptions } from './ProgramOptionDescriptions';
import { ProviderFailure, TxSubmitProvider } from '@cardano-sdk/core';
import { RabbitMqTxSubmitProvider } from '@cardano-sdk/rabbitmq';
import { ServiceNames } from './ServiceNames';
import dns, { SrvRecord } from 'dns';
import fs from 'fs';
import pRetry, { FailedAttemptError } from 'p-retry';

export const SERVICE_DISCOVERY_BACKOFF_FACTOR_DEFAULT = 1.1;
export const SERVICE_DISCOVERY_TIMEOUT_DEFAULT = 60 * 1000;
export const DNS_SRV_CACHE_KEY = 'DNS_SRV_Record';

export type RetryBackoffConfig = {
  factor?: number;
  maxRetryTime?: number;
};

export const onFailedAttemptFor =
  (serviceName: string, logger: Logger) =>
  async ({ attemptNumber, message, retriesLeft }: FailedAttemptError) => {
    const nextAction = retriesLeft > 0 ? 'retrying...' : 'exiting';
    logger.trace(message);
    logger.debug(
      `Establishing connection to ${serviceName}: Attempt ${attemptNumber} of ${
        attemptNumber + retriesLeft
      }, ${nextAction}`
    );
    if (retriesLeft === 0) {
      logger.error(message);
      // Invokes onDeath() callback within cardano-services entrypoints, following by server.shutdown() and process.exit(1)
      process.kill(process.pid, 'SIGTERM');
    }
  };

// Select the first random record from the DNS server resolved list
export const resolveSrvRecord = async (serviceName: string): Promise<SrvRecord> => {
  const [srvRecord] = await dns.promises.resolveSrv(serviceName);
  return srvRecord;
};

export const createDnsResolver = (config: RetryBackoffConfig, logger: Logger) => async (serviceName: string) =>
  await pRetry(async () => await resolveSrvRecord(serviceName), {
    factor: config.factor,
    maxRetryTime: config.maxRetryTime,
    onFailedAttempt: onFailedAttemptFor(serviceName, logger)
  });

export type DnsResolver = ReturnType<typeof createDnsResolver>;

export const connectionErrorCodes = ['ENOTFOUND', 'ECONNREFUSED', 'ECONNRESET'];

export const isConnectionError = (error: any) => {
  if (
    (error?.code && connectionErrorCodes.includes(error.code)) ||
    (error?.message && connectionErrorCodes.some((err) => error.message.includes(err))) ||
    error instanceof Ogmios.WebSocketClosed
  ) {
    return true;
  }
  return false;
};

/**
 * Creates a extended Pool client :
 * - use passed srv service name in order to resolve the port
 * - make dealing with failovers (re-resolving the port) opaque
 * - use exponential backoff retry internally with default timeout and factor
 * - intercept 'query' operation and handle connection errors runtime
 * - all other operations are bind to pool object withoud modifications
 *
 * @returns pg.Pool instance
 */
export const getPoolWithServiceDiscovery = async (
  dnsResolver: DnsResolver,
  logger: Logger,
  { host, database, password, ssl, user }: ClientConfig
): Promise<Pool> => {
  const { name, port } = await dnsResolver(host!);
  let pool = new Pool({ database, host: name, password, port, ssl, user });

  return new Proxy<Pool>({} as Pool, {
    get(_, prop) {
      if (prop === 'then') return;
      if (prop === 'query') {
        return (args: string | QueryConfig, values?: any) =>
          pool.query(args, values).catch(async (error) => {
            if (isConnectionError(error)) {
              const record = await dnsResolver(host!);
              logger.info(`DNS resolution for Postgres service, resolved with record: ${JSON.stringify(record)}`);
              pool = new Pool({ database, host: record.name, password, port: record.port, ssl, user });
              return await pool.query(args, values);
            }
            throw error;
          });
      }
      // Bind if it is a function, no intercept operations
      if (typeof pool[prop as keyof Pool] === 'function') {
        const method = pool[prop as keyof Pool] as any;
        return method.bind(pool);
      }
    }
  });
};

export const loadSecret = (path: string) => fs.readFileSync(path, 'utf8').toString();

export const getPool = async (
  dnsResolver: DnsResolver,
  logger: Logger,
  options?: HttpServerOptions
): Promise<Pool | undefined> => {
  const ssl = options?.postgresSslCaFile ? { ca: loadSecret(options.postgresSslCaFile) } : undefined;
  if (options?.postgresConnectionString && options.postgresSrvServiceName)
    throw new InvalidArgsCombination(
      ProgramOptionDescriptions.PostgresConnectionString,
      ProgramOptionDescriptions.PostgresServiceDiscoveryArgs
    );
  if (options?.postgresConnectionString) return new Pool({ connectionString: options.postgresConnectionString, ssl });
  if (options?.postgresSrvServiceName && options.postgresUser && options.postgresDb && options.postgresPassword) {
    return getPoolWithServiceDiscovery(dnsResolver, logger, {
      database: options.postgresDb,
      host: options.postgresSrvServiceName,
      password: options.postgresPassword,
      ssl,
      user: options.postgresUser
    });
  }
  // If db connection string is not passed nor postgres srv service name
  return undefined;
};

/**
 * Creates a extended TxSubmitProvider instance :
 * - use passed srv service name in order to resolve the port
 * - make dealing with failovers (re-resolving the port) opaque
 * - use exponential backoff retry internally with default timeout and factor
 * - intercept 'submitTx' operation and handle connection errors runtime
 * - all other operations are bind to pool object withoud modifications
 *
 * @returns TxSubmitProvider instance
 */
export const ogmiosTxSubmitProviderWithDiscovery = async (
  dnsResolver: DnsResolver,
  logger: Logger,
  serviceName: string
): Promise<TxSubmitProvider> => {
  const { name, port } = await dnsResolver(serviceName!);
  let ogmiosProvider = ogmiosTxSubmitProvider({ host: name, port });

  return new Proxy<TxSubmitProvider>({} as TxSubmitProvider, {
    get(_, prop) {
      if (prop === 'then') return;
      if (prop === 'submitTx') {
        return (args: Uint8Array) =>
          ogmiosProvider.submitTx(args).catch(async (error) => {
            if (error.innerError && isConnectionError(error.innerError)) {
              const record = await dnsResolver(serviceName!);
              logger.info(`DNS resolution for Ogmios service, resolved with record: ${JSON.stringify(record)}`);
              await ogmiosProvider
                .close?.()
                .catch((error_) =>
                  logger.warn(`Ogmios tx submit provider failed to close after DNS resolution: ${error_}`)
                );
              ogmiosProvider = ogmiosTxSubmitProvider({ host: record.name, port: record.port });
              return await ogmiosProvider.submitTx(args);
            }
            throw error;
          });
      }
      // Bind if it is a function, no intercept operations
      if (typeof ogmiosProvider[prop as keyof TxSubmitProvider] === 'function') {
        const method = ogmiosProvider[prop as keyof TxSubmitProvider] as any;
        return method.bind(ogmiosProvider);
      }
    }
  });
};

export const getOgmiosTxSubmitProvider = async (
  dnsResolver: DnsResolver,
  logger: Logger,
  options?: CommonProgramOptions
): Promise<TxSubmitProvider> => {
  if (options?.ogmiosSrvServiceName)
    return ogmiosTxSubmitProviderWithDiscovery(dnsResolver, logger, options.ogmiosSrvServiceName);
  if (options?.ogmiosUrl) return ogmiosTxSubmitProvider(urlToConnectionConfig(options?.ogmiosUrl));
  throw new MissingProgramOption(ServiceNames.TxSubmit, [
    CommonOptionDescriptions.OgmiosUrl,
    CommonOptionDescriptions.OgmiosSrvServiceName
  ]);
};

/**
 * Creates a extended OgmiosCardanoNode instance :
 * - use passed srv service name in order to resolve the port
 * - make dealing with failovers (re-resolving the port) opaque
 * - use exponential backoff retry internally with default timeout and factor
 * - intercept 'initialize' operation and handle connection errors on initialization
 * - intercept 'eraSummaries' operation and handle connection errors runtime
 * - all other operations are bind to pool object withoud modifications
 *
 * @returns OgmiosCardanoNode instance
 */
export const ogmiosCardanoNodeWithDiscovery = async (
  dnsResolver: DnsResolver,
  logger: Logger,
  serviceName: string
): Promise<OgmiosCardanoNode> => {
  const { name, port } = await dnsResolver(serviceName!);
  let ogmiosCardanoNode = new OgmiosCardanoNode({ host: name, port }, logger);

  return new Proxy<OgmiosCardanoNode>({} as OgmiosCardanoNode, {
    get(_, prop) {
      if (prop === 'then') return;
      if (prop === 'initialize') {
        return () =>
          ogmiosCardanoNode.initialize().catch(async (error) => {
            if (isConnectionError(error)) {
              const record = await dnsResolver(serviceName!);
              logger.info(`DNS resolution for Ogmios service, resolved with record: ${JSON.stringify(record)}`);
              await ogmiosCardanoNode
                .shutdown?.()
                .catch((error_) =>
                  logger.warn(`Ogmios cardano node failed to shutdown after DNS resolution: ${error_}`)
                );
              ogmiosCardanoNode = new OgmiosCardanoNode({ host: record.name, port: record.port }, logger);
              return await ogmiosCardanoNode.initialize();
            }
            throw error;
          });
      }
      if (prop === 'eraSummaries') {
        return () =>
          ogmiosCardanoNode.eraSummaries().catch(async (error) => {
            if (isConnectionError(error)) {
              const record = await dnsResolver(serviceName!);
              logger.info(`DNS resolution for Ogmios service, resolved with record: ${JSON.stringify(record)}`);
              await ogmiosCardanoNode
                .shutdown?.()
                .catch((error_) =>
                  logger.warn(`Ogmios cardano node failed to shutdown after DNS resolution: ${error_}`)
                );
              ogmiosCardanoNode = new OgmiosCardanoNode({ host: record.name, port: record.port }, logger);
              await ogmiosCardanoNode.initialize();
              return await ogmiosCardanoNode.eraSummaries();
            }
            throw error;
          });
      }
      // Bind if it is a function, no intercept operations
      if (typeof ogmiosCardanoNode[prop as keyof OgmiosCardanoNode] === 'function') {
        const method = ogmiosCardanoNode[prop as keyof OgmiosCardanoNode] as any;
        return method.bind(ogmiosCardanoNode);
      }
    }
  });
};

export const getOgmiosCardanoNode = async (
  dnsResolver: DnsResolver,
  logger: Logger,
  options?: CommonProgramOptions
): Promise<OgmiosCardanoNode> => {
  if (options?.ogmiosSrvServiceName)
    return ogmiosCardanoNodeWithDiscovery(dnsResolver, logger, options.ogmiosSrvServiceName);
  if (options?.ogmiosUrl) return new OgmiosCardanoNode(urlToConnectionConfig(options.ogmiosUrl), logger);
  throw new MissingProgramOption(ServiceNames.TxSubmit, [
    CommonOptionDescriptions.OgmiosUrl,
    CommonOptionDescriptions.OgmiosSrvServiceName
  ]);
};

export const srvRecordToRabbitmqURL = ({ name, port }: SrvRecord) => new URL(`amqp://${name}:${port}`);

/**
 * Creates a extended RabbitMqTxSubmitProvider instance :
 * - use passed srv service name in order to resolve the port
 * - make dealing with failovers (re-resolving the port) opaque
 * - use exponential backoff retry internally with default timeout and factor
 * - intercept 'submitTx' operation and handle connection errors runtime
 * - all other operations are bind to pool object withoud modifications
 *
 * @returns RabbitMqTxSubmitProvider instance
 */
export const rabbitMqTxSubmitProviderWithDiscovery = async (
  dnsResolver: DnsResolver,
  logger: Logger,
  serviceName: string
): Promise<RabbitMqTxSubmitProvider> => {
  const record = await dnsResolver(serviceName!);
  let rabbitmqProvider = new RabbitMqTxSubmitProvider({
    rabbitmqUrl: srvRecordToRabbitmqURL(record)
  });

  return new Proxy<RabbitMqTxSubmitProvider>({} as RabbitMqTxSubmitProvider, {
    get(_, prop) {
      if (prop === 'then') return;
      if (prop === 'submitTx') {
        return (args: Uint8Array) =>
          rabbitmqProvider.submitTx(args).catch(async (error) => {
            if (
              error.innerError?.reason === ProviderFailure.ConnectionFailure ||
              isConnectionError(error.innerError.innerError)
            ) {
              const resolvedRecord = await dnsResolver(serviceName!);
              logger.info(`DNS resolution for RabbitMQ service, resolved with record: ${JSON.stringify(record)}`);
              await rabbitmqProvider
                .close?.()
                .catch((error_) => logger.warn(`RabbitMQ provider failed to close after DNS resolution: ${error_}`));
              rabbitmqProvider = new RabbitMqTxSubmitProvider({
                rabbitmqUrl: srvRecordToRabbitmqURL(resolvedRecord)
              });
              return await rabbitmqProvider.submitTx(args);
            }
            throw error;
          });
      }
      // Bind if it is a function, no intercept operations
      if (typeof rabbitmqProvider[prop as keyof RabbitMqTxSubmitProvider] === 'function') {
        const method = rabbitmqProvider[prop as keyof RabbitMqTxSubmitProvider] as any;
        return method.bind(rabbitmqProvider);
      }
    }
  });
};

export const getRabbitMqTxSubmitProvider = async (
  dnsResolver: DnsResolver,
  logger: Logger,
  options?: CommonProgramOptions
): Promise<RabbitMqTxSubmitProvider> => {
  if (options?.rabbitmqSrvServiceName)
    return rabbitMqTxSubmitProviderWithDiscovery(dnsResolver, logger, options.rabbitmqSrvServiceName);
  if (options?.rabbitmqUrl) return new RabbitMqTxSubmitProvider({ rabbitmqUrl: options.rabbitmqUrl });
  throw new MissingProgramOption(ServiceNames.TxSubmit, [
    CommonOptionDescriptions.RabbitMQUrl,
    CommonOptionDescriptions.RabbitMQSrvServiceName
  ]);
};
