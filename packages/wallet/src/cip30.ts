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
import { CML, Cardano, Transaction, TxCBOR, cmlToCore, coalesceValueQuantities, coreToCml } from '@cardano-sdk/core';
import { HexBlob, ManagedFreeableScope, usingAutoFree } from '@cardano-sdk/util';
import { InputSelectionError, InputSelectionFailure } from '@cardano-sdk/input-selection';
import { Logger } from 'ts-log';
import { Observable, firstValueFrom } from 'rxjs';
import { ObservableWallet } from './types';
import { requiresForeignSignatures } from './services';

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
    addr: Cardano.PaymentAddress;
    payload: HexBlob;
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

const processTxInput = (input: string) => {
  try {
    const cbor = TxCBOR(input);
    const tx = TxCBOR.deserialize(cbor);
    return { cbor, tx };
  } catch {
    throw new ApiError(APIErrorCode.InvalidRequest, "Couldn't parse transaction. Expecting hex-encoded CBOR string.");
  }
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

const cardanoAddressToCbor = (address: Cardano.PaymentAddress | Cardano.RewardAccount): Cbor => {
  const addr = Cardano.Address.fromString(address);

  if (!addr) {
    throw new ApiError(APIErrorCode.InternalError, `could not transform address ${address} to CBOR`);
  }
  return addr.toBytes();
};

const formatUnknownError = (error: unknown): string => (error as Error)?.message || 'Unknown error';

const parseValueCbor = (scope: ManagedFreeableScope, value: Cbor) => {
  try {
    return scope.manage(CML.Value.from_bytes(Buffer.from(value, 'hex')));
  } catch {
    throw new ApiError(APIErrorCode.InvalidRequest, 'could not parse Value');
  }
};

const dumbSelection = (utxos: Cardano.Utxo[], target: Cardano.Value) => {
  const selectedUtxos: Cardano.Utxo[] = [];
  const filterAmountAssets = [...(target.assets?.entries() || [])];
  let foundEnough = false;
  for (const utxo of utxos) {
    selectedUtxos.push(utxo);
    const selectedValue = coalesceValueQuantities(selectedUtxos.map(([_, { value }]) => value));
    foundEnough =
      selectedValue.coins >= target.coins &&
      filterAmountAssets.every(
        ([assetId, requestedQuantity]) => (selectedValue.assets?.get(assetId) || 0n) >= requestedQuantity
      );
    if (foundEnough) {
      break;
    }
  }
  if (!foundEnough) {
    return null;
  }
  return selectedUtxos;
};

const walletSelection = async (target: Cardano.Value, wallet: ObservableWallet) => {
  try {
    /**
     * Getting UTxOs to meet a required amount is a complex operation,
     * which is handled by input selection capabilities. By initializing
     * a transaction we're able to utilise the internal configuration and
     * algorithm to make this selection, using a wallet address to
     * satisfy the interface only.
     */
    const addresses = await firstValueFrom(wallet.addresses$);
    const { inputSelection } = await wallet.initializeTx({
      outputs: new Set([{ address: addresses[0].address, value: target }])
    });

    return [...inputSelection.inputs];
  } catch (error) {
    if (error instanceof InputSelectionError && error.failure === InputSelectionFailure.UtxoBalanceInsufficient) {
      return null;
    }
    const message = formatUnknownError(error);

    throw new ApiError(APIErrorCode.InternalError, message);
  }
};

/**
 * Select utxo via either default wallet's default input selection algorithm,
 * or 'dumb selection', which should preserve the order of utxos for pagination.
 */
const selectUtxo = async (wallet: ObservableWallet, filterAmount: Cardano.Value, useDumbSelection: boolean) =>
  useDumbSelection
    ? dumbSelection(await firstValueFrom(wallet.utxo.available$), filterAmount)
    : await walletSelection(filterAmount, wallet);

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
        return cardanoAddressToCbor(address);
      }
    } catch (error) {
      logger.error(error);
      if (error instanceof ApiError) {
        throw error;
      }
      throw new ApiError(APIErrorCode.InternalError, formatUnknownError(error));
    }
  },
  // eslint-disable-next-line max-statements
  getCollateral: async ({ amount = cslToCbor(MAX_COLLATERAL_AMOUNT) }: { amount?: Cbor } = {}): Promise<
    Cbor[] | null
    // eslint-disable-next-line sonarjs/cognitive-complexity
  > =>
    usingAutoFree(async (scope) => {
      logger.debug('getting collateral');
      const wallet = await firstValueFrom(wallet$);
      let unspendables = (await firstValueFrom(wallet.utxo.unspendable$)).sort(compareUtxos);

      // No available unspendable UTXO
      if (unspendables.length === 0) return null;

      if (unspendables.some((utxo) => utxo[1].value.assets && utxo[1].value.assets.size > 0)) {
        throw new ApiError(APIErrorCode.Refused, 'unspendable UTxOs must not contain assets when used as collateral');
      }
      if (amount) {
        try {
          const filterAmount = (() => {
            try {
              return scope.manage(CML.BigNum.from_bytes(Buffer.from(amount, 'hex')));
            } catch {
              return scope.manage(
                CML.BigNum.from_str(scope.manage(CML.BigInt.from_bytes(Buffer.from(amount, 'hex'))).to_str())
              );
            }
          })();
          if (filterAmount.compare(MAX_COLLATERAL_AMOUNT) > 0) {
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
            throw new ApiError(APIErrorCode.Refused, 'not enough coins in configured collateral UTxOs');
          }
          unspendables = utxos;
        } catch (error) {
          logger.error(error);
          if (error instanceof ApiError) {
            throw error;
          }
          throw new ApiError(APIErrorCode.InternalError, formatUnknownError(error));
        }
      }
      return coreToCml.utxo(scope, unspendables).map(cslToCbor);
    }),
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
        return [cardanoAddressToCbor(rewardAccount)];
      }
    } catch (error) {
      logger.error(error);
      if (error instanceof ApiError) {
        throw error;
      }
      throw new ApiError(APIErrorCode.InternalError, formatUnknownError(error));
    }
  },
  getUnusedAddresses: async (): Promise<Cbor[]> => {
    logger.debug('getting unused addresses');
    return Promise.resolve([]);
  },
  getUsedAddresses: async (_paginate?: Paginate): Promise<Cbor[]> => {
    logger.debug('getting used addresses');

    const wallet = await firstValueFrom(wallet$);
    const addresses = await firstValueFrom(wallet.addresses$);

    if (addresses.length === 0) {
      throw new ApiError(APIErrorCode.InternalError, 'could not get used addresses');
    } else {
      return addresses.map((groupAddresses) => cardanoAddressToCbor(groupAddresses.address));
    }
  },
  getUtxos: async (amount?: Cbor, paginate?: Paginate): Promise<Cbor[] | null> => {
    const scope = new ManagedFreeableScope();
    try {
      const wallet = await firstValueFrom(wallet$);
      let utxos = amount
        ? await selectUtxo(wallet, cmlToCore.value(parseValueCbor(scope, amount)), !!paginate)
        : await firstValueFrom(wallet.utxo.available$);
      if (!utxos) return null;
      if (paginate) {
        utxos = utxos.slice(paginate.page * paginate.limit, paginate.page * paginate.limit + paginate.limit);
      }
      const cbor = coreToCml.utxo(scope, utxos).map(cslToCbor);
      scope.dispose();
      return cbor;
    } finally {
      scope.dispose();
    }
  },
  signData: async (addr: Cardano.PaymentAddress | Bytes, payload: Bytes): Promise<Cip30DataSignature> => {
    logger.debug('signData');
    const hexBlobPayload = HexBlob(payload);
    const signWith = Cardano.PaymentAddress(addr);

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
  signTx: async (tx: Cbor, partialSign?: Boolean): Promise<Cbor> => {
    const scope = new ManagedFreeableScope();
    logger.debug('signTx');
    const txDecoded = scope.manage(Transaction.fromCbor(HexBlob(tx)));

    const hash = txDecoded.getId();
    const coreTx = txDecoded.toCore();
    const shouldProceed = await confirmationCallback({
      data: coreTx,
      type: Cip30ConfirmationCallbackType.SignTx
    }).catch((error) => mapCallbackFailure(error, logger));
    if (shouldProceed) {
      const wallet = await firstValueFrom(wallet$);
      try {
        const needsForeignSignature = await requiresForeignSignatures(coreTx, wallet);

        // If partialSign is false and the wallet could not sign the entire transaction
        if (!partialSign && needsForeignSignature)
          throw new DataSignError(
            DataSignErrorCode.ProofGeneration,
            'The wallet does not have the secret key associated with some of the inputs or certificates.'
          );
        const {
          witness: { signatures }
        } = await wallet.finalizeTx({ tx: { ...coreTx, hash } });

        // If partialSign is true, the wallet only tries to sign what it can. However, if
        // signatures size is 0 then throw.
        if (partialSign && signatures.size === 0) {
          throw new DataSignError(
            DataSignErrorCode.ProofGeneration,
            'The wallet does not have the secret key associated with any of the inputs and certificates.'
          );
        }

        const cslWitnessSet = scope.manage(coreToCml.witnessSet(scope, { signatures }));
        const cbor = Buffer.from(cslWitnessSet.to_bytes()).toString('hex');
        return Promise.resolve(cbor);
      } catch (error) {
        logger.error(error);
        if (error instanceof DataSignError) {
          throw error;
        } else {
          const message = formatUnknownError(error);
          throw new TxSignError(TxSignErrorCode.UserDeclined, message);
        }
      } finally {
        scope.dispose();
      }
    } else {
      scope.dispose();
      throw new TxSignError(TxSignErrorCode.UserDeclined, 'user declined signing tx');
    }
  },
  submitTx: async (input: Cbor): Promise<string> => {
    logger.debug('submitting tx');
    const { cbor, tx } = processTxInput(input);
    const shouldProceed = await confirmationCallback({
      data: tx,
      type: Cip30ConfirmationCallbackType.SubmitTx
    }).catch((error) => mapCallbackFailure(error, logger));

    if (shouldProceed) {
      try {
        const wallet = await firstValueFrom(wallet$);
        await wallet.submitTx(cbor);
        return tx.id;
      } catch (error) {
        logger.error(error);
        const info = error instanceof Error ? error.message : 'unknown';
        throw new TxSendError(TxSendErrorCode.Failure, info);
      }
    } else {
      logger.debug('transaction refused');
      throw new TxSendError(TxSendErrorCode.Refused, 'transaction refused');
    }
  }
});
