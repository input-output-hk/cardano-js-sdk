/* eslint-disable promise/no-nesting */
/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable unicorn/no-nested-ternary */
import { DnsResolver } from '../utils';
import { InvalidProgramOption, MissingProgramOption } from '../errors';
import { Logger } from 'ts-log';
import { Observable, defer, from, of } from 'rxjs';
import { PgConnectionConfig } from '@cardano-sdk/projection-typeorm';
import { Pool, PoolConfig, QueryConfig } from 'pg';
import { PosgresProgramOptions } from '../options';
import { TlsOptions } from 'tls';
import { URL } from 'url';
import { isConnectionError } from '@cardano-sdk/util';
import connString from 'pg-connection-string';
import fs from 'fs';

const timedQuery = (pool: Pool, logger: Logger) => async (args: string | QueryConfig, values?: any) => {
  const startTime = Date.now();
  const result = await pool.query(args, values);
  logger.debug(`Query\n${args}\ntook ${Date.now() - startTime} milliseconds`);
  return result;
};

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
  { host, database, max, password, ssl, user }: PoolConfig
): Promise<Pool> => {
  const { name, port } = await dnsResolver(host!);
  let pool = new Pool({ database, host: name, max, password, port, ssl, user });

  return new Proxy<Pool>({} as Pool, {
    get(_, prop) {
      if (prop === 'then') return;
      if (prop === 'query') {
        return (args: string | QueryConfig, values?: any) =>
          timedQuery(pool, logger)(args, values).catch(async (error) => {
            if (isConnectionError(error)) {
              const record = await dnsResolver(host!);
              logger.info(`DNS resolution for Postgres service, resolved with record: ${JSON.stringify(record)}`);
              pool = new Pool({ database, host: record.name, max, password, port: record.port, ssl, user });
              return timedQuery(pool, logger)(args, values);
            }
            throw error;
          });
      }
      // Bind if it is a function, no intercept operations
      if (typeof pool[prop as keyof Pool] === 'function') {
        const method = pool[prop as keyof Pool] as any;
        return method.bind(pool);
      }

      return pool[prop as keyof Pool];
    }
  });
};

export const loadSecret = (path: string) => fs.readFileSync(path, 'utf8').toString();

// types of 'pg-connection-string' seem to be incorrect:
// according to documentation it is either a boolean or a compatible TlsOptions object.
const mergeTlsOptions = (
  conn: connString.ConnectionOptions,
  ssl: { ca: string } | undefined
): boolean | TlsOptions | undefined =>
  typeof conn.ssl === 'object'
    ? {
        ...(conn.ssl as TlsOptions),
        ca: ssl?.ca || (conn.ssl as TlsOptions).ca
      }
    : (conn.ssl as boolean | undefined);

export const getConnectionConfig = (
  dnsResolver: DnsResolver,
  options?: PosgresProgramOptions
): Observable<PgConnectionConfig> => {
  const ssl = options?.postgresSslCaFile ? { ca: loadSecret(options.postgresSslCaFile) } : undefined;
  if (options?.postgresConnectionString) {
    const conn = connString.parse(options.postgresConnectionString);
    if (!conn.database || !conn.host) {
      throw new InvalidProgramOption('postgresConnectionString');
    }
    return of({
      database: conn.database,
      host: conn.host,
      password: conn.password,
      port: conn.port ? Number.parseInt(conn.port) : undefined,
      ssl: mergeTlsOptions(conn, ssl),
      username: conn.user
    });
  }

  if (options?.postgresSrvServiceName && options.postgresUser && options.postgresDb && options.postgresPassword) {
    return defer(() =>
      from(
        dnsResolver(options.postgresSrvServiceName!).then(
          (record): PgConnectionConfig => ({
            database: options.postgresDb,
            host: record.name,
            password: options.postgresPassword,
            port: record.port,
            ssl,
            username: options.postgresUser
          })
        )
      )
    );
  }

  throw new MissingProgramOption('projector', [
    'postgresConnectionString',
    'postgresSrvServiceName',
    'postgresUser',
    'postgresDb',
    'postgresPassword'
  ]);
};

export const getPool = async (
  dnsResolver: DnsResolver,
  logger: Logger,
  options?: PosgresProgramOptions
): Promise<Pool | undefined> => {
  const ssl = options?.postgresSslCaFile ? { ca: loadSecret(options.postgresSslCaFile) } : undefined;

  if (options?.postgresConnectionString) {
    const pool = new Pool({ connectionString: options.postgresConnectionString, max: options.postgresPoolMax, ssl });

    return new Proxy<Pool>({} as Pool, {
      get(_, prop) {
        if (prop === 'then') return;
        if (prop === 'query') {
          return timedQuery(pool, logger);
        }
        // Bind if it is a function, no intercept operations
        if (typeof pool[prop as keyof Pool] === 'function') {
          const method = pool[prop as keyof Pool] as any;
          return method.bind(pool);
        }

        return pool[prop as keyof Pool];
      }
    });
  }

  if (options?.postgresSrvServiceName && options.postgresUser && options.postgresDb && options.postgresPassword) {
    return getPoolWithServiceDiscovery(dnsResolver, logger, {
      database: options.postgresDb,
      host: options.postgresSrvServiceName,
      max: options.postgresPoolMax,
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

export const connectionStringFromArgs = (args: PosgresProgramOptions) => {
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
