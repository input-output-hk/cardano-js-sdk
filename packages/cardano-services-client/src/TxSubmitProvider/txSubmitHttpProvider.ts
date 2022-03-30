import {
  // eslint-disable-next-line @typescript-eslint/ban-ts-comment
  // @ts-ignore
  Cardano,
  ProviderError,
  ProviderFailure,
  TxSubmitProvider
} from '@cardano-sdk/core';
import { deserializeError } from 'serialize-error';
import got from 'got';
// eslint-disable-next-line @typescript-eslint/ban-ts-comment
// @ts-ignore
import type ConnectionConfig from '@cardano-sdk/cardano-graphql-services';

/**
 * Connect to a TxSubmitHttpServer instance
 *
 * @param {ConnectionConfig} connectionConfig Service connection configuration
 * @returns {TxSubmitProvider} TxSubmitProvider
 * @throws {Cardano.TxSubmissionErrors}
 */
export const txSubmitHttpProvider = (connectionConfig: { url: string }): TxSubmitProvider => ({
  async healthCheck() {
    try {
      const response = await got.get(`${connectionConfig.url}/health`);
      return JSON.parse(response.body);
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
    } catch (error: any) {
      if (error.name === 'RequestError') {
        return { ok: false };
      }
      throw new ProviderError(ProviderFailure.Unknown, error);
    }
  },
  async submitTx(tx: Uint8Array) {
    try {
      await got.post(`${connectionConfig.url}/submit`, {
        body: Buffer.from(tx),
        headers: { 'Content-Type': 'application/cbor' }
      });
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
    } catch (error: any) {
      const domainErrors = JSON.parse(error?.response?.body || null) as null | string | string[];
      if (Array.isArray(domainErrors)) {
        throw domainErrors.map((e: string) => deserializeError(e));
      } else if (domainErrors !== null) {
        throw deserializeError(domainErrors);
      }
      throw new ProviderError(ProviderFailure.Unknown, error);
    }
  }
});
