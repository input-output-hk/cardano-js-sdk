import { Cardano, ProviderError, ProviderFailure, TxBodyCBOR } from '@cardano-sdk/core';
import { hexStringToBuffer } from '@cardano-sdk/util';
import { mapCardanoTxSubmitError } from './cardanoTxSubmitErrorMapper.js';
import axios from 'axios';
import type { AxiosAdapter, AxiosInstance } from 'axios';
import type { Logger } from 'ts-log';
import type { SubmitTxArgs, TxSubmitProvider } from '@cardano-sdk/core';

export type TxSubmitApiProviderProperties = {
  baseUrl: URL;
  path?: string;
};

export type TxSubmitApiProviderDependencies = {
  logger: Logger;
  adapter?: AxiosAdapter;
};

export class TxSubmitApiProvider implements TxSubmitProvider {
  #axios: AxiosInstance;
  #healthStatus = true;
  #logger: Logger;
  #path: string;
  #adapter?: AxiosAdapter;

  constructor(
    { baseUrl, path = '/api/submit/tx' }: TxSubmitApiProviderProperties,
    { logger, adapter }: TxSubmitApiProviderDependencies
  ) {
    this.#axios = axios.create({ baseURL: baseUrl.origin });
    this.#logger = logger;
    this.#path = path;
    this.#adapter = adapter;
  }

  async submitTx({ signedTransaction }: SubmitTxArgs) {
    let txId: Cardano.TransactionId | undefined;

    try {
      txId = Cardano.TransactionId.fromTxBodyCbor(TxBodyCBOR.fromTxCBOR(signedTransaction));

      this.#logger.debug(`Submitting tx ${txId} ...`);

      await this.#axios({
        adapter: this.#adapter,
        data: hexStringToBuffer(signedTransaction),
        headers: { 'Content-Type': 'application/cbor' },
        method: 'post',
        url: this.#path
      });

      this.#healthStatus = true;
      this.#logger.debug(`Tx ${txId} submitted`);
    } catch (error) {
      this.#healthStatus = false;
      this.#logger.error(`Tx ${txId} submission error`);
      this.#logger.error(error);

      if (axios.isAxiosError(error) && error.response) {
        const { data, status } = error.response;

        if (typeof status === 'number' && status >= 400 && status < 500) this.#healthStatus = true;

        throw new ProviderError(
          ProviderFailure.BadRequest,
          mapCardanoTxSubmitError(data),
          typeof data === 'string' ? data : JSON.stringify(data)
        );
      }

      throw new ProviderError(ProviderFailure.Unknown, error, 'submitting tx');
    }
  }

  healthCheck() {
    return Promise.resolve({ ok: this.#healthStatus });
  }
}
