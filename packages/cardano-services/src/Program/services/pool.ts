/* eslint-disable max-len */
/* eslint-disable promise/no-nesting */
/* eslint-disable @typescript-eslint/no-explicit-any */
import { ClientConfig, Pool, QueryConfig } from 'pg';
import { DnsResolver } from './utils';
import { HttpServerOptions } from '../loadHttpServer';
import { InvalidArgsCombination } from '../errors';
import { Logger } from 'ts-log';
import { ProgramOptionDescriptions } from '../ProgramOptionDescriptions';

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
            if (error.code && ['ENOTFOUND', 'ECONNREFUSED', 'ECONNRESET'].includes(error.code)) {
              const record = await dnsResolver(host!);
              logger.info(`DNS resolution for Postgres service, resolved with record: ${JSON.stringify(record)}`);
              pool = new Pool({ database, host: record.name, password, port: record.port, user });
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

export const getPool = async (
  dnsResolver: DnsResolver,
  logger: Logger,
  options?: HttpServerOptions
): Promise<Pool | undefined> => {
  if (options?.postgresConnectionString && options.postgresSrvServiceName)
    throw new InvalidArgsCombination(
      ProgramOptionDescriptions.PostgresConnectionString,
      ProgramOptionDescriptions.PostgresServiceDiscoveryArgs
    );
  if (options?.postgresConnectionString) return new Pool({ connectionString: options.postgresConnectionString });
  if (options?.postgresSrvServiceName && options.postgresUser && options.postgresDb && options.postgresPassword) {
    return getPoolWithServiceDiscovery(dnsResolver, logger, {
      database: options.postgresDb,
      host: options.postgresSrvServiceName,
      password: options.postgresPassword,
      user: options.postgresUser
    });
  }
  // If db connection string is not passed nor postgres srv service name
  return undefined;
};
