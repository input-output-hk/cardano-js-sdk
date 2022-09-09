import {
  APIErrorCode,
  ApiError,
  Bytes,
  Cbor,
  Cip30DataSignature,
  DataSignError,
  DataSignErrorCode,
  Paginate,
  TxSendError,
  TxSendErrorCode,
  TxSignError,
  TxSignErrorCode,
  WalletApi
} from '@cardano-sdk/cip30';
import { CSL, Cardano, coreToCsl, cslToCore } from '@cardano-sdk/core';
import { InputSelectionError } from '@cardano-sdk/cip2';
import { Logger } from 'ts-log';
import { ObservableWallet } from './types';
import { errors } from '@cardano-sdk/key-management';
import { firstValueFrom } from 'rxjs';

export type Cip30WalletDependencies = {
  logger: Logger;
};

export enum Cip30ConfirmationCallbackType {
  SignData = 'sign_data',
  SignTx = 'sign_tx',
  SubmitTx = 'submit_tx'
}

export type SignDataCallbackParams = {
  type: Cip30ConfirmationCallbackType.SignData;
  data: {
    addr: Cardano.Address;
    payload: Cardano.util.HexBlob;
  };
};

export type SignTxCallbackParams = {
  type: Cip30ConfirmationCallbackType.SignTx;
  data: Cardano.NewTxBodyAlonzo;
};

export type SubmitTxCallbackParams = {
  type: Cip30ConfirmationCallbackType.SubmitTx;
  data: Cardano.NewTxAlonzo;
};

export type CallbackConfirmation = (
  args: SignDataCallbackParams | SignTxCallbackParams | SubmitTxCallbackParams
) => Promise<boolean>;

interface CslInterface {
  to_bytes(): Uint8Array;
}

const mapCallbackFailure = (err: unknown, logger: Logger) => {
  logger.error(err);
  return false;
};

const MAX_COLLATERAL_AMOUNT = CSL.BigNum.from_str('5000000');

const cslToCbor = (csl: CslInterface) => Buffer.from(csl.to_bytes()).toString('hex');

const compareUtxos = (utxo: Cardano.Utxo, comparedTo: Cardano.Utxo) => {
  const currentCoin = utxo[1].value.coins;
  const comparedToCoin = comparedTo[1].value.coins;
  if (currentCoin < comparedToCoin) return -1;
  if (currentCoin > comparedToCoin) return 1;
  return 0;
};

export const createWalletApi = (
  walletReady: Promise<ObservableWallet>,
  confirmationCallback: CallbackConfirmation,
  { logger }: Cip30WalletDependencies
): WalletApi => ({
  getBalance: async (): Promise<Cbor> => {
    logger.debug('getting balance');
    try {
      const wallet = await walletReady;
      const value = await firstValueFrom(wallet.balance.utxo.available$);
      return Buffer.from(coreToCsl.value(value).to_bytes()).toString('hex');
    } catch (error) {
      logger.error(error);
      throw error;
    }
  },
  getChangeAddress: async (): Promise<Cbor> => {
    logger.debug('getting changeAddress');
    try {
      const wallet = await walletReady;
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
  getCollateral: async ({ amount = cslToCbor(MAX_COLLATERAL_AMOUNT) }: { amount?: Cbor } = {}): Promise<
    Cbor[] | null
    // eslint-disable-next-line sonarjs/cognitive-complexity
  > => {
    logger.debug('getting collateral');
    const wallet = await walletReady;
    let unspendables = (await firstValueFrom(wallet.utxo.unspendable$)).sort(compareUtxos);
    if (unspendables.some((utxo) => utxo[1].value.assets && utxo[1].value.assets.size > 0))
      throw new ApiError(APIErrorCode.Refused, 'unspendable UTxOs must not contain assets when used as collateral');
    if (amount) {
      try {
        const filterAmount = CSL.BigNum.from_bytes(Buffer.from(amount, 'hex'));
        if (filterAmount.compare(MAX_COLLATERAL_AMOUNT) > 0)
          throw new ApiError(APIErrorCode.InvalidRequest, 'requested amount is too big');
        const utxos = [];
        let totalCoins = CSL.BigNum.from_str('0');
        for (const utxo of unspendables) {
          const coin = CSL.BigNum.from_str(utxo[1].value.coins.toString());
          totalCoins = totalCoins.checked_add(coin);
          utxos.push(utxo);
          if (totalCoins.compare(filterAmount) !== -1) break;
        }
        if (totalCoins.compare(filterAmount) === -1)
          throw new ApiError(APIErrorCode.Refused, 'not enough coins in configured collateral UTxOs');
        unspendables = utxos;
      } catch (error) {
        logger.error(error);
        if (error instanceof ApiError) {
          throw error;
        }
        throw new ApiError(APIErrorCode.InternalError, 'Nope');
      }
    }
    return coreToCsl.utxo(unspendables).map(cslToCbor);
  },
  getNetworkId: async (): Promise<Cardano.NetworkId> => {
    logger.debug('getting networkId');
    const wallet = await walletReady;
    const genesisParameters = await firstValueFrom(wallet.genesisParameters$);
    return genesisParameters.networkId;
  },
  getRewardAddresses: async (): Promise<Cbor[]> => {
    logger.debug('getting reward addresses');
    try {
      const wallet = await walletReady;
      const [{ rewardAccount }] = await firstValueFrom(wallet.addresses$);

      if (!rewardAccount) {
        throw new ApiError(APIErrorCode.InternalError, 'could not get reward address');
      } else {
        return [rewardAccount.toString()];
      }
    } catch (error) {
      logger.error(error);
      if (error instanceof ApiError) {
        throw error;
      }
      throw new ApiError(APIErrorCode.InternalError, 'Nope');
    }
  },
  getUnusedAddresses: async (): Promise<Cbor[]> => {
    logger.debug('getting unused addresses');
    return Promise.resolve([]);
  },
  getUsedAddresses: async (_paginate?: Paginate): Promise<Cbor[]> => {
    logger.debug('getting changeAddress');

    const wallet = await walletReady;
    const [{ address }] = await firstValueFrom(wallet.addresses$);

    if (!address) {
      throw new ApiError(APIErrorCode.InternalError, 'could not get used addresses');
    } else {
      return [address.toString()];
    }
  },
  getUtxos: async (amount?: Cbor, paginate?: Paginate): Promise<Cbor[] | undefined> => {
    const wallet = await walletReady;
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
        const addresses = await firstValueFrom(wallet.addresses$);
        const { inputSelection } = await wallet.initializeTx({
          outputs: new Set([{ address: addresses[0].address, value: cslToCore.value(filterAmount) }])
        });

        utxos = [...inputSelection.inputs];
      } catch (error) {
        logger.debug(error);
        const message = error instanceof InputSelectionError ? error.message : 'Nope';
        throw new ApiError(APIErrorCode.Refused, message);
      }
    } else if (paginate) {
      utxos = utxos.slice(paginate.page * paginate.limit, paginate.page * paginate.limit + paginate.limit);
    }

    return coreToCsl.utxo(utxos).map(cslToCbor);
  },
  signData: async (addr: Cardano.Address, payload: Bytes): Promise<Cip30DataSignature> => {
    logger.debug('signData');
    const hexBlobPayload = Cardano.util.HexBlob(payload);

    const shouldProceed = await confirmationCallback({
      data: {
        addr,
        payload: hexBlobPayload
      },
      type: Cip30ConfirmationCallbackType.SignData
    }).catch((error) => mapCallbackFailure(error, logger));

    if (shouldProceed) {
      const wallet = await walletReady;
      return wallet.signData({
        payload: hexBlobPayload,
        signWith: addr
      });
    }
    logger.debug('sign data declined');
    throw new DataSignError(DataSignErrorCode.UserDeclined, 'user declined signing');
  },
  signTx: async (tx: Cbor, _partialSign?: Boolean): Promise<Cbor> => {
    logger.debug('signTx');

    const txDecoded = CSL.TransactionBody.from_bytes(Buffer.from(tx, 'hex'));
    const hash = Cardano.TransactionId(Buffer.from(CSL.hash_transaction(txDecoded).to_bytes()).toString('hex'));
    const coreTx = cslToCore.txBody(txDecoded);
    const shouldProceed = await confirmationCallback({
      data: coreTx,
      type: Cip30ConfirmationCallbackType.SignTx
    }).catch((error) => mapCallbackFailure(error, logger));
    if (shouldProceed) {
      const wallet = await walletReady;
      try {
        const {
          witness: { signatures }
        } = await wallet.finalizeTx({ tx: { body: coreTx, hash } });

        const cslWitnessSet = coreToCsl.witnessSet({ signatures });

        return Promise.resolve(Buffer.from(cslWitnessSet.to_bytes()).toString('hex'));
      } catch (error) {
        logger.error(error);
        // TODO: handle ProofGeneration errors?
        const message = error instanceof errors.AuthenticationError ? error.message : 'Nope';
        throw new TxSignError(TxSignErrorCode.UserDeclined, message);
      }
    } else {
      throw new TxSignError(TxSignErrorCode.UserDeclined, 'user declined signing tx');
    }
  },
  submitTx: async (tx: Cbor): Promise<string> => {
    logger.debug('submitting tx');
    const txDecoded = CSL.Transaction.from_bytes(Buffer.from(tx, 'hex'));
    const txData: Cardano.NewTxAlonzo = cslToCore.newTx(txDecoded);
    const shouldProceed = await confirmationCallback({
      data: txData,
      type: Cip30ConfirmationCallbackType.SubmitTx
    }).catch((error) => mapCallbackFailure(error, logger));

    if (shouldProceed) {
      try {
        const wallet = await walletReady;
        await wallet.submitTx(txData);
        return txData.id.toString();
      } catch (error) {
        logger.error(error);
        throw error;
      }
    } else {
      logger.debug('transaction refused');
      throw new TxSendError(TxSendErrorCode.Refused, 'transaction refused');
    }
  }
});
