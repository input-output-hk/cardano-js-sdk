import * as Crypto from '@cardano-sdk/crypto';
import { BaseWallet } from '@cardano-sdk/wallet';
import { Cardano, EraSummary, StakePoolProvider, createSlotEpochCalc } from '@cardano-sdk/core';
import { InMemoryKeyAgent, KeyRole } from '@cardano-sdk/key-management';
import { MultiSigTx } from './MultiSigTx';
import { MultiSigWallet } from './MultiSigWallet';
import { Observable, filter, firstValueFrom, map, take } from 'rxjs';
import { TrackerSubject } from '@cardano-sdk/util-rxjs';
import {
  bip32Ed25519Factory,
  createStandaloneKeyAgent,
  getEnv,
  getWallet,
  waitForEpoch,
  walletReady,
  walletVariables
} from '../../../src';
import { isNotNil } from '@cardano-sdk/util';
import { logger } from '@cardano-sdk/util-dev';

const env = getEnv(walletVariables);

// eslint-disable-next-line max-len
const aliceMnemonics =
  'decorate survey empower stairs pledge humble social leisure baby wrap grief exact monster rug dash kiss perfect select science light frame play swallow day';

// eslint-disable-next-line max-len
const bobMnemonics =
  'salon zoo engage submit smile frost later decide wing sight chaos renew lizard rely canal coral scene hobby scare step bus leaf tobacco slice';

// eslint-disable-next-line max-len
const charlotteMnemonics =
  'phrase raw learn suspect inmate powder combine apology regular hero gain chronic fruit ritual short screen goddess odor keen creek brand today kit machine';

const DERIVATION_PATH = {
  index: 0,
  role: KeyRole.External
};

const getPoolIds = async (stakePoolProvider: StakePoolProvider, count: number) => {
  const activePools = await stakePoolProvider.queryStakePools({
    filters: { pledgeMet: true, status: [Cardano.StakePoolStatus.Active] },
    pagination: { limit: count, startAt: 0 }
  });
  expect(activePools.totalResultCount).toBeGreaterThanOrEqual(count);
  const poolIds = activePools.pageResults.map(({ id }) => id);
  expect(poolIds.every((poolId) => poolId !== undefined)).toBeTruthy();
  logger.info('Wallet funds will be staked to pools:', poolIds);
  return poolIds;
};

const fundMultiSigWallet = async (sendingWallet: BaseWallet, address: Cardano.PaymentAddress) => {
  logger.info(`Funding multisig wallet with address: ${address}`);

  const tAdaToSend = 5_000_000n;

  const txBuilder = sendingWallet.createTxBuilder();
  const txOut = await txBuilder.buildOutput().address(address).coin(tAdaToSend).build();
  const { tx: signedTx } = await txBuilder.addOutput(txOut).build().sign();
  await sendingWallet.submitTx(signedTx);
};

const getKeyAgent = async (mnemonics: string, faucetWallet: BaseWallet, bip32Ed25519: Crypto.Bip32Ed25519) => {
  const genesis = await firstValueFrom(faucetWallet.genesisParameters$);

  const keyAgent = await createStandaloneKeyAgent(mnemonics.split(' '), genesis, bip32Ed25519);

  const pubKey = await keyAgent.derivePublicKey(DERIVATION_PATH);

  return { keyAgent, pubKey };
};

const generateTxs = async (sendingWallet: BaseWallet, receivingWallet: BaseWallet) => {
  logger.info('Sending 100 txs to generate reward fees');

  const tAdaToSend = 5_000_000n;
  const [{ address: receivingAddress }] = await firstValueFrom(receivingWallet.addresses$);

  for (let i = 0; i < 100; i++) {
    const txBuilder = sendingWallet.createTxBuilder();
    const txOut = await txBuilder.buildOutput().address(receivingAddress).coin(tAdaToSend).build();
    const { tx: signedTx } = await txBuilder.addOutput(txOut).build().sign();
    await sendingWallet.submitTx(signedTx);
  }
};

const createMultiSignWallet = async (
  keyAgent: InMemoryKeyAgent,
  faucetWallet: BaseWallet,
  participants: Array<Crypto.Ed25519PublicKeyHex>
) => {
  const props = {
    chainHistoryProvider: faucetWallet.chainHistoryProvider,
    expectedSigners: participants,
    inMemoryKeyAgent: keyAgent,
    networkId: env.KEY_MANAGEMENT_PARAMS.chainId.networkId,
    networkInfoProvider: faucetWallet.networkInfoProvider,
    pollingInterval: 50,
    rewardsProvider: faucetWallet.rewardsProvider,
    txSubmitProvider: faucetWallet.txSubmitProvider,
    utxoProvider: faucetWallet.utxoProvider
  };

  return await MultiSigWallet.createMultiSigWallet(props);
};

const getTxConfirmationEpoch = async (
  history$: Observable<Cardano.HydratedTx[]>,
  tx: Cardano.Tx<Cardano.TxBody>,
  eraSummaries$: TrackerSubject<EraSummary[]>
) => {
  const txs = await firstValueFrom(history$.pipe(filter((_) => _.some(({ id }) => id === tx.id))));
  const observedTx = txs.find(({ id }) => id === tx.id);
  const slotEpochCalc = createSlotEpochCalc(await firstValueFrom(eraSummaries$));

  return slotEpochCalc(observedTx!.blockHeader.slot);
};

describe('multi signature wallet', () => {
  let faucetWallet: BaseWallet;
  let aliceKeyAgent: InMemoryKeyAgent;
  let bobKeyAgent: InMemoryKeyAgent;
  let charlotteKeyAgent: InMemoryKeyAgent;
  let alicePubKey: Crypto.Ed25519PublicKeyHex;
  let bobPubKey: Crypto.Ed25519PublicKeyHex;
  let charlottePubKey: Crypto.Ed25519PublicKeyHex;
  let faucetAddress: Cardano.PaymentAddress;
  let aliceMultiSigWallet: MultiSigWallet;
  let bobMultiSigWallet: MultiSigWallet;
  let charlotteMultiSigWallet: MultiSigWallet;
  let multiSigParticipants: Crypto.Ed25519PublicKeyHex[];
  let stakePoolProvider: StakePoolProvider;

  const initializeFaucet = async () => {
    ({
      wallet: faucetWallet,
      providers: { stakePoolProvider }
    } = await getWallet({
      env,
      logger,
      name: 'Faucet Wallet',
      polling: { interval: 50 }
    }));

    await walletReady(faucetWallet);
  };

  beforeAll(async () => {
    await initializeFaucet();
    const bip32Ed25519 = await bip32Ed25519Factory.create(env.KEY_MANAGEMENT_PARAMS.bip32Ed25519, null, logger);

    ({ keyAgent: aliceKeyAgent, pubKey: alicePubKey } = await getKeyAgent(aliceMnemonics, faucetWallet, bip32Ed25519));
    ({ keyAgent: bobKeyAgent, pubKey: bobPubKey } = await getKeyAgent(bobMnemonics, faucetWallet, bip32Ed25519));
    ({ keyAgent: charlotteKeyAgent, pubKey: charlottePubKey } = await getKeyAgent(
      charlotteMnemonics,
      faucetWallet,
      bip32Ed25519
    ));

    faucetAddress = (await firstValueFrom(faucetWallet.addresses$))[0].address;

    multiSigParticipants = [alicePubKey, bobPubKey, charlottePubKey];

    aliceMultiSigWallet = await createMultiSignWallet(aliceKeyAgent, faucetWallet, multiSigParticipants);
    bobMultiSigWallet = await createMultiSignWallet(bobKeyAgent, faucetWallet, multiSigParticipants);
    charlotteMultiSigWallet = await createMultiSignWallet(charlotteKeyAgent, faucetWallet, multiSigParticipants);
  });

  afterAll(() => {
    faucetWallet?.shutdown();
  });

  it('can receive balance and can spend balance', async () => {
    expect(aliceMultiSigWallet.getPaymentAddress()).toEqual(bobMultiSigWallet.getPaymentAddress());
    expect(aliceMultiSigWallet.getPaymentAddress()).toEqual(charlotteMultiSigWallet.getPaymentAddress());

    await fundMultiSigWallet(faucetWallet, bobMultiSigWallet.getPaymentAddress());

    const multiSigWalletBalance = await firstValueFrom(
      bobMultiSigWallet.getBalance().pipe(
        map((value) => value.coins),
        filter((value) => value > 0n),
        take(1)
      )
    );

    expect(multiSigWalletBalance).toBeGreaterThan(0n);

    // Alice will initiate the transaction on her wallet.
    let tx = await aliceMultiSigWallet.transferFunds(faucetAddress, { coins: 2_000_000n });

    // Alice then signs the transaction and relay it to Bob.
    tx = await aliceMultiSigWallet.sign(tx);
    const aliceSerializedTx = tx.toCbor();

    // .... Bob receives the transaction and signs it.
    let bobTx = MultiSigTx.fromCbor(aliceSerializedTx);
    bobTx = await bobMultiSigWallet.sign(bobTx);

    // Bob can then check if there are any missing signatures. If there are, he can then
    // check who is missing and send the transaction to them.
    expect(bobTx.isFullySigned()).toBe(false);
    expect(bobTx.getMissingSigners()).toEqual([charlottePubKey]);

    const bobSerializedTx = bobTx.toCbor();

    // .... Charlotte receives the transaction and signs it.
    let charlotteTx = MultiSigTx.fromCbor(bobSerializedTx);
    charlotteTx = await charlotteMultiSigWallet.sign(charlotteTx);

    // Charlotte can then check if there are any missing signatures. And if all signatures
    // are complete she can submit it to the network.
    expect(charlotteTx.getMissingSigners()).toEqual([]);
    expect(charlotteTx.isFullySigned()).toBe(true);
    const txId = await charlotteMultiSigWallet.submit(charlotteTx);

    // Search chain history to see if the transaction is there.
    const txFoundInHistory = await firstValueFrom(
      faucetWallet.transactions.history$.pipe(
        map((txs) => txs.find((hTx) => hTx.id === txId)),
        filter(isNotNil),
        take(1)
      )
    );

    expect(txFoundInHistory).toBeTruthy();
  });

  // eslint-disable-next-line max-statements
  it('delegate to a pool and claim rewards', async () => {
    expect(aliceMultiSigWallet.getRewardAccount()).toEqual(bobMultiSigWallet.getRewardAccount());
    expect(aliceMultiSigWallet.getRewardAccount()).toEqual(charlotteMultiSigWallet.getRewardAccount());

    await fundMultiSigWallet(faucetWallet, bobMultiSigWallet.getPaymentAddress());

    const multiSigWalletBalance = await firstValueFrom(
      bobMultiSigWallet.getBalance().pipe(
        map((value) => value.coins),
        filter((value) => value > 0n),
        take(1)
      )
    );

    expect(multiSigWalletBalance).toBeGreaterThan(0n);

    const [poolId] = await getPoolIds(stakePoolProvider, 1);

    // Alice will initiate the delegation transaction on her wallet.
    let tx = await aliceMultiSigWallet.delegate(poolId);
    tx = await aliceMultiSigWallet.sign(tx);
    tx = await bobMultiSigWallet.sign(tx);
    tx = await charlotteMultiSigWallet.sign(tx);

    const txId = await charlotteMultiSigWallet.submit(tx);

    // Search chain history to see if the transaction is there.
    const txFoundInHistory = await firstValueFrom(
      charlotteMultiSigWallet.getTransactionHistory().pipe(
        map((txs) => txs.find((hTx) => hTx.id === txId)),
        filter(isNotNil),
        take(1)
      )
    );

    expect(txFoundInHistory).toBeTruthy();

    // Delegation is completed. Now we wait for rewards to be available.
    const delegationTxConfirmedAtEpoch = await getTxConfirmationEpoch(
      charlotteMultiSigWallet.getTransactionHistory(),
      tx.getTransaction(),
      faucetWallet.eraSummaries$
    );

    logger.info(`Delegation tx confirmed at epoch #${delegationTxConfirmedAtEpoch}`);

    await waitForEpoch(faucetWallet, delegationTxConfirmedAtEpoch + 2);
    await generateTxs(faucetWallet, faucetWallet);
    await waitForEpoch(faucetWallet, delegationTxConfirmedAtEpoch + 4);

    // Check reward
    const multiSigWalletRewardBalance = await firstValueFrom(
      bobMultiSigWallet.getRewardAccountBalance().pipe(
        filter((value) => value > 0n),
        take(1)
      )
    );

    expect(multiSigWalletRewardBalance).toBeGreaterThan(0n);

    logger.info(`Generated rewards: ${multiSigWalletRewardBalance} tLovelace`);

    tx = await aliceMultiSigWallet.transferFunds(faucetAddress, { coins: 2_000_000n });
    expect(tx.getTransaction().body.withdrawals?.length).toBeGreaterThan(0);

    tx = await aliceMultiSigWallet.sign(tx);
    tx = await bobMultiSigWallet.sign(tx);
    tx = await charlotteMultiSigWallet.sign(tx);

    const spendRewardsTx = await charlotteMultiSigWallet.submit(tx);

    // Search chain history to see if the transaction is there.
    const spendRewardsTxFoundInHistory = await firstValueFrom(
      faucetWallet.transactions.history$.pipe(
        map((txs) => txs.find((hTx) => hTx.id === spendRewardsTx)),
        filter(isNotNil),
        take(1)
      )
    );

    expect(spendRewardsTxFoundInHistory).toBeTruthy();

    // Check reward
    const finalRewardBalance = await firstValueFrom(
      bobMultiSigWallet.getRewardAccountBalance().pipe(
        filter((value) => value === 0n),
        take(1)
      )
    );

    expect(finalRewardBalance).toEqual(0n);
  });
});
