import {
  APIErrorCode,
  ApiError,
  Bytes,
  Cbor,
  Cip30DataSignature,
  Cip95WalletApi,
  DataSignError,
  DataSignErrorCode,
  Paginate,
  SenderContext,
  TxSendError,
  TxSendErrorCode,
  TxSignError,
  TxSignErrorCode,
  WalletApi,
  WalletApiExtension,
  WithSenderContext
} from '@cardano-sdk/dapp-connector';
import { Cardano, Serialization, TxCBOR, coalesceValueQuantities } from '@cardano-sdk/core';
import { HexBlob, ManagedFreeableScope } from '@cardano-sdk/util';
import { InputSelectionError, InputSelectionFailure } from '@cardano-sdk/input-selection';
import { Logger } from 'ts-log';
import { MessageSender } from '@cardano-sdk/key-management';
import { Observable, firstValueFrom, map } from 'rxjs';
import { ObservableWallet } from './types';
import { requiresForeignSignatures } from './services';
import uniq from 'lodash/uniq.js';

export type Cip30WalletDependencies = {
  logger: Logger;
};

export enum Cip30ConfirmationCallbackType {
  SignData = 'sign_data',
  SignTx = 'sign_tx',
  SubmitTx = 'submit_tx',
  GetCollateral = 'get_collateral'
}

export type SignDataCallbackParams = {
  type: Cip30ConfirmationCallbackType.SignData;
  sender: MessageSender;
  data: {
    addr: Cardano.PaymentAddress | Cardano.DRepID;
    payload: HexBlob;
  };
};

export type SignTxCallbackParams = {
  sender: MessageSender;
  type: Cip30ConfirmationCallbackType.SignTx;
  data: Cardano.Tx;
};

export type SubmitTxCallbackParams = {
  type: Cip30ConfirmationCallbackType.SubmitTx;
  data: Cardano.Tx;
};

// Optional callback
export type GetCollateralCallbackParams = {
  sender: MessageSender;
  type: Cip30ConfirmationCallbackType.GetCollateral;
  data: {
    amount: Cardano.Lovelace;
    utxos: Cardano.Utxo[];
  };
};

type GetCollateralCallback = (args: GetCollateralCallbackParams) => Promise<Cardano.Utxo[]>;

export type CallbackConfirmation = {
  signData: (args: SignDataCallbackParams) => Promise<boolean>;
  signTx: (args: SignTxCallbackParams) => Promise<boolean>;
  submitTx: (args: SubmitTxCallbackParams) => Promise<boolean>;
  getCollateral?: GetCollateralCallback;
};

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

const MAX_COLLATERAL_AMOUNT = 5_000_000n;

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

const parseValueCbor = (value: Cbor) => {
  try {
    return Serialization.Value.fromCbor(value as unknown as HexBlob);
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

/** Returns an array of UTxOs that do not contain assets */
const getUtxosWithoutAssets = (utxos: Cardano.Utxo[]): Cardano.Utxo[] => utxos.filter((utxo) => !utxo[1].value.assets);

const getFilterAsBigNum = (amount: Cbor): bigint => {
  const reader = new Serialization.CborReader(HexBlob(amount));

  if (
    reader.peekState() === Serialization.CborReaderState.Tag &&
    reader.peekTag() === Serialization.CborTag.UnsignedBigNum
  ) {
    reader.readTag();
    return BigInt(`0x${HexBlob.fromBytes(reader.readByteString())}`).valueOf();
  }

  return reader.readInt();
};

const getFilterAmount = (amount: Cbor): bigint => {
  try {
    const filterAmount = getFilterAsBigNum(amount);

    if (filterAmount > MAX_COLLATERAL_AMOUNT) {
      throw new ApiError(APIErrorCode.InvalidRequest, 'requested amount is too big');
    }
    return filterAmount;
  } catch (error) {
    throw new ApiError(APIErrorCode.InternalError, formatUnknownError(error));
  }
};

/**
 * getCollateralCallback
 *
 * @param sender The sender of the request
 * @param amount ADA collateral required in lovelaces
 * @param availableUtxos available UTxOs
 * @param callback Callback to execute to attempt setting new collateral
 * @param logger The logger instance
 * @returns Promise<Cbor[]> or null
 */
const getCollateralCallback = async (
  sender: MessageSender,
  amount: Cardano.Lovelace,
  availableUtxos: Cardano.Utxo[],
  callback: GetCollateralCallback,
  logger: Logger
) => {
  const availableUtxosWithoutAssets = getUtxosWithoutAssets(availableUtxos);
  if (availableUtxosWithoutAssets.length === 0) return null;
  try {
    // Send the amount and filtered available UTxOs to the callback
    // Client can then choose to mark a UTxO set as unspendable
    const newCollateral = await callback({
      data: {
        amount,
        utxos: availableUtxosWithoutAssets
      },
      sender,
      type: Cip30ConfirmationCallbackType.GetCollateral
    });
    return newCollateral.map((core) => Serialization.TransactionUnspentOutput.fromCore(core).toCbor());
  } catch (error) {
    logger.error(error);
    if (error instanceof ApiError) {
      throw error;
    }
    throw new ApiError(APIErrorCode.InternalError, formatUnknownError(error));
  }
};

const getSortedUtxos = async (observableUtxos: Observable<Cardano.Utxo[]>): Promise<Cardano.Utxo[]> => {
  const utxos = await firstValueFrom(observableUtxos);
  return utxos.sort(compareUtxos);
};

const baseCip30WalletApi = (
  wallet$: Observable<ObservableWallet>,
  confirmationCallback: CallbackConfirmation,
  { logger }: Cip30WalletDependencies
) => ({
  getBalance: async (): Promise<Cbor> => {
    logger.debug('getting balance');
    try {
      const wallet = await firstValueFrom(wallet$);
      const value = await firstValueFrom(wallet.balance.utxo.available$);
      return Serialization.Value.fromCore(value).toCbor();
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
  // eslint-disable-next-line max-statements, sonarjs/cognitive-complexity,complexity
  getCollateral: async (
    { sender }: SenderContext,
    { amount = new Serialization.Value(MAX_COLLATERAL_AMOUNT).toCbor() }: { amount?: Cbor } = {}
  ): Promise<
    Cbor[] | null
    // eslint-disable-next-line sonarjs/cognitive-complexity, max-statements
  > => {
    logger.debug('getting collateral');
    const wallet = await firstValueFrom(wallet$);
    let unspendables = await getSortedUtxos(wallet.utxo.unspendable$);
    const available = await getSortedUtxos(wallet.utxo.available$);
    // No available unspendable UTxO
    if (unspendables.length === 0) {
      if (available.length > 0 && !!confirmationCallback.getCollateral) {
        // available UTxOs could be set as collateral based on user preference
        return await getCollateralCallback(
          sender,
          getFilterAmount(amount),
          available,
          confirmationCallback.getCollateral,
          logger
        );
      }
      return null;
    }

    if (unspendables.some((utxo) => utxo[1].value.assets && utxo[1].value.assets.size > 0)) {
      throw new ApiError(APIErrorCode.Refused, 'unspendable UTxOs must not contain assets when used as collateral');
    }
    if (amount) {
      const filterAmount = getFilterAmount(amount);

      try {
        const utxos = [];
        let totalCoins = 0n;
        for (const utxo of unspendables) {
          const coin = utxo[1].value.coins;
          totalCoins += coin;
          utxos.push(utxo);
          if (totalCoins >= filterAmount) break;
        }
        if (totalCoins < filterAmount) {
          // if no collateral available by amount in unspendables, return callback if provided to set unspendables and return in the callback

          if (available.length > 0 && !!confirmationCallback.getCollateral) {
            return await getCollateralCallback(
              sender,
              filterAmount,
              available,
              confirmationCallback.getCollateral,
              logger
            );
          }

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
    return unspendables.map((core) => Serialization.TransactionUnspentOutput.fromCore(core).toCbor());
  },
  getExtensions: async (): Promise<WalletApiExtension[]> => {
    logger.debug('getting enabled extensions');
    return Promise.resolve([{ cip: 95 }]);
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
      const walletAddresses = await firstValueFrom(wallet.addresses$);
      const rewardAccounts = uniq(walletAddresses.map((address) => address.rewardAccount));

      if (!rewardAccounts || rewardAccounts.length === 0) {
        throw new ApiError(APIErrorCode.InternalError, 'could not get reward address');
      } else {
        return rewardAccounts.map((rewardAccount) => cardanoAddressToCbor(rewardAccount));
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
  getUsedAddresses: async (): Promise<Cbor[]> => {
    logger.debug('getting used addresses');

    const wallet = await firstValueFrom(wallet$);
    const addresses = await firstValueFrom(wallet.addresses$);

    if (addresses.length === 0) {
      throw new ApiError(APIErrorCode.InternalError, 'could not get used addresses');
    } else {
      return addresses.map((groupAddresses) => cardanoAddressToCbor(groupAddresses.address));
    }
  },
  getUtxos: async (_: SenderContext, amount?: Cbor, paginate?: Paginate): Promise<Cbor[] | null> => {
    const scope = new ManagedFreeableScope();
    try {
      const wallet = await firstValueFrom(wallet$);
      let utxos = amount
        ? await selectUtxo(wallet, parseValueCbor(amount).toCore(), !!paginate)
        : await firstValueFrom(wallet.utxo.available$);
      if (!utxos) return null;
      if (paginate) {
        utxos = utxos.slice(paginate.page * paginate.limit, paginate.page * paginate.limit + paginate.limit);
      }
      const cbor = utxos.map((core) => Serialization.TransactionUnspentOutput.fromCore(core).toCbor());
      scope.dispose();
      return cbor;
    } finally {
      scope.dispose();
    }
  },
  signData: async (
    { sender }: SenderContext,
    addr: Cardano.PaymentAddress | Cardano.DRepID | Bytes,
    payload: Bytes
  ): Promise<Cip30DataSignature> => {
    logger.debug('signData');
    const hexBlobPayload = HexBlob(payload);
    const signWith = Cardano.DRepID.isValid(addr) ? Cardano.DRepID(addr) : Cardano.PaymentAddress(addr);

    const shouldProceed = await confirmationCallback
      .signData({
        data: {
          addr: signWith,
          payload: hexBlobPayload
        },
        sender,
        type: Cip30ConfirmationCallbackType.SignData
      })
      .catch((error) => mapCallbackFailure(error, logger));

    if (shouldProceed) {
      const wallet = await firstValueFrom(wallet$);
      return wallet.signData({
        payload: hexBlobPayload,
        sender,
        signWith
      });
    }
    logger.debug('sign data declined');
    throw new DataSignError(DataSignErrorCode.UserDeclined, 'user declined signing');
  },
  signTx: async ({ sender }: SenderContext, tx: Cbor, partialSign?: Boolean): Promise<Cbor> => {
    const scope = new ManagedFreeableScope();
    logger.debug('signTx');
    const txDecoded = Serialization.Transaction.fromCbor(TxCBOR(tx));

    const hash = txDecoded.getId();
    const coreTx = txDecoded.toCore();
    const shouldProceed = await confirmationCallback
      .signTx({
        data: coreTx,
        sender,
        type: Cip30ConfirmationCallbackType.SignTx
      })
      .catch((error) => mapCallbackFailure(error, logger));
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
        } = await wallet.finalizeTx({
          bodyCbor: txDecoded.body().toCbor(),
          signingContext: { sender },
          tx: { ...coreTx, hash }
        });

        // If partialSign is true, the wallet only tries to sign what it can. However, if
        // signatures size is 0 then throw.
        if (partialSign && signatures.size === 0) {
          throw new DataSignError(
            DataSignErrorCode.ProofGeneration,
            'The wallet does not have the secret key associated with any of the inputs and certificates.'
          );
        }

        const cbor = Serialization.TransactionWitnessSet.fromCore({ signatures }).toCbor();
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
  submitTx: async (_: SenderContext, input: Cbor): Promise<string> => {
    logger.debug('submitting tx');
    const { cbor, tx } = processTxInput(input);
    const shouldProceed = await confirmationCallback
      .submitTx({
        data: tx,
        type: Cip30ConfirmationCallbackType.SubmitTx
      })
      .catch((error) => mapCallbackFailure(error, logger));

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

const getPubStakeKeys = async (
  wallet$: Observable<ObservableWallet>,
  filter: Cardano.StakeCredentialStatus.Registered | Cardano.StakeCredentialStatus.Unregistered
) => {
  const wallet = await firstValueFrom(wallet$);
  return firstValueFrom(
    wallet.publicStakeKeys$.pipe(
      map((keys) =>
        keys.filter(({ credentialStatus }) => {
          const status =
            credentialStatus === Cardano.StakeCredentialStatus.Registered ||
            credentialStatus === Cardano.StakeCredentialStatus.Registering
              ? Cardano.StakeCredentialStatus.Registered
              : Cardano.StakeCredentialStatus.Unregistered;
          return filter === status;
        })
      ),
      map((keys) => keys.map(({ publicStakeKey }) => publicStakeKey))
    )
  );
};

const extendedCip95WalletApi = (
  wallet$: Observable<ObservableWallet>,
  { logger }: Cip30WalletDependencies
): Cip95WalletApi => ({
  getPubDRepKey: async () => {
    logger.debug('getting public DRep key');
    try {
      const wallet = await firstValueFrom(wallet$);
      const dReKey = await wallet.governance.getPubDRepKey();

      if (!dReKey) throw new Error('Shared wallet does not support DRep key');

      return dReKey;
    } catch (error) {
      logger.error(error);
      throw new ApiError(APIErrorCode.InternalError, formatUnknownError(error));
    }
  },
  getRegisteredPubStakeKeys: async () => {
    logger.debug('getting registered public stake keys');
    try {
      return await getPubStakeKeys(wallet$, Cardano.StakeCredentialStatus.Registered);
    } catch (error) {
      logger.error(error);
      throw new ApiError(APIErrorCode.InternalError, formatUnknownError(error));
    }
  },
  getUnregisteredPubStakeKeys: async () => {
    logger.debug('getting unregistered public stake keys');
    try {
      return await getPubStakeKeys(wallet$, Cardano.StakeCredentialStatus.Unregistered);
    } catch (error) {
      logger.error(error);
      throw new ApiError(APIErrorCode.InternalError, formatUnknownError(error));
    }
  }
});

export const createWalletApi = (
  wallet$: Observable<ObservableWallet>,
  confirmationCallback: CallbackConfirmation,
  { logger }: Cip30WalletDependencies
): WithSenderContext<WalletApi> => ({
  ...baseCip30WalletApi(wallet$, confirmationCallback, { logger }),
  ...extendedCip95WalletApi(wallet$, { logger })
});
