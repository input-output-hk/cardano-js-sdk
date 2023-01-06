/* eslint-disable @typescript-eslint/no-explicit-any */
import * as envalid from 'envalid';
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
import { InMemoryKeyAgent } from '@cardano-sdk/key-management';
import { ObservableWallet, SignedTx, SingleAddressWallet, buildTx } from '@cardano-sdk/wallet';
import { TestWallet, faucetProviderFactory, getEnv, networkInfoProviderFactory, walletVariables } from '../src';
import { assertTxIsValid } from '../../wallet/test/util';
import { logger } from '@cardano-sdk/util-dev';
import sortBy from 'lodash/sortBy';

const env = getEnv(walletVariables);

const SECOND = 1000;
const MINUTE = 60 * SECOND;
export const TX_TIMEOUT = 7 * MINUTE;
const SYNC_TIMEOUT = 3 * MINUTE;
const BALANCE_TIMEOUT = 3 * MINUTE;

export const FAST_OPERATION_TIMEOUT = 15 * SECOND;

export const firstValueFromTimed = <T>(
  observable$: Observable<T>,
  timeoutMessage = 'Timed out',
  timeoutAfter = FAST_OPERATION_TIMEOUT
) =>
  firstValueFrom(
    observable$.pipe(
      timeout(timeoutAfter),
      catchError(() => throwError(() => new Error(timeoutMessage)))
    )
  );

export const waitForWalletStateSettle = (wallet: ObservableWallet) =>
  firstValueFromTimed(
    wallet.syncStatus.isSettled$.pipe(filter((isSettled) => isSettled)),
    'Took too long to settle',
    SYNC_TIMEOUT
  );

export const waitForWalletBalance = (wallet: ObservableWallet) =>
  firstValueFromTimed(
    wallet.balance.utxo.total$.pipe(filter(({ coins }) => coins > 0)),
    'Took too long to load balance',
    BALANCE_TIMEOUT
  );

export const walletReady = (wallet: ObservableWallet) =>
  firstValueFromTimed(
    combineLatest([wallet.syncStatus.isSettled$, wallet.balance.utxo.total$]).pipe(
      filter(([isSettled, balance]) => isSettled && balance.coins > 0n)
    ),
    'Took too long to be ready',
    SYNC_TIMEOUT
  );

export const normalizeTxBody = (body: Cardano.HydratedTxBody | Cardano.TxBody) => {
  body.collaterals ||= [];
  // TODO: inputs should be a Set since they're unordered.
  // Then Jest should correctly compare it with toEqual.
  body.inputs = sortBy(body.inputs, 'txId');
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
            filter(({ blockNo }) => blockNo >= Cardano.BlockNo(tx.blockHeader.blockNo.valueOf() + numConfirmations)),
            map(() => tx)
          );
        })
      ),
      failed$.pipe(
        mergeMap(({ tx, error, reason }) =>
          tx.id === id ? throwError(() => error || new Error(`Tx failed due to '${reason}': ${id}`)) : EMPTY
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
  logger.info(`Address ${address.toString()} will be funded with ${coins} tLovelace.`);

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
  const requestResult = await faucetProvider.request(address.toString(), Number.parseInt(coins.toString()), 3, 30_000);
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
  logger.info(
    `Address ${sendingAddress.toString()} will send ${coins} lovelace to address ${receivingAddress.toString()}.`
  );

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
      filter((currentEpochNo) => currentEpochNo.valueOf() >= waitForEpochNo)
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
  const txProps = {
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
 */
export const createStandaloneKeyAgent = async (mnemonics: string[], genesis: Cardano.CompactGenesis) =>
  await InMemoryKeyAgent.fromBip39MnemonicWords(
    {
      chainId: genesis,
      getPassword: async () => Buffer.from(''),
      mnemonicWords: mnemonics
    },
    { inputResolver: { resolveInputAddress: async () => null }, logger }
  );
