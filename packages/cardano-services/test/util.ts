/* eslint-disable @typescript-eslint/no-explicit-any */
import { DbPools } from '../src/util/DbSyncProvider';
import { Ogmios } from '@cardano-sdk/ogmios';
import { Pool } from 'pg';
import { createMockOgmiosServer } from '../../ogmios/test/mocks/mockOgmiosServer';
import { getRandomPort } from 'get-port-please';
import { of } from 'rxjs';
import axios, { AxiosRequestConfig } from 'axios';
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

export const ogmiosServerReady = (connection: Ogmios.Connection): Promise<void> =>
  serverStarted(connection.address.http, 405);

export const createHealthyMockOgmiosServer = (submitTxHook?: () => void) =>
  createMockOgmiosServer({
    healthCheck: { response: { networkSynchronization: 0.999, success: true } },
    stateQuery: {
      eraSummaries: { response: { success: true } },
      stakeDistribution: { response: { success: true } },
      systemStart: { response: { success: true } }
    },
    submitTx: { response: { success: true } },
    submitTxHook
  });

export const createUnhealthyMockOgmiosServer = () =>
  createMockOgmiosServer({
    healthCheck: { response: { networkSynchronization: 0.8, success: true } },
    stateQuery: { eraSummaries: { response: { success: false } }, systemStart: { response: { success: false } } },
    submitTx: { response: { success: false } }
  });

export const createConnectionObjectWithRandomPort = async () =>
  Ogmios.createConnectionObject({ port: await getRandomPort() });

export const doServerRequest =
  (apiBaseUrl: string) =>
  async <Args, Response>(url: string, args: Args, extraOptions: AxiosRequestConfig = {}) =>
    (await axios.post(`${apiBaseUrl}${url}`, { ...args }, extraOptions)).data as Promise<Response>;

export const ingestDbData = async (db: Pool, tableName: string, columns: string[], values: any[]) => {
  const columnsPlaceholder = columns.toString();
  const valuesPlaceholder = Array.from({ length: values.length }, (_, i) => `$${i + 1}`).toString();
  const sqlString = `INSERT INTO ${tableName} (${columnsPlaceholder}) VALUES (${valuesPlaceholder});`;

  await db.query(sqlString, values);
};

export const deleteDbData = async (db: Pool, tableName: string, field: string, value: any) => {
  const sqlString = `DELETE FROM ${tableName} WHERE ${field} = ${value};`;

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
  database: process.env.POSTGRES_DB_PROJECTION!,
  host: process.env.POSTGRES_HOST!,
  password: process.env.POSTGRES_PASSWORD!,
  port: Number.parseInt(process.env.POSTGRES_PORT!),
  username: process.env.POSTGRES_USER!
};
export const projectorConnectionConfig$ = of(projectorConnectionConfig);
