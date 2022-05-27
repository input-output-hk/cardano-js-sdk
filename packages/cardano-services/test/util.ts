import { Connection, createConnectionObject } from '@cardano-ogmios/client';
import { createMockOgmiosServer } from '@cardano-sdk/ogmios/test/mocks/mockOgmiosServer';
import { getRandomPort } from 'get-port-please';
import axios, { AxiosRequestConfig } from 'axios';
import waitOn from 'wait-on';

export const serverReady = (apiUrl: string, statusCodeMatch = 404): Promise<void> =>
  waitOn({
    resources: [apiUrl],
    validateStatus: (status: number) => status === statusCodeMatch
  });

export const ogmiosServerReady = (connection: Connection): Promise<void> => serverReady(connection.address.http, 405);

export const createHealthyMockOgmiosServer = (submitTxHook?: () => void) =>
  createMockOgmiosServer({
    healthCheck: { response: { networkSynchronization: 0.999, success: true } },
    submitTx: { response: { success: true } },
    submitTxHook
  });

export const createUnhealthyMockOgmiosServer = () =>
  createMockOgmiosServer({
    healthCheck: { response: { networkSynchronization: 0.8, success: true } },
    submitTx: { response: { success: false } }
  });

export const createConnectionObjectWithRandomPort = async () => createConnectionObject({ port: await getRandomPort() });

export const doServerRequest =
  (apiBaseUrl: string) =>
  async <Args, Response>(url: string, args: Args, extraOptions: AxiosRequestConfig = {}) =>
    (await axios.post(`${apiBaseUrl}${url}`, { args }, extraOptions)).data as Promise<Response>;
