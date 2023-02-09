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
} from '@cardano-sdk/dapp-connector';
import { CML, Cardano, cmlToCore, coreToCml } from '@cardano-sdk/core';
import { InputSelectionError } from '@cardano-sdk/input-selection';
import { Logger } from 'ts-log';
import { ManagedFreeableScope, usingAutoFree } from '@cardano-sdk/util';
import { Observable, firstValueFrom } from 'rxjs';
import { ObservableWallet } from './types';
import { errors } from '@cardano-sdk/key-management';

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
  data: Cardano.Tx;
};

export type SubmitTxCallbackParams = {
  type: Cip30ConfirmationCallbackType.SubmitTx;
  data: Cardano.Tx;
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

const MAX_COLLATERAL_AMOUNT = CML.BigNum.from_str('5000000');

const cslToCbor = (csl: CslInterface) => Buffer.from(csl.to_bytes()).toString('hex');

const compareUtxos = (utxo: Cardano.Utxo, comparedTo: Cardano.Utxo) => {
  const currentCoin = utxo[1].value.coins;
  const comparedToCoin = comparedTo[1].value.coins;
  if (currentCoin < comparedToCoin) return -1;
  if (currentCoin > comparedToCoin) return 1;
  return 0;
};

export const createWalletApi = (
  wallet$: Observable<ObservableWallet>,
  confirmationCallback: CallbackConfirmation,
  { logger }: Cip30WalletDependencies
): WalletApi => ({
  getBalance: async (): Promise<Cbor> => {
    logger.debug('getting balance');
    try {
      const wallet = await firstValueFrom(wallet$);
      const value = await firstValueFrom(wallet.balance.utxo.available$);
      return Buffer.from(usingAutoFree((scope) => coreToCml.value(scope, value).to_bytes())).toString('hex');
    } catch (error) {
      logger.error(error);
      throw error;
    }
  },
  getChangeAddress: async (): Promise<Cbor> => {
    logger.debug('getting changeAddress');
    try {
      const wallet = await firstValueFrom(wallet$);
      const [{ address }] = await firstValueFrom(wallet.addresses$);

      if (!address) {
        logger.error('could not get change address');
        throw new ApiError(APIErrorCode.InternalError, 'could not get change address');
      } else {
        return address.toString();
      }
    } catch (error) {
      logger.error(error);
      if (error instanceof ApiError) {
        throw error;
      }
      throw new ApiError(APIErrorCode.InternalError, 'Nope');
    }
  },
  // eslint-disable-next-line max-statements
  getCollateral: async ({ amount = cslToCbor(MAX_COLLATERAL_AMOUNT) }: { amount?: Cbor } = {}): Promise<
    Cbor[] | null
    // eslint-disable-next-line sonarjs/cognitive-complexity
  > => {
    const scope = new ManagedFreeableScope();
    logger.debug('getting collateral');
    const wallet = await firstValueFrom(wallet$);
    let unspendables = (await firstValueFrom(wallet.utxo.unspendable$)).sort(compareUtxos);
    if (unspendables.some((utxo) => utxo[1].value.assets && utxo[1].value.assets.size > 0)) {
      scope.dispose();
      throw new ApiError(APIErrorCode.Refused, 'unspendable UTxOs must not contain assets when used as collateral');
    }
    if (amount) {
      try {
        const filterAmount = scope.manage(CML.BigNum.from_bytes(Buffer.from(amount, 'hex')));
        if (filterAmount.compare(MAX_COLLATERAL_AMOUNT) > 0) {
          scope.dispose();
          throw new ApiError(APIErrorCode.InvalidRequest, 'requested amount is too big');
        }

        const utxos = [];
        let totalCoins = scope.manage(CML.BigNum.from_str('0'));
        for (const utxo of unspendables) {
          const coin = scope.manage(CML.BigNum.from_str(utxo[1].value.coins.toString()));
          totalCoins = totalCoins.checked_add(coin);
          utxos.push(utxo);
          if (totalCoins.compare(filterAmount) !== -1) break;
        }
        if (totalCoins.compare(filterAmount) === -1) {
          scope.dispose();
          throw new ApiError(APIErrorCode.Refused, 'not enough coins in configured collateral UTxOs');
        }
        unspendables = utxos;
      } catch (error) {
        logger.error(error);
        scope.dispose();
        if (error instanceof ApiError) {
          throw error;
        }
        throw new ApiError(APIErrorCode.InternalError, 'Nope');
      }
    }
    const cbor = coreToCml.utxo(scope, unspendables).map(cslToCbor);
    scope.dispose();
    return cbor;
  },
  getNetworkId: async (): Promise<Cardano.NetworkId> => {
    logger.debug('getting networkId');
    const wallet = await firstValueFrom(wallet$);
    const genesisParameters = await firstValueFrom(wallet.genesisParameters$);
    return genesisParameters.networkId;
  },
  getRewardAddresses: async (): Promise<Cbor[]> => {
    logger.debug('getting reward addresses');
    try {
      const wallet = await firstValueFrom(wallet$);
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

    const wallet = await firstValueFrom(wallet$);
    const [{ address }] = await firstValueFrom(wallet.addresses$);

    if (!address) {
      throw new ApiError(APIErrorCode.InternalError, 'could not get used addresses');
    } else {
      return [address.toString()];
    }
  },
  getUtxos: async (amount?: Cbor, paginate?: Paginate): Promise<Cbor[] | undefined> => {
    const scope = new ManagedFreeableScope();
    const wallet = await firstValueFrom(wallet$);
    let utxos = await firstValueFrom(wallet.utxo.available$);
    if (amount) {
      try {
        const filterAmount = scope.manage(CML.Value.from_bytes(Buffer.from(amount, 'hex')));
        /**
         * Getting UTxOs to meet a required amount is a complex operation,
         * which is handled by input selection capabilities. By initializing
         * a transaction we're able to utilise the internal configuration and
         * algorithm to make this selection, using a wallet address to
         * satisfy the interface only.
         */
        const addresses = await firstValueFrom(wallet.addresses$);
        const { inputSelection } = await wallet.initializeTx({
          outputs: new Set([{ address: addresses[0].address, value: cmlToCore.value(filterAmount) }])
        });

        utxos = [...inputSelection.inputs];
      } catch (error) {
        logger.debug(error);
        const message = error instanceof InputSelectionError ? error.message : 'Nope';

        scope.dispose();
        throw new ApiError(APIErrorCode.Refused, message);
      }
    } else if (paginate) {
      utxos = utxos.slice(paginate.page * paginate.limit, paginate.page * paginate.limit + paginate.limit);
    }
    const cbor = coreToCml.utxo(scope, utxos).map(cslToCbor);
    scope.dispose();
    return cbor;
  },
  signData: async (addr: Cardano.Address | Bytes, payload: Bytes): Promise<Cip30DataSignature> => {
    logger.debug('signData');
    const hexBlobPayload = Cardano.util.HexBlob(payload);
    const signWith = Cardano.Address(addr.toString());

    const shouldProceed = await confirmationCallback({
      data: {
        addr: signWith,
        payload: hexBlobPayload
      },
      type: Cip30ConfirmationCallbackType.SignData
    }).catch((error) => mapCallbackFailure(error, logger));

    if (shouldProceed) {
      const wallet = await firstValueFrom(wallet$);
      return wallet.signData({
        payload: hexBlobPayload,
        signWith
      });
    }
    logger.debug('sign data declined');
    throw new DataSignError(DataSignErrorCode.UserDeclined, 'user declined signing');
  },
  signTx: async (tx: Cbor, _partialSign?: Boolean): Promise<Cbor> => {
    const scope = new ManagedFreeableScope();
    logger.debug('signTx');
    const txDecoded = scope.manage(CML.Transaction.from_bytes(Buffer.from(tx, 'hex')));
    const hash = Cardano.TransactionId(
      Buffer.from(scope.manage(CML.hash_transaction(scope.manage(txDecoded.body()))).to_bytes()).toString('hex')
    );
    const coreTx = cmlToCore.newTx(txDecoded);
    const shouldProceed = await confirmationCallback({
      data: coreTx,
      type: Cip30ConfirmationCallbackType.SignTx
    }).catch((error) => mapCallbackFailure(error, logger));
    if (shouldProceed) {
      const wallet = await firstValueFrom(wallet$);
      try {
        const {
          witness: { signatures }
        } = await wallet.finalizeTx({ tx: { ...coreTx, hash } });

        const cslWitnessSet = scope.manage(coreToCml.witnessSet(scope, { signatures }));
        const cbor = Buffer.from(cslWitnessSet.to_bytes()).toString('hex');
        return Promise.resolve(cbor);
      } catch (error) {
        logger.error(error);
        // TODO: handle ProofGeneration errors?
        const message = error instanceof errors.AuthenticationError ? error.message : 'Nope';
        throw new TxSignError(TxSignErrorCode.UserDeclined, message);
      } finally {
        scope.dispose();
      }
    } else {
      scope.dispose();
      throw new TxSignError(TxSignErrorCode.UserDeclined, 'user declined signing tx');
    }
  },
  submitTx: async (tx: Cbor): Promise<string> => {
    logger.debug('submitting tx');
    const txData: Cardano.Tx = usingAutoFree((scope) =>
      cmlToCore.newTx(scope.manage(CML.Transaction.from_bytes(Buffer.from(tx, 'hex'))))
    );
    const shouldProceed = await confirmationCallback({
      data: txData,
      type: Cip30ConfirmationCallbackType.SubmitTx
    }).catch((error) => mapCallbackFailure(error, logger));

    if (shouldProceed) {
      try {
        const wallet = await firstValueFrom(wallet$);
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
