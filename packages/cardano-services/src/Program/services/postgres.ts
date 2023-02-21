/* eslint-disable max-len */
/* eslint-disable promise/no-nesting */
/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable unicorn/no-nested-ternary */
import { ClientConfig, Pool, QueryConfig } from 'pg';
import { DnsResolver } from '../utils';
import { HttpServerOptions } from '../programs';
import { Logger } from 'ts-log';
import { PosgresProgramOptions } from '../options';
import { URL } from 'url';
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
  options?: PosgresProgramOptions
): Promise<Pool | undefined> => {
  const ssl = options?.postgresSslCaFile ? { ca: loadSecret(options.postgresSslCaFile) } : undefined;
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

const getSecret = (secretFilePath?: string, secret?: string) =>
  secretFilePath ? loadSecret(secretFilePath) : secret ? secret : undefined;

export const connectionStringFromOptions = (args: HttpServerOptions) => {
  const dbName = getSecret(args.postgresDbFile, args.postgresDb);
  const dbUser = getSecret(args.postgresUserFile, args.postgresUser);
  const dbPassword = getSecret(args.postgresPasswordFile, args.postgresPassword);

  // Setting the connection string takes preference over secrets.
  // It can also remain undefined since there is no a default value. Usually used locally with static config.
  let postgresConnectionString;
  if (args.postgresConnectionString) {
    postgresConnectionString = new URL(args.postgresConnectionString).toString();
  } else if (dbName && dbPassword && dbUser && args.postgresHost && args.postgresPort) {
    postgresConnectionString = `postgresql://${dbUser}:${dbPassword}@${args.postgresHost}:${args.postgresPort}/${dbName}`;
  }
  return postgresConnectionString;
};
