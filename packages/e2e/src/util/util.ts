/* eslint-disable @typescript-eslint/no-explicit-any */
import * as Crypto from '@cardano-sdk/crypto';
import { Cardano, createSlotEpochCalc } from '@cardano-sdk/core';
import {
  EMPTY,
  Observable,
  combineLatest,
  distinctUntilChanged,
  filter,
  firstValueFrom,
  map,
  merge,
  mergeMap,
  switchMap,
  tap,
  throwError,
  timeout
} from 'rxjs';
import { FAST_OPERATION_TIMEOUT_DEFAULT, SYNC_TIMEOUT_DEFAULT } from '../defaults';
import { FinalizeTxProps, ObservableWallet, PersonalWallet } from '@cardano-sdk/wallet';
import { InMemoryKeyAgent, TransactionSigner } from '@cardano-sdk/key-management';
import { InitializeTxProps } from '@cardano-sdk/tx-construction';
import { TestWallet, networkInfoProviderFactory } from '../factories';
import { getEnv, walletVariables } from '../environment';
import { logger } from '@cardano-sdk/util-dev';
import sortBy from 'lodash/sortBy';

const env = getEnv(walletVariables);

export const firstValueFromTimed = <T>(
  observable$: Observable<T>,
  timeoutMessage = 'Timed out',
  timeoutAfter = FAST_OPERATION_TIMEOUT_DEFAULT
) =>
  firstValueFrom(
    observable$.pipe(timeout({ each: timeoutAfter, with: () => throwError(() => new Error(timeoutMessage)) }))
  );

export const waitForWalletStateSettle = (wallet: ObservableWallet, syncTimeout: number = SYNC_TIMEOUT_DEFAULT) =>
  firstValueFromTimed(
    wallet.syncStatus.isSettled$.pipe(filter((isSettled) => isSettled)),
    'Took too long to settle',
    syncTimeout
  );

export const insufficientFundsMessage = (
  address: Cardano.PaymentAddress,
  min: bigint,
  actual: bigint
) => `Insufficient funds at ${address}. Expected ${min}, found ${actual} lovelace.
      Please use a faucet to fund the address or another address with sufficient funds`;

export const walletReady = async (
  wallet: ObservableWallet,
  minCoinBalance = 1n,
  syncTimeout = SYNC_TIMEOUT_DEFAULT
): Promise<[boolean, Cardano.Value]> => {
  const [isSettled, balance, address] = await firstValueFromTimed(
    combineLatest([
      wallet.syncStatus.isSettled$,
      wallet.balance.utxo.total$,
      wallet.addresses$.pipe(map((addresses) => addresses[0].address))
    ]).pipe(filter(([settled]) => settled)),
    'Took too long to be ready',
    syncTimeout
  );

  if (balance.coins < minCoinBalance) {
    throw new Error(insufficientFundsMessage(address, minCoinBalance, balance.coins));
  }

  return [isSettled, balance];
};

const sortTxIn = (txInCollection: Cardano.TxIn[] | undefined): Cardano.TxIn[] =>
  sortBy(txInCollection, ['txId', 'index']);

export const normalizeTxBody = (body: Cardano.HydratedTxBody | Cardano.TxBody) => {
  // TODO: inputs should be a Set since they're unordered.
  // Then Jest should correctly compare it with toEqual.
  body.inputs = sortTxIn(body.inputs);
  body.collaterals = sortTxIn(body.collaterals);
  body.referenceInputs = sortTxIn(body.referenceInputs);
  return body;
};

export const txConfirmed = (
  {
    tip$,
    transactions: {
      history$,
      outgoing: { failed$ }
    }
  }: ObservableWallet,
  { id }: Pick<Cardano.Tx, 'id'>,
  numConfirmations = 3
) =>
  firstValueFromTimed(
    merge(
      history$.pipe(
        switchMap((txs) => {
          const tx = txs.find((historyTx) => historyTx.id === id);
          if (!tx) return EMPTY;
          return tip$.pipe(
            filter(({ blockNo }) => blockNo >= Cardano.BlockNo(tx.blockHeader.blockNo + numConfirmations)),
            map(() => tx)
          );
        })
      ),
      failed$.pipe(
        mergeMap((outgoingTx) =>
          outgoingTx.id === id
            ? throwError(
                () => outgoingTx.error || new Error(`Tx failed due to '${outgoingTx.reason}': ${outgoingTx.id}`)
              )
            : EMPTY
        )
      )
    ),
    `Tx confirmation timeout: ${id}`,
    SYNC_TIMEOUT_DEFAULT / 5
  );

const submit = (wallet: ObservableWallet, tx: Cardano.Tx) => wallet.submitTx(tx);
const confirm = (wallet: ObservableWallet, tx: Cardano.Tx) => txConfirmed(wallet, tx);
export const submitAndConfirm = (wallet: ObservableWallet, tx: Cardano.Tx) =>
  Promise.all([submit(wallet, tx), confirm(wallet, tx)]);

export type RequestCoinsProps = {
  wallet: ObservableWallet;
  coins: Cardano.Lovelace;
};

export type TransferCoinsProps = {
  fromWallet: ObservableWallet;
  toWallet: ObservableWallet;
  coins: Cardano.Lovelace;
};

export const transferCoins = async ({ fromWallet, toWallet, coins }: TransferCoinsProps) => {
  // Arrange
  const [{ address: sendingAddress }] = await firstValueFrom(fromWallet.addresses$);
  const [{ address: receivingAddress }] = await firstValueFrom(toWallet.addresses$);
  logger.info(`Address ${sendingAddress} will send ${coins} lovelace to address ${receivingAddress}.`);

  // Act
  // Send 50 tADA to second wallet.
  const txBuilder = fromWallet.createTxBuilder();
  const txOut = await txBuilder.buildOutput().address(receivingAddress).coin(coins).build();
  const { tx: signedTx } = await txBuilder.addOutput(txOut).build().sign();

  // Wait until wallet two is aware of the funds.
  await Promise.all([fromWallet.submitTx(signedTx), txConfirmed(toWallet, signedTx)]);
};

export const waitForEpoch = (wallet: Pick<ObservableWallet, 'currentEpoch$'>, waitForEpochNo: number) => {
  logger.info(`Waiting for epoch #${waitForEpochNo}`);
  return firstValueFrom(
    wallet.currentEpoch$.pipe(
      map(({ epochNo }) => epochNo),
      distinctUntilChanged(),
      tap((epochNo) => logger.info(`Currently at epoch #${epochNo}`)),
      filter((currentEpochNo) => currentEpochNo >= waitForEpochNo)
    )
  );
};

export const runningAgainstLocalNetwork = async () => {
  const networkInfoProvider = await networkInfoProviderFactory.create(
    env.NETWORK_INFO_PROVIDER,
    env.NETWORK_INFO_PROVIDER_PARAMS,
    logger
  );
  const { epochLength, slotLength } = await networkInfoProvider.genesisParameters();

  const estimatedTestDurationInEpochs = 4;
  const localNetworkEpochDuration = 1000 * 0.2;
  const estimatedTestDuration = epochLength * slotLength * estimatedTestDurationInEpochs;
  if (estimatedTestDuration > localNetworkEpochDuration * estimatedTestDurationInEpochs) {
    return false;
  }
  return true;
};

/**
 * Gets the epoch when a transaction **was confirmed**.
 *
 * @param wallet The wallet used to perform the required actions
 * @param tx The **already confirmed** transaction we need to know the confirmation epoch
 * @returns The epoch when the given transaction was confirmed
 */
export const getTxConfirmationEpoch = async (wallet: PersonalWallet, tx: Cardano.Tx<Cardano.TxBody>) => {
  const txs = await firstValueFrom(wallet.transactions.history$.pipe(filter((_) => _.some(({ id }) => id === tx.id))));
  const observedTx = txs.find(({ id }) => id === tx.id);
  const slotEpochCalc = createSlotEpochCalc(await firstValueFrom(wallet.eraSummaries$));

  return slotEpochCalc(observedTx!.blockHeader.slot);
};

/**
 * Submit certificates on behalf of the given wallet.
 *
 * @param certificate The certificate to be send.
 * @param wallet The wallet
 */
export const submitCertificate = async (certificate: Cardano.Certificate, wallet: TestWallet) => {
  const walletAddress = (await firstValueFrom(wallet.wallet.addresses$))[0].address;
  const txProps: InitializeTxProps = {
    certificates: [certificate],
    outputs: new Set([{ address: walletAddress, value: { coins: 3_000_000n } }])
  };

  const unsignedTx = await wallet.wallet.initializeTx(txProps);
  const signedTx = await wallet.wallet.finalizeTx({ tx: unsignedTx });

  await submitAndConfirm(wallet.wallet, signedTx);

  return signedTx;
};

/**
 * Creates a key agent from a given set of mnemonics and the network id.
 * Input resolver always resolves to 'null', so this KeyAgent won't be able to determine
 * payment keys when signing a transaction.
 *
 * @param mnemonics The random set of mnemonics.
 * @param genesis Network genesis parameters
 * @param bip32Ed25519 The Ed25519 cryptography implementation.
 */
export const createStandaloneKeyAgent = async (
  mnemonics: string[],
  genesis: Cardano.CompactGenesis,
  bip32Ed25519: Crypto.Bip32Ed25519
) =>
  await InMemoryKeyAgent.fromBip39MnemonicWords(
    {
      chainId: genesis,
      getPassphrase: async () => Buffer.from(''),
      mnemonicWords: mnemonics
    },
    { bip32Ed25519, inputResolver: { resolveInput: async () => null }, logger }
  );

/**
 * Create burn transaction to cleanup minted assets in tests.
 * Each test or test suite should call this function to remove any minted assets.
 * Pass `tokens` with positive value. This method will negate them.
 * In case `tokens` is undefined, all wallet tokens will be burned.
 */
export const burnTokens = async ({
  wallet,
  tokens,
  scripts,
  policySigners: extraSigners
}: {
  wallet: PersonalWallet;
  tokens?: Cardano.TokenMap;
  scripts: Cardano.Script[];
  policySigners: TransactionSigner[];
}) => {
  if (!tokens) {
    tokens = (await firstValueFrom(wallet.balance.utxo.available$)).assets;
  }

  if (!tokens?.size) {
    return; // nothing to burn
  }

  const negativeTokens = new Map([...tokens].map(([assetId, value]) => [assetId, -value]));
  const txProps: InitializeTxProps = {
    mint: negativeTokens,
    witness: { extraSigners, scripts }
  };

  const unsignedTx = await wallet.initializeTx(txProps);

  const finalizeProps: FinalizeTxProps = {
    tx: unsignedTx,
    witness: { extraSigners, scripts }
  };

  const signedTx = await wallet.finalizeTx(finalizeProps);
  await submitAndConfirm(wallet, signedTx);
  await txConfirmed(wallet, signedTx);
};
