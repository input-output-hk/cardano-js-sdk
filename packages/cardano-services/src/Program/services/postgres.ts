/* eslint-disable max-len */
/* eslint-disable promise/no-nesting */
/* eslint-disable @typescript-eslint/no-explicit-any */
import { ClientConfig, Pool, QueryConfig } from 'pg';
import { DnsResolver } from '../utils';
import { HttpServerOptions } from '../loadHttpServer';
import { Logger } from 'ts-log';
import { installTemporarySchemaOnDbSync } from '../../util';
import { isConnectionError } from '@cardano-sdk/util';
import fs from 'fs';

/**
 * Creates a extended Pool client :
 * - use passed srv service name in order to resolve the port
 * - make dealing with failover (re-resolving the port) opaque
 * - use exponential backoff retry internally with default timeout and factor
 * - intercept 'query' operation and handle connection errors runtime
 * - all other operations are bind to pool object without modifications
 *
 * @returns pg.Pool instance
 */
export const getPoolWithServiceDiscovery = async (
  dnsResolver: DnsResolver,
  logger: Logger,
  { host, database, password, ssl, user }: ClientConfig,
  epochLength?: number
): Promise<Pool> => {
  const { name, port } = await dnsResolver(host!);
  let pool = installTemporarySchemaOnDbSync(
    new Pool({ database, host: name, password, port, ssl, user }),
    logger,
    epochLength
  );

  return new Proxy<Pool>({} as Pool, {
    get(_, prop) {
      if (prop === 'then') return;
      if (prop === 'query') {
        return (args: string | QueryConfig, values?: any) =>
          pool.query(args, values).catch(async (error) => {
            if (isConnectionError(error)) {
              const record = await dnsResolver(host!);
              logger.info(`DNS resolution for Postgres service, resolved with record: ${JSON.stringify(record)}`);
              pool = installTemporarySchemaOnDbSync(
                new Pool({ database, host: record.name, password, port: record.port, ssl, user }),
                logger,
                epochLength
              );
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
  options?: HttpServerOptions,
  epochLength?: number
): Promise<Pool | undefined> => {
  const ssl = options?.postgresSslCaFile ? { ca: loadSecret(options.postgresSslCaFile) } : undefined;
  if (options?.postgresConnectionString)
    return installTemporarySchemaOnDbSync(
      new Pool({ connectionString: options.postgresConnectionString, ssl }),
      logger,
      epochLength
    );
  if (options?.postgresSrvServiceName && options.postgresUser && options.postgresDb && options.postgresPassword) {
    return getPoolWithServiceDiscovery(
      dnsResolver,
      logger,
      {
        database: options.postgresDb,
        host: options.postgresSrvServiceName,
        password: options.postgresPassword,
        ssl,
        user: options.postgresUser
      },
      epochLength
    );
  }
  // If db connection string is not passed nor postgres srv service name
  return undefined;
};
