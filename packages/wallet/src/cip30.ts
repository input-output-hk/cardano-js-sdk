import {
  ApiError,
  Bytes,
  Cbor,
  Cip30DataSignature,
  Paginate,
  TxSignError,
  TxSignErrorCode,
  WalletApi,
  handleMessages
} from '@cardano-sdk/cip30';
import { AuthenticationError } from './KeyManagement/errors';
import { CSL, Cardano, coreToCsl, cslToCore } from '@cardano-sdk/core';
import { InputSelectionError } from '@cardano-sdk/cip2';
import { Logger, dummyLogger } from 'ts-log';
import { SingleAddressWallet } from '.';
import { cip30signData } from './KeyManagement/cip8';
import { firstValueFrom } from 'rxjs';

export type Cip30WalletDependencies = {
  logger?: Logger;
};

export const createWalletApi = (
  wallet: SingleAddressWallet,
  { logger = dummyLogger }: Cip30WalletDependencies = {}
): WalletApi => ({
  getBalance: async (): Promise<Cbor> => {
    logger.debug('getting balance');
    try {
      const value = await firstValueFrom(wallet.balance.available$);
      return Buffer.from(coreToCsl.value(value).to_bytes()).toString('hex');
    } catch (error) {
      logger.error(error);
      throw error;
    }
  },
  getChangeAddress: async (): Promise<Cbor> => {
    logger.debug('getting changeAddress');
    try {
      const [{ address }] = await firstValueFrom(wallet.addresses$);

      if (!address) {
        logger.error('could not get change address');
        throw new ApiError(500, 'could not get change address');
      } else {
        return address.toString();
      }
    } catch (error) {
      logger.error(error);
      if (error instanceof ApiError) {
        throw error;
      }
      throw new ApiError(500, 'Nope');
    }
  },
  getNetworkId: async (): Promise<number> => {
    logger.debug('getting networkId');
    return Promise.resolve(wallet.keyAgent.networkId);
  },
  getRewardAddresses: async (): Promise<Cbor[]> => {
    logger.debug('getting reward addresses');
    try {
      const [{ rewardAccount }] = await firstValueFrom(wallet.addresses$);

      if (!rewardAccount) {
        throw new ApiError(500, 'could not get reward address');
      } else {
        return [rewardAccount.toString()];
      }
    } catch (error) {
      logger.error(error);
      if (error instanceof ApiError) {
        throw error;
      }
      throw new ApiError(500, 'Nope');
    }
  },
  getUnusedAddresses: async (): Promise<Cbor[]> => {
    logger.debug('getting unused addresses');
    return Promise.resolve([]);
  },
  getUsedAddresses: async (_paginate?: Paginate): Promise<Cbor[]> => {
    logger.debug('getting changeAddress');

    const [{ address }] = await firstValueFrom(wallet.addresses$);

    if (!address) {
      throw new ApiError(500, 'could not get used addresses');
    } else {
      return [address.toString()];
    }
  },
  getUtxos: async (amount?: Cbor, paginate?: Paginate): Promise<Cardano.Utxo[] | undefined> => {
    let utxos = await firstValueFrom(wallet.utxo.available$);

    if (amount) {
      try {
        const filterAmount = CSL.Value.from_bytes(Buffer.from(amount, 'hex'));
        /**
         * Getting UTxOs to meet a required amount is a complex operation,
         * which is handled by input selection capabilities. By initializing
         * a transaction we're able to utilise the internal configuration and
         * algorithm to make this selection, using a wallet address to
         * satisfy the interface only.
         */
        const { inputSelection } = await wallet.initializeTx({
          outputs: new Set([{ address: wallet.addresses$.value![0].address, value: cslToCore.value(filterAmount) }])
        });

        utxos = [...inputSelection.inputs];
      } catch (error) {
        logger.debug(error);
        const message = error instanceof InputSelectionError ? error.message : 'Nope';
        throw new ApiError(400, message);
      }
    } else if (paginate) {
      utxos = utxos.slice(paginate.page * paginate.limit, paginate.page * paginate.limit + paginate.limit);
    }

    return Promise.resolve(utxos);
  },
  signData: async (addr: Cardano.Address, payload: Bytes): Promise<Cip30DataSignature> => {
    logger.debug('signData');
    return cip30signData({
      keyAgent: wallet.keyAgent,
      payload: Cardano.util.HexBlob(payload),
      signWith: addr
    });
  },
  signTx: async (tx: Cbor, _partialSign?: Boolean): Promise<Cbor> => {
    logger.debug('signTx');
    try {
      const txDecoded = CSL.TransactionBody.from_bytes(Buffer.from(tx, 'hex'));
      const hash = Cardano.TransactionId(Buffer.from(CSL.hash_transaction(txDecoded).to_bytes()).toString('hex'));
      const coreTx = cslToCore.txBody(txDecoded);
      const witnessSet = await wallet.keyAgent.signTransaction(
        {
          body: coreTx,
          hash
        },
        { inputAddressResolver: wallet.inputAddressResolver }
      );

      const cslWitnessSet = coreToCsl.witnessSet(witnessSet);

      return Promise.resolve(Buffer.from(cslWitnessSet.to_bytes()).toString('hex'));
    } catch (error) {
      logger.error(error);
      // TODO: handle ProofGeneration errors?
      const message = error instanceof AuthenticationError ? error.message : 'Nope';
      throw new TxSignError(TxSignErrorCode.UserDeclined, message);
    }
  },
  submitTx: async (tx: Cbor): Promise<string> => {
    logger.debug('submitting tx');
    try {
      const txDecoded = CSL.Transaction.from_bytes(Buffer.from(tx, 'hex'));
      const txData: Cardano.NewTxAlonzo = cslToCore.newTx(txDecoded);
      await wallet.submitTx(txData);
      return Promise.resolve(txData.id.toString());
    } catch (error) {
      logger.error(error);
      throw error;
    }
  }
});

/**
 * Hook up the wallet to handle CIP30 browser runtime messages
 *
 * @returns {Function} unregisters browser runtime event listeners
 */
export const initialize = (wallet: SingleAddressWallet, { logger = dummyLogger }: Cip30WalletDependencies = {}) => {
  const walletApi = createWalletApi(wallet, { logger });
  return handleMessages(wallet.name, walletApi, logger);
};
