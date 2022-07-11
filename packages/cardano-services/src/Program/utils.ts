/* eslint-disable max-len */
/* eslint-disable @typescript-eslint/no-explicit-any */
import { ClientConfig, Pool, QueryConfig } from 'pg';
import { HttpServerOptions } from './loadHttpServer';
import { InMemoryCache, UNLIMITED_CACHE_TTL } from '../InMemoryCache';
import { InvalidArgsCombination, MissingProgramOption } from './errors';
import { ProgramOptionDescriptions } from './ProgramOptionDescriptions';
import { ProviderError, ProviderFailure, TxSubmitProvider } from '@cardano-sdk/core';
import { RabbitMqTxSubmitProvider } from '@cardano-sdk/rabbitmq';
import { ServiceNames } from './ServiceNames';
import { WebSocketClosed, ogmiosTxSubmitProvider, urlToConnectionConfig } from '@cardano-sdk/ogmios';
import Logger from 'bunyan';
import dns, { SrvRecord } from 'dns';
import pRetry, { FailedAttemptError } from 'p-retry';

export const SERVICE_DISCOVERY_BACKOFF_FACTOR_DEFAULT = 1.1;
export const SERVICE_DISCOVERY_BACKOFF_TIMEOUT_DEFAULT = 60 * 1000;
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

// Return the cached record if present for stickiness with the service dependency, otherwise, select a random record from the DNS server
export const resolveMaybeCachedSrvRecord = async (serviceName: string, cache: InMemoryCache): Promise<SrvRecord> => {
  const cachedSrvRecord = cache.getVal<SrvRecord>(`${DNS_SRV_CACHE_KEY}/${serviceName}`);
  if (!cachedSrvRecord) {
    const [srvRecord] = await dns.promises.resolveSrv(serviceName);
    cache.set(`${DNS_SRV_CACHE_KEY}/${serviceName}`, srvRecord, UNLIMITED_CACHE_TTL);
    return srvRecord;
  }
  const records = await dns.promises.resolveSrv(serviceName);
  const recordFound = records.find((record) => record.name === cachedSrvRecord.name);
  if (!recordFound)
    throw new ProviderError(
      ProviderFailure.ConnectionFailure,
      null,
      'Cached SRV record not found within resolved list of records'
    );
  return recordFound;
};

export const createDnsResolver =
  (config: RetryBackoffConfig, cache: InMemoryCache, logger: Logger) => async (serviceName: string) =>
    await pRetry(async () => await resolveMaybeCachedSrvRecord(serviceName, cache), {
      factor: config.factor,
      maxRetryTime: config.maxRetryTime,
      onFailedAttempt: onFailedAttemptFor(serviceName, logger)
    });

export type DnsResolver = ReturnType<typeof createDnsResolver>;

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
  { host, database, password, user }: ClientConfig
): Promise<Pool> => {
  const { name, port } = await dnsResolver(host!);
  let pool = new Pool({ database, host: name, password, port, user });

  return new Proxy<Pool>({} as Pool, {
    get(_, prop) {
      if (prop === 'then') return;
      if (prop === 'query') {
        return (args: string | QueryConfig, values?: any) =>
          pool.query(args, values).catch(async (error) => {
            if (error.code && ['ENOTFOUND', 'ECONNREFUSED'].includes(error.code)) {
              const address = await dnsResolver(host!);
              pool = new Pool({ database, host: address.name, password, port: address.port, user });
              return await pool.query(args, values);
            }
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

export const getPool = async (dnsResolver: DnsResolver, options?: HttpServerOptions): Promise<Pool | undefined> => {
  if (options?.dbConnectionString && options.postgresSrvServiceName)
    throw new InvalidArgsCombination(ProgramOptionDescriptions.DbConnection, ProgramOptionDescriptions.PostgresSrvArgs);
  if (options?.dbConnectionString) return new Pool({ connectionString: options.dbConnectionString });
  if (options?.postgresSrvServiceName && options?.postgresUser && options.postgresDb && options.postgresPassword) {
    return getPoolWithServiceDiscovery(dnsResolver, {
      database: options.postgresDb,
      host: options.postgresSrvServiceName,
      password: options.postgresPassword,
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
            if (error instanceof WebSocketClosed && error.message === 'WebSocket is closed') {
              const record = await dnsResolver(serviceName!);
              ogmiosProvider = ogmiosTxSubmitProvider({ host: record.name, port: record.port });
              return await ogmiosProvider.submitTx(args);
            }
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
  options?: HttpServerOptions
): Promise<TxSubmitProvider> => {
  if (options?.ogmiosSrvServiceName)
    return ogmiosTxSubmitProviderWithDiscovery(dnsResolver, options.ogmiosSrvServiceName);
  if (options?.ogmiosUrl) return ogmiosTxSubmitProvider(urlToConnectionConfig(options?.ogmiosUrl));
  throw new MissingProgramOption(ServiceNames.TxSubmit, [
    ProgramOptionDescriptions.OgmiosUrl,
    ProgramOptionDescriptions.OgmiosSrvServiceName
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
            if (error instanceof ProviderError && error.innerError === ProviderFailure.ConnectionFailure) {
              const resolvedRecord = await dnsResolver(serviceName!);
              rabbitmqProvider = new RabbitMqTxSubmitProvider({
                rabbitmqUrl: srvRecordToRabbitmqURL(resolvedRecord)
              });
              return await rabbitmqProvider.submitTx(args);
            }
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
  options?: HttpServerOptions
): Promise<RabbitMqTxSubmitProvider> => {
  if (options?.rabbitmqSrvServiceName)
    return rabbitMqTxSubmitProviderWithDiscovery(dnsResolver, options.rabbitmqSrvServiceName);
  if (options?.rabbitmqUrl) return new RabbitMqTxSubmitProvider({ rabbitmqUrl: options.rabbitmqUrl });
  throw new MissingProgramOption(ServiceNames.TxSubmit, [
    ProgramOptionDescriptions.RabbitMQUrl,
    ProgramOptionDescriptions.RabbitMQSrvServiceName
  ]);
};
