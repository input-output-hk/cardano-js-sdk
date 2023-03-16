import { Command, Option } from 'commander';
import { existingFileValidator } from '../../util/validators';

export enum PostgresOptionDescriptions {
  ConnectionString = 'PostgreSQL Connection string',
  SrvServiceName = 'PostgreSQL SRV service name when using service discovery',
  Db = 'PostgreSQL database name',
  DbFile = 'PostgreSQL database name file path',
  User = 'PostgreSQL user',
  UserFile = 'PostgreSQL user file path',
  Password = 'PostgreSQL password',
  PasswordFile = 'PostgreSQL password file path',
  SslCaFile = 'PostgreSQL SSL CA file path',
  Host = 'PostgreSQL host',
  Port = 'PostgreSQL port',
  PoolMax = 'Maximum number of clients in the PostgreSQL pool',
  ServiceDiscoveryArgs = 'Postgres SRV service name, db, user and password'
}

export interface PosgresProgramOptions {
  postgresConnectionString?: string;
  postgresSrvServiceName?: string;
  postgresDb?: string;
  postgresDbFile?: string;
  postgresUser?: string;
  postgresUserFile?: string;
  postgresPassword?: string;
  postgresPasswordFile?: string;
  postgresHost?: string;
  postgresPoolMax?: number;
  postgresPort?: string;
  postgresSslCaFile?: string;
}

export const withPostgresOptions = (command: Command) =>
  command
    .addOption(
      new Option('--postgres-connection-string <postgresConnectionString>', PostgresOptionDescriptions.ConnectionString)
        .env('POSTGRES_CONNECTION_STRING')
        .conflicts('postgresSrvServiceName')
        .conflicts('postgresDb')
        .conflicts('postgresDbFile')
        .conflicts('postgresUser')
        .conflicts('postgresUserFile')
        .conflicts('postgresPassword')
        .conflicts('postgresPasswordFile')
        .conflicts('postgresHost')
        .conflicts('postgresPort')
    )
    .addOption(
      new Option('--postgres-srv-service-name <postgresSrvServiceName>', PostgresOptionDescriptions.SrvServiceName)
        .env('POSTGRES_SRV_SERVICE_NAME')
        .conflicts('postgresHost')
        .conflicts('postgresPort')
    )
    .addOption(
      new Option('--postgres-db <postgresDb>', PostgresOptionDescriptions.Db)
        .env('POSTGRES_DB')
        .conflicts('postgresDbFile')
    )
    .addOption(
      new Option('--postgres-db-file <postgresDbFile>', PostgresOptionDescriptions.DbFile)
        .env('POSTGRES_DB_FILE')
        .argParser(existingFileValidator)
    )
    .addOption(
      new Option('--postgres-user <postgresUser>', PostgresOptionDescriptions.User)
        .env('POSTGRES_USER')
        .conflicts('postgresUserFile')
    )
    .addOption(
      new Option('--postgres-user-file <postgresUserFile>', PostgresOptionDescriptions.UserFile)
        .env('POSTGRES_USER_FILE')
        .argParser(existingFileValidator)
    )
    .addOption(
      new Option('--postgres-password <postgresPassword>', PostgresOptionDescriptions.Password)
        .env('POSTGRES_PASSWORD')
        .conflicts('postgresPasswordFile')
    )
    .addOption(
      new Option('--postgres-password-file <postgresPasswordFile>', PostgresOptionDescriptions.PasswordFile)
        .env('POSTGRES_PASSWORD_FILE')
        .argParser(existingFileValidator)
    )
    .addOption(new Option('--postgres-host <postgresHost>', PostgresOptionDescriptions.Host).env('POSTGRES_HOST'))
    .addOption(
      new Option('--postgres-pool-max <postgresPoolMax>', PostgresOptionDescriptions.PoolMax)
        .env('POSTGRES_POOL_MAX')
        .argParser((max) => Number.parseInt(max, 10))
    )
    .addOption(new Option('--postgres-port <postgresPort>', PostgresOptionDescriptions.Port).env('POSTGRES_PORT'))
    .addOption(
      new Option('--postgres-ssl-ca-file <postgresSslCaFile>', PostgresOptionDescriptions.SslCaFile).env(
        'POSTGRES_SSL_CA_FILE'
      )
    );
