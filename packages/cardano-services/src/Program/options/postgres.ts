import { Command } from 'commander';
import { addOptions, newOption } from './util';
import { existingFileValidator, integerValidator } from '../../util/validators';

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

export interface BasePosgresProgramOptions {
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

export type ConnectionNames = 'DbSync' | 'Handle' | 'StakePool' | 'Asset' | '';

export type PosgresProgramOptions<
  Suffix extends ConnectionNames,
  Options extends keyof BasePosgresProgramOptions = keyof BasePosgresProgramOptions
> = { [k in Options as `${k}${Suffix}`]?: BasePosgresProgramOptions[k] };

export const getPostgresOption = <Suffix extends ConnectionNames, Options extends keyof BasePosgresProgramOptions>(
  suffix: Suffix,
  option: Options,
  args: PosgresProgramOptions<Suffix, Options> | undefined
) => args?.[`${option}${suffix}`] as BasePosgresProgramOptions[typeof option];

export const suffixType2Cli = (suffix: ConnectionNames) => suffix.replace(/[A-Z]/g, (_) => `-${_.toLowerCase()}`);

export const withPostgresOptions = (command: Command, suffixes: ConnectionNames[]) => {
  for (const suffix of suffixes) {
    const cliSuffix = suffix ? suffixType2Cli(suffix) : '';
    const dscSuffix = suffix ? suffix.replace(/[A-Z]/g, (_) => ` ${_.toLowerCase()}`) : '';
    const envSuffix = suffix ? suffix.replace(/[A-Z]/g, (_) => `_${_}`).replace(/[a-z]/g, (_) => _.toUpperCase()) : '';

    const descSuffix = ` for${dscSuffix}`;

    addOptions(command, [
      newOption(
        `--postgres-connection-string${cliSuffix} <postgresConnectionString${suffix}>`,
        PostgresOptionDescriptions.ConnectionString + descSuffix,
        `POSTGRES_CONNECTION_STRING${envSuffix}`
      )
        .conflicts(`postgresSrvServiceName${suffix}`)
        .conflicts(`postgresDb${suffix}`)
        .conflicts(`postgresDbFile${suffix}`)
        .conflicts(`postgresUser${suffix}`)
        .conflicts(`postgresUserFile${suffix}`)
        .conflicts(`postgresPassword${suffix}`)
        .conflicts(`postgresPasswordFile${suffix}`)
        .conflicts(`postgresHost${suffix}`)
        .conflicts(`postgresPort${suffix}`),
      newOption(
        `--postgres-srv-service-name${cliSuffix} <postgresSrvServiceName${suffix}>`,
        PostgresOptionDescriptions.SrvServiceName + descSuffix,
        `POSTGRES_SRV_SERVICE_NAME${envSuffix}`
      )
        .conflicts(`postgresHost${suffix}`)
        .conflicts(`postgresPort${suffix}`),
      newOption(
        `--postgres-db${cliSuffix} <postgresDb${suffix}>`,
        PostgresOptionDescriptions.Db + descSuffix,
        `POSTGRES_DB${envSuffix}`
      ).conflicts(`postgresDbFile${suffix}`),
      newOption(
        `--postgres-db-file${cliSuffix} <postgresDbFile${suffix}>`,
        PostgresOptionDescriptions.DbFile + descSuffix,
        `POSTGRES_DB_FILE${envSuffix}`,
        existingFileValidator
      ),
      newOption(
        `--postgres-user${cliSuffix} <postgresUser${suffix}>`,
        PostgresOptionDescriptions.User + descSuffix,
        `POSTGRES_USER${envSuffix}`
      ).conflicts(`postgresUserFile${suffix}`),
      newOption(
        `--postgres-user-file${cliSuffix} <postgresUserFile${suffix}>`,
        PostgresOptionDescriptions.UserFile + descSuffix,
        `POSTGRES_USER_FILE${envSuffix}`,
        existingFileValidator
      ),
      newOption(
        `--postgres-password${cliSuffix} <postgresPassword${suffix}>`,
        PostgresOptionDescriptions.Password + descSuffix,
        `POSTGRES_PASSWORD${envSuffix}`
      ).conflicts(`postgresPasswordFile${suffix}`),
      newOption(
        `--postgres-password-file${cliSuffix} <postgresPasswordFile${suffix}>`,
        PostgresOptionDescriptions.PasswordFile + descSuffix,
        `POSTGRES_PASSWORD_FILE${envSuffix}`,
        existingFileValidator
      ),
      newOption(
        `--postgres-host${cliSuffix} <postgresHost${suffix}>`,
        PostgresOptionDescriptions.Host + descSuffix,
        `POSTGRES_HOST${envSuffix}`
      ),
      newOption(
        `--postgres-pool-max${cliSuffix} <postgresPoolMax${suffix}>`,
        PostgresOptionDescriptions.PoolMax + descSuffix,
        `POSTGRES_POOL_MAX${envSuffix}`,
        integerValidator(PostgresOptionDescriptions.PoolMax + descSuffix)
      ),
      newOption(
        `--postgres-port${cliSuffix} <postgresPort${suffix}>`,
        PostgresOptionDescriptions.Port + descSuffix,
        `POSTGRES_PORT${envSuffix}`
      ),
      newOption(
        `--postgres-ssl-ca-file${cliSuffix} <postgresSslCaFile${suffix}>`,
        PostgresOptionDescriptions.SslCaFile + descSuffix,
        `POSTGRES_SSL_CA_FILE${envSuffix}`
      )
    ]);
  }

  return command;
};
