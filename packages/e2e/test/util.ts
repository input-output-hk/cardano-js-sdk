/* eslint-disable @typescript-eslint/no-explicit-any */
import * as Crypto from '@cardano-sdk/crypto';
import * as envalid from 'envalid';
import {
  BALANCE_TIMEOUT_DEFAULT,
  FAST_OPERATION_TIMEOUT_DEFAULT,
  SYNC_TIMEOUT_DEFAULT,
  TestWallet,
  faucetProviderFactory,
  getEnv,
  networkInfoProviderFactory,
  walletVariables
} from '../src';
import { Cardano, createSlotEpochCalc } from '@cardano-sdk/core';
import {
  EMPTY,
  Observable,
  catchError,
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
import {
  FinalizeTxProps,
  InitializeTxProps,
  ObservableWallet,
  SignedTx,
  SingleAddressWallet,
  buildTx
} from '@cardano-sdk/wallet';
import { InMemoryKeyAgent, TransactionSigner } from '@cardano-sdk/key-management';
import { assertTxIsValid } from '../../wallet/test/util';
import { logger } from '@cardano-sdk/util-dev';
import sortBy from 'lodash/sortBy';

const env = getEnv(walletVariables);

export const firstValueFromTimed = <T>(
  observable$: Observable<T>,
  timeoutMessage = 'Timed out',
  timeoutAfter = FAST_OPERATION_TIMEOUT_DEFAULT
) =>
  firstValueFrom(
    observable$.pipe(
      timeout(timeoutAfter),
      catchError(() => throwError(() => new Error(timeoutMessage)))
    )
  );

export const waitForWalletStateSettle = (wallet: ObservableWallet, syncTimeout: number = SYNC_TIMEOUT_DEFAULT) =>
  firstValueFromTimed(
    wallet.syncStatus.isSettled$.pipe(filter((isSettled) => isSettled)),
    'Took too long to settle',
    syncTimeout
  );

export const waitForWalletBalance = (wallet: ObservableWallet) =>
  firstValueFromTimed(
    wallet.balance.utxo.total$.pipe(filter(({ coins }) => coins > 0)),
    'Took too long to load balance',
    BALANCE_TIMEOUT_DEFAULT
  );

export const walletReady = (wallet: ObservableWallet) =>
  firstValueFromTimed(
    combineLatest([wallet.syncStatus.isSettled$, wallet.balance.utxo.total$]).pipe(
      filter(([isSettled, balance]) => isSettled && balance.coins > 0n)
    ),
    'Took too long to be ready',
    SYNC_TIMEOUT_DEFAULT
  );

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
  firstValueFrom(
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
    )
  );

const submit = (wallet: ObservableWallet, tx: Cardano.Tx | SignedTx) =>
  'submit' in tx ? tx.submit() : wallet.submitTx(tx);
const confirm = (wallet: ObservableWallet, tx: Cardano.Tx | SignedTx) => txConfirmed(wallet, 'tx' in tx ? tx.tx : tx);
export const submitAndConfirm = (wallet: ObservableWallet, tx: Cardano.Tx | SignedTx) =>
  Promise.all([submit(wallet, tx), confirm(wallet, tx)]);

export type RequestCoinsProps = {
  wallet: ObservableWallet;
  coins: Cardano.Lovelace;
};

export const requestCoins = async ({ coins, wallet }: RequestCoinsProps) => {
  const [{ address }] = await firstValueFrom(wallet.addresses$);
  logger.info(`Address ${address} will be funded with ${coins} tLovelace.`);

  const { FAUCET_PROVIDER, FAUCET_PROVIDER_PARAMS } = envalid.cleanEnv(process.env, {
    FAUCET_PROVIDER: envalid.str(),
    FAUCET_PROVIDER_PARAMS: envalid.json({ default: {} })
  });

  const faucetProvider = await faucetProviderFactory.create(FAUCET_PROVIDER, FAUCET_PROVIDER_PARAMS, logger);
  await faucetProvider.start();
  const healthCheck = await faucetProvider.healthCheck();
  if (!healthCheck.ok) throw new Error('Faucet provider could not be started.');
  // Request coins from faucet. This will block until the transaction is in the ledger,
  // and has the given amount of confirmation, which means the funds can be used immediately after
  // this call.
  // TODO: change FaucetProvider signature to accept Cardano.Lovelace
  const requestResult = await faucetProvider.request(address, Number.parseInt(coins.toString()), 3, 30_000);
  await txConfirmed(wallet, requestResult);
  await faucetProvider.close();
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
  const txBuilder = buildTx({ logger, observableWallet: fromWallet });
  const txOut = txBuilder.buildOutput().address(receivingAddress).coin(coins).toTxOut();
  const unsignedTx = await txBuilder.addOutput(txOut).build();
  assertTxIsValid(unsignedTx);
  const signedTx = await unsignedTx.sign();

  // Wait until wallet two is aware of the funds.
  await Promise.all([submit(fromWallet, signedTx), txConfirmed(toWallet, signedTx.tx)]);
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
export const getTxConfirmationEpoch = async (wallet: SingleAddressWallet, tx: Cardano.Tx<Cardano.TxBody>) => {
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
  wallet: SingleAddressWallet;
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
    scripts,
    witness: { extraSigners }
  };

  const unsignedTx = await wallet.initializeTx(txProps);

  const finalizeProps: FinalizeTxProps = {
    scripts,
    tx: unsignedTx,
    witness: { extraSigners }
  };

  const signedTx = await wallet.finalizeTx(finalizeProps);
  await submitAndConfirm(wallet, signedTx);

  // Wait until all assets are burned
  await firstValueFromTimed(
    wallet.balance.utxo.available$.pipe(
      map(({ assets: availableAssets }) => availableAssets),
      filter(
        (availableAssets) =>
          !availableAssets?.size ||
          ![...tokens!].some(([id]) => [...availableAssets].some(([assetId]) => assetId === id))
      )
    ),
    'Not all assets were burned',
    FAST_OPERATION_TIMEOUT_DEFAULT
  );
};
