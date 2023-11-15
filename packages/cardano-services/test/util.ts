/* eslint-disable @typescript-eslint/no-explicit-any */
import { DbPools } from '../src/util/DbSyncProvider';
import { Pool } from 'pg';
import { ServiceNames } from '../src';
import { of } from 'rxjs';
import { versionPathFromSpec } from '../src/util/openApi';
import axios, { AxiosRequestConfig } from 'axios';
import path from 'path';
import waitOn from 'wait-on';

type WrappedAsyncTestFunction = (db: Pool) => Promise<any>;
type AsyncTestFunction = () => Promise<any>;

/**
 * Consider the server started when the base API url returns 404 status code
 *
 * @param apiUrl server base url
 * @param statusCodeMatch expected status code to validate with
 * @param headers headers needed in case of CORS enabled
 */
export const serverStarted = (apiUrl: string, statusCodeMatch = 404, headers?: Record<string, any>): Promise<void> =>
  waitOn({
    headers,
    resources: [apiUrl],
    validateStatus: (status: number) => status === statusCodeMatch
  });

export const doServerRequest =
  (apiBaseUrl: string) =>
  async <Args, Response>(url: string, args: Args, extraOptions: AxiosRequestConfig = {}) =>
    (await axios.post(`${apiBaseUrl}${url}`, { ...args }, extraOptions)).data as Promise<Response>;

export const ingestDbData = async (db: Pool, tableName: string, columns: string[], values: any[]) => {
  const columnsPlaceholder = columns.toString();
  const valuesPlaceholder = Array.from({ length: values.length }, (_, i) => `$${i + 1}`).toString();
  const sqlString = `INSERT INTO ${tableName} (${columnsPlaceholder})
                     VALUES (${valuesPlaceholder});`;

  await db.query(sqlString, values);
};

export const deleteDbData = async (db: Pool, tableName: string, field: string, value: any) => {
  const sqlString = `DELETE
                     FROM ${tableName}
                     WHERE ${field} = ${value};`;

  await db.query(sqlString);
};

export const emptyDbData = async (db: Pool, tableName: string) => {
  const sqlString = `TRUNCATE ${tableName}`;

  await db.query(sqlString);
};

/**
 * Wraps integration test within a transaction and once test has finished, rollback is executed
 * Guarantee that db state remains clean after data ingestion needed for specific test cases
 */
export const wrapWithTransaction =
  (testFunction: WrappedAsyncTestFunction, db: Pool): AsyncTestFunction =>
  async () => {
    await db.query('START TRANSACTION');
    return Promise.resolve(testFunction(db).then(() => db.query('ROLLBACK')));
  };

export const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

export const clearDbPools = async ({ main, healthCheck }: DbPools) => {
  await main?.end();
  await healthCheck?.end();
};

export const projectorConnectionConfig = {
  database: process.env.POSTGRES_DB_STAKE_POOLS!,
  host: process.env.POSTGRES_HOST_DB_SYNC!,
  password: process.env.POSTGRES_PASSWORD_DB_SYNC!,
  port: Number.parseInt(process.env.POSTGRES_PORT_DB_SYNC!),
  username: process.env.POSTGRES_USER_DB_SYNC!
};
export const projectorConnectionConfig$ = of(projectorConnectionConfig);

export const baseVersionPath = versionPathFromSpec(path.join(__dirname, '..', 'src', 'Http', 'openApi.json'));

const versionPathForService = (serviceName: string) =>
  versionPathFromSpec(path.join(__dirname, '..', 'src', serviceName, 'openApi.json'));

export const servicesWithVersionPath = {
  asset: {
    name: ServiceNames.Asset,
    versionPath: versionPathForService('Asset')
  },
  chainHistory: {
    name: ServiceNames.ChainHistory,
    versionPath: versionPathForService('ChainHistory')
  },
  networkInfo: {
    name: ServiceNames.NetworkInfo,
    versionPath: versionPathForService('NetworkInfo')
  },
  rewards: {
    name: ServiceNames.Rewards,
    versionPath: versionPathForService('Rewards')
  },
  stakePool: {
    name: ServiceNames.StakePool,
    versionPath: versionPathForService('StakePool')
  },
  txSubmit: {
    name: ServiceNames.TxSubmit,
    versionPath: versionPathForService('TxSubmit')
  },
  utxo: {
    name: ServiceNames.Utxo,
    versionPath: versionPathForService('Utxo')
  }
};
