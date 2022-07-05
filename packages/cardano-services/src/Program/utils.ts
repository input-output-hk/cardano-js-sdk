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

// Get a random selection of dns srv resolved service address initially and make it sticky for reconnects by storing a reference in memory
export const getStikyAddressWithDnsSrv = async (serviceName: string, cache: InMemoryCache): Promise<SrvRecord> => {
  const stickyAddress = cache.getVal<SrvRecord>(`${DNS_SRV_CACHE_KEY}/${serviceName}`);
  if (!stickyAddress) {
    const [address] = await dns.promises.resolveSrv(serviceName);
    cache.set(`${DNS_SRV_CACHE_KEY}/${serviceName}`, address, UNLIMITED_CACHE_TTL);
    return address;
  }
  const addresses = await dns.promises.resolveSrv(serviceName);
  const addressFound = addresses.find((address) => address.name === stickyAddress.name);
  if (!addressFound)
    throw new ProviderError(
      ProviderFailure.ConnectionFailure,
      null,
      'Stiky address not found within dns srv resolved addresses'
    );
  return addressFound;
};

export const getDnsSrvResolveWithExponentialBackoff =
  (config: RetryBackoffConfig, cache: InMemoryCache, logger: Logger) => async (serviceName: string) =>
    await pRetry(async () => await getStikyAddressWithDnsSrv(serviceName, cache), {
      factor: config.factor,
      maxRetryTime: config.maxRetryTime,
      onFailedAttempt: onFailedAttemptFor(serviceName, logger)
    });

export type DnsSrvResolve = ReturnType<typeof getDnsSrvResolveWithExponentialBackoff>;

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
export const getSrvPool = async (
  dnsSrvResolve: DnsSrvResolve,
  { host, database, password, user }: ClientConfig
): Promise<Pool> => {
  const { name, port } = await dnsSrvResolve(host!);
  let pool = new Pool({ database, host: name, password, port, user });

  return new Proxy<Pool>({} as Pool, {
    get(_, prop) {
      if (prop === 'then') return;
      if (prop === 'query') {
        return (args: string | QueryConfig, values?: any) =>
          pool.query(args, values).catch(async (error) => {
            if (error.code && ['ENOTFOUND', 'ECONNREFUSED'].includes(error.code)) {
              const address = await dnsSrvResolve(host!);
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

export const getPool = async (dnsSrvResolve: DnsSrvResolve, options?: HttpServerOptions): Promise<Pool | undefined> => {
  if (options?.dbConnectionString && options.postgresSrvServiceName)
    throw new InvalidArgsCombination(
      ProgramOptionDescriptions.DbConnection,
      ProgramOptionDescriptions.PostgresSrvServiceName
    );
  if (options?.dbConnectionString) return new Pool({ connectionString: options.dbConnectionString });
  if (options?.postgresSrvServiceName && options?.postgresUser && options.postgresName && options.postgresPassword) {
    return getSrvPool(dnsSrvResolve, {
      database: options.postgresName,
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
export const getSrvOgmiosTxSubmitProvider = async (
  dnsSrvResolve: DnsSrvResolve,
  serviceName: string
): Promise<TxSubmitProvider> => {
  const { name, port } = await dnsSrvResolve(serviceName!);
  let ogmiosProvider = ogmiosTxSubmitProvider({ host: name, port });

  return new Proxy<TxSubmitProvider>({} as TxSubmitProvider, {
    get(_, prop) {
      if (prop === 'then') return;
      if (prop === 'submitTx') {
        return (args: Uint8Array) =>
          ogmiosProvider.submitTx(args).catch(async (error) => {
            if (error instanceof WebSocketClosed && error.message === 'WebSocket is closed') {
              const address = await dnsSrvResolve(serviceName!);
              ogmiosProvider = ogmiosTxSubmitProvider(address);
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

export const getCardanoNodeProvider = async (
  dnsSrvResolve: DnsSrvResolve,
  options?: HttpServerOptions
): Promise<TxSubmitProvider> => {
  if (options?.ogmiosUrl && options.ogmiosSrvServiceName)
    throw new InvalidArgsCombination(
      ProgramOptionDescriptions.OgmiosUrl,
      ProgramOptionDescriptions.OgmiosSrvServiceName
    );
  if (options?.ogmiosUrl) return ogmiosTxSubmitProvider(urlToConnectionConfig(options?.ogmiosUrl));
  if (options?.ogmiosSrvServiceName) {
    return getSrvOgmiosTxSubmitProvider(dnsSrvResolve, options.ogmiosSrvServiceName);
  }
  throw new MissingProgramOption(ServiceNames.TxSubmit, [
    ProgramOptionDescriptions.OgmiosUrl,
    ProgramOptionDescriptions.OgmiosSrvServiceName
  ]);
};

export const srvAddressToRabbitmqURL = ({ name, port }: SrvRecord) => new URL(`amqp://${name}:${port}`);

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
export const getSrvRabbitMqTxSubmitProvider = async (
  dnsSrvResolve: DnsSrvResolve,
  serviceName: string
): Promise<RabbitMqTxSubmitProvider> => {
  const address = await dnsSrvResolve(serviceName!);
  let rabbitmqProvider = new RabbitMqTxSubmitProvider({
    rabbitmqUrl: srvAddressToRabbitmqURL(address)
  });

  return new Proxy<RabbitMqTxSubmitProvider>({} as RabbitMqTxSubmitProvider, {
    get(_, prop) {
      if (prop === 'then') return;
      if (prop === 'submitTx') {
        return (args: Uint8Array) =>
          rabbitmqProvider.submitTx(args).catch(async (error) => {
            if (error instanceof ProviderError && error.innerError === ProviderFailure.ConnectionFailure) {
              const resolvedAddress = await dnsSrvResolve(serviceName!);
              rabbitmqProvider = new RabbitMqTxSubmitProvider({
                rabbitmqUrl: srvAddressToRabbitmqURL(resolvedAddress)
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
  dnsSrvResolve: DnsSrvResolve,
  options?: HttpServerOptions
): Promise<RabbitMqTxSubmitProvider> => {
  if (options?.rabbitmqUrl && options.rabbitmqSrvServiceName)
    throw new InvalidArgsCombination(
      ProgramOptionDescriptions.RabbitMQUrl,
      ProgramOptionDescriptions.RabbitMQSrvServiceName
    );
  if (options?.rabbitmqUrl) return new RabbitMqTxSubmitProvider({ rabbitmqUrl: options.rabbitmqUrl });
  if (options?.rabbitmqSrvServiceName) {
    return getSrvRabbitMqTxSubmitProvider(dnsSrvResolve, options.rabbitmqSrvServiceName);
  }
  throw new MissingProgramOption(ServiceNames.TxSubmit, [
    ProgramOptionDescriptions.RabbitMQUrl,
    ProgramOptionDescriptions.RabbitMQSrvServiceName
  ]);
};
