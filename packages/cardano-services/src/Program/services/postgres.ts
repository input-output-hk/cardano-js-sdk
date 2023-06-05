/* eslint-disable promise/no-nesting */
/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable unicorn/no-nested-ternary */
import { ConnectionNames, PosgresProgramOptions, getPostgresOption } from '../options/postgres';
import { DnsResolver } from '../utils';
import { InvalidProgramOption, MissingProgramOption } from '../errors';
import { Logger } from 'ts-log';
import { Observable, defer, from, of } from 'rxjs';
import { PgConnectionConfig } from '@cardano-sdk/projection-typeorm';
import { Pool, PoolConfig, QueryConfig } from 'pg';
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
  program: string,
  options?: PosgresProgramOptions<'StakePool'>
): Observable<PgConnectionConfig> => {
  const ssl = options?.postgresSslCaFileStakePool ? { ca: loadSecret(options.postgresSslCaFileStakePool) } : undefined;
  if (options?.postgresConnectionStringStakePool) {
    const conn = connString.parse(options.postgresConnectionStringStakePool);
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

  if (
    options?.postgresSrvServiceNameStakePool &&
    options.postgresUserStakePool &&
    options.postgresDbStakePool &&
    options.postgresPasswordStakePool
  ) {
    return defer(() =>
      from(
        dnsResolver(options.postgresSrvServiceNameStakePool!).then(
          (record): PgConnectionConfig => ({
            database: options.postgresDbStakePool,
            host: record.name,
            password: options.postgresPasswordStakePool,
            port: record.port,
            ssl,
            username: options.postgresUserStakePool
          })
        )
      )
    );
  }

  throw new MissingProgramOption(program, [
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
  options?: PosgresProgramOptions<'DbSync'>
): Promise<Pool | undefined> => {
  const ssl = options?.postgresSslCaFileDbSync ? { ca: loadSecret(options.postgresSslCaFileDbSync) } : undefined;

  if (options?.postgresConnectionStringDbSync) {
    const pool = new Pool({
      connectionString: options.postgresConnectionStringDbSync,
      max: options.postgresPoolMaxDbSync,
      ssl
    });

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

  if (
    options?.postgresSrvServiceNameDbSync &&
    options.postgresUserDbSync &&
    options.postgresDbDbSync &&
    options.postgresPasswordDbSync
  ) {
    return getPoolWithServiceDiscovery(dnsResolver, logger, {
      database: options.postgresDbDbSync,
      host: options.postgresSrvServiceNameDbSync,
      max: options.postgresPoolMaxDbSync,
      password: options.postgresPasswordDbSync,
      ssl,
      user: options.postgresUserDbSync
    });
  }
  // If db connection string is not passed nor postgres srv service name
  return undefined;
};

const getSecret = (secretFilePath?: string, secret?: string) =>
  secretFilePath ? loadSecret(secretFilePath) : secret ? secret : undefined;

export const connectionStringFromArgs = <Suffix extends ConnectionNames>(
  args: PosgresProgramOptions<Suffix>,
  suffix: Suffix
) => {
  const dbName = getSecret(
    getPostgresOption(suffix, 'postgresDbFile', args),
    getPostgresOption(suffix, 'postgresDb', args)
  );
  const dbUser = getSecret(
    getPostgresOption(suffix, 'postgresUserFile', args),
    getPostgresOption(suffix, 'postgresUser', args)
  );
  const dbPassword = getSecret(
    getPostgresOption(suffix, 'postgresPasswordFile', args),
    getPostgresOption(suffix, 'postgresPassword', args)
  );

  // Setting the connection string takes preference over secrets.
  // It can also remain undefined since there is no a default value. Usually used locally with static config.
  let postgresConnectionString = getPostgresOption(suffix, 'postgresConnectionString', args);

  if (postgresConnectionString) {
    postgresConnectionString = new URL(postgresConnectionString).toString();
  } else {
    const postgresHost = getPostgresOption(suffix, 'postgresHost', args);
    const postgresPort = getPostgresOption(suffix, 'postgresPort', args);

    if (dbName && dbPassword && dbUser && postgresHost && postgresPort)
      postgresConnectionString = `postgresql://${dbUser}:${dbPassword}@${postgresHost}:${postgresPort}/${dbName}`;
  }

  return postgresConnectionString;
};
