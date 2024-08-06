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
import { isConnectionError, toSerializableObject } from '@cardano-sdk/util';
import connString from 'pg-connection-string';
import fs from 'fs';

const TIMEOUT = 60 * 1000;

const timedQuery = (pool: Pool, logger: Logger) => async (args: string | QueryConfig, values?: any) => {
  const startTime = Date.now();
  const result = await pool.query(args, values);
  const query =
    typeof args === 'string'
      ? `${args} ${JSON.stringify(toSerializableObject(values))}\nMISSING PREPARED STATEMENT`
      : 'text' in args && typeof args.text === 'string'
      ? `${args.text} ${JSON.stringify(toSerializableObject(args.values))}`
      : `${JSON.stringify(toSerializableObject({ args, values }))}\nUNEXPECTED QUERY FORMAT`;

  logger.debug(`Query\n${query}\ntook ${Date.now() - startTime} milliseconds`);

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
  let pool = new Pool({
    connectionTimeoutMillis: TIMEOUT,
    database,
    host: name,
    max,
    password,
    port,
    query_timeout: TIMEOUT,
    ssl,
    user
  });

  return new Proxy<Pool>({} as Pool, {
    get(_, prop, receiver) {
      if (prop === 'then') return;
      if (prop === 'query') {
        return (args: string | QueryConfig, values?: any) =>
          timedQuery(pool, logger)(args, values).catch(async (error) => {
            if (isConnectionError(error)) {
              const record = await dnsResolver(host!);
              logger.info(`DNS resolution for Postgres service, resolved with record: ${JSON.stringify(record)}`);
              pool = new Pool({
                connectionTimeoutMillis: TIMEOUT,
                database,
                host: record.name,
                max,
                password,
                port: record.port,
                query_timeout: TIMEOUT,
                ssl,
                user
              });
              return timedQuery(receiver, logger)(args, values);
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
    : ssl || !!conn.ssl;

export const connStringToPgConnectionConfig = (
  postgresConnectionString: string,
  {
    poolSize,
    ssl
  }: {
    poolSize?: number;
    ssl?: { ca: string };
  } = {}
): PgConnectionConfig => {
  const conn = connString.parse(postgresConnectionString);
  if (!conn.database || !conn.host) {
    throw new InvalidProgramOption('postgresConnectionString');
  }
  return {
    database: conn.database,
    host: conn.host,
    password: conn.password,
    poolSize,
    port: conn.port ? Number.parseInt(conn.port) : undefined,
    ssl: mergeTlsOptions(conn, ssl),
    username: conn.user
  };
};

export const getConnectionConfig = <Suffix extends ConnectionNames>(
  dnsResolver: DnsResolver,
  program: string,
  suffix: Suffix,
  options?: PosgresProgramOptions<Suffix>
): Observable<PgConnectionConfig> => {
  const max = getPostgresOption(suffix, 'postgresPoolMax', options);
  const postgresConnectionString = getPostgresOption(suffix, 'postgresConnectionString', options);
  const postgresSslCaFile = getPostgresOption(suffix, 'postgresSslCaFile', options);
  const ssl = postgresSslCaFile ? { ca: loadSecret(postgresSslCaFile) } : undefined;

  if (postgresConnectionString) {
    return of(connStringToPgConnectionConfig(postgresConnectionString, { poolSize: max, ssl }));
  }

  const postgresDb = getPostgresOption(suffix, 'postgresDb', options);
  const postgresPassword = getPostgresOption(suffix, 'postgresPassword', options);
  const postgresSrvServiceName = getPostgresOption(suffix, 'postgresSrvServiceName', options);
  const postgresUser = getPostgresOption(suffix, 'postgresUser', options);

  if (postgresSrvServiceName && postgresUser && postgresDb && postgresPassword) {
    return defer(() =>
      from(
        dnsResolver(postgresSrvServiceName).then(
          (record): PgConnectionConfig => ({
            database: postgresDb,
            host: record.name,
            password: postgresPassword,
            port: record.port,
            ssl,
            username: postgresUser
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
      connectionTimeoutMillis: TIMEOUT,
      max: options.postgresPoolMaxDbSync,
      query_timeout: TIMEOUT,
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
