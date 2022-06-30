/* eslint-disable @typescript-eslint/no-explicit-any */
import { ClientConfig, Pool, QueryConfig } from 'pg';
import { HttpServerOptions } from './loadHttpServer';
import { InvalidArgsCombination } from './errors';
import Logger from 'bunyan';
import dns from 'dns';
import pRetry, { FailedAttemptError } from 'p-retry';

export const RETRY_BACKOFF_FACTOR_DEFAULT = 1.1;
export const RETRY_BACKOFF_MAX_TIMEOUT_DEFAULT = 60 * 1000;

type RetryBackoffConfig = {
  factor: number;
  maxRetryTime: number;
};

export const onFailedAttemptFor =
  (operation: string, logger: Logger) =>
  async ({ attemptNumber, message, retriesLeft }: FailedAttemptError) => {
    const nextAction = retriesLeft > 0 ? 'retrying...' : 'exiting';
    logger.trace(message);
    logger.debug(`${operation}: Attempt ${attemptNumber} of ${attemptNumber + retriesLeft}, ${nextAction}`);
    if (retriesLeft === 0) {
      logger.error(message);
      // await server.shutdown(); ?
      // eslint-disable-next-line unicorn/no-process-exit
      process.exit(1);
    }
  };

export const resolveDnsSrvWithExponentialBackoff = async (
  serviceName: string,
  { factor, maxRetryTime }: RetryBackoffConfig,
  logger: Logger
) =>
  await pRetry(
    async () => {
      // Shall we grab the first one always?
      const [record] = await dns.promises.resolveSrv(serviceName);
      return record;
    },
    {
      factor,
      maxRetryTime,
      onFailedAttempt: onFailedAttemptFor(`Establishing connection to ${serviceName}`, logger)
    }
  );

export const getSrvPool = async (
  { host, database, password, user }: ClientConfig,
  retryConfig: RetryBackoffConfig,
  logger: Logger
): Promise<Pool> => {
  const srvRecord = await resolveDnsSrvWithExponentialBackoff(host!, retryConfig, logger);
  let pool: Pool = new Pool({ database, host, password, port: srvRecord.port, user });

  return new Proxy<Pool>({} as Pool, {
    get(_, prop) {
      if (prop === 'then') return;
      if (prop === 'query') {
        return (args: string | QueryConfig, values?: any) =>
          pool.query(args, values).catch(async (error) => {
            if (error.code && ['ENOTFOUND', 'ECONNREFUSED'].includes(error.code)) {
              const record = await resolveDnsSrvWithExponentialBackoff(host!, retryConfig, logger);
              pool = new Pool({ database, host, password, port: record.port, user });
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

export const getPool = async (logger: Logger, options?: HttpServerOptions): Promise<Pool | undefined> => {
  if (options?.dbConnectionString && options.postgresSrvName)
    throw new InvalidArgsCombination(options.dbConnectionString, options.postgresSrvName);
  if (options?.dbConnectionString) return new Pool({ connectionString: options.dbConnectionString });
  // TODO: optimize passed options -> 'options' is required by default, no need to check it .? everywhere
  if (options?.postgresSrvName && options?.postgresUser && options.postgresName && options.postgresPassword) {
    return getSrvPool(
      {
        database: options.postgresName,
        host: options.postgresSrvName,
        password: options.postgresPassword,
        user: options.postgresUser
      },
      { factor: options.serviceDiscoveryBackoffFactor, maxRetryTime: options.serviceDiscoveryTimeout },
      logger
    );
  }
  // If db connection string nor srv db credentials are being passed
  return undefined;
};
