/* eslint-disable max-statements */
import { Cardano } from '@cardano-sdk/core';
import { ObservableWallet, SingleAddressWallet, StakeKeyStatus, txInEquals } from '../../../src';
import { TX_TIMEOUT, firstValueFromTimed, waitForWalletStateSettle } from '../../util';
import { TxInternals } from '../../../src/Transaction';
import {
  assetProvider,
  keyAgentByIdx,
  networkInfoProvider,
  poolId1,
  poolId2,
  stakePoolProvider,
  txSubmitProvider,
  utxoProvider,
  walletProvider
} from '../config';
import { combineLatest, filter, firstValueFrom } from 'rxjs';

const getWalletStateSnapshot = (wallet: ObservableWallet) => {
  const [rewardAccount] = wallet.delegation.rewardAccounts$.value!;
  return {
    balance: { available: wallet.balance.available$.value!, total: wallet.balance.total$.value! },
    epoch: wallet.currentEpoch$.value!.epochNo,
    isStakeKeyRegistered: rewardAccount.keyStatus === StakeKeyStatus.Registered,
    rewardAccount,
    utxo: { available: wallet.utxo.total$.value!, total: wallet.utxo.available$.value! }
  };
};
type WalletStateSnapshot = ReturnType<typeof getWalletStateSnapshot>;

const createDelegationCertificates = ({
  epoch,
  isStakeKeyRegistered,
  rewardAccount: { delegatee: delegateeBefore1stTx, address: rewardAccount }
}: WalletStateSnapshot) => {
  // swap poolId if it's already delegating to one of the pools
  const poolId = delegateeBefore1stTx?.nextNextEpoch?.id === poolId2 ? poolId1 : poolId2;
  const stakeKeyHash = Cardano.Ed25519KeyHash.fromRewardAccount(rewardAccount);
  return {
    certificates: [
      ...(isStakeKeyRegistered
        ? []
        : ([
            {
              __typename: Cardano.CertificateType.StakeKeyRegistration,
              stakeKeyHash
            }
          ] as Cardano.Certificate[])),
      { __typename: Cardano.CertificateType.StakeDelegation, epoch, poolId, stakeKeyHash }
    ] as Cardano.Certificate[],
    poolId
  };
};

const waitForTx = async (wallet: ObservableWallet, { hash }: TxInternals) => {
  await firstValueFromTimed(
    combineLatest([
      wallet.transactions.history$.pipe(filter((txs) => txs.some(({ id }) => id === hash))),
      // test that confirmed$ works
      wallet.transactions.outgoing.confirmed$.pipe(filter(({ id }) => id === hash))
    ]),
    'Tx not confirmed for too long',
    TX_TIMEOUT
  );
  await waitForWalletStateSettle(wallet);
};

const getWallet = async (idx: number) =>
  new SingleAddressWallet(
    { name: `Test Wallet ${idx}` },
    {
      assetProvider: await assetProvider,
      keyAgent: await keyAgentByIdx(idx),
      networkInfoProvider: await networkInfoProvider,
      stakePoolProvider,
      txSubmitProvider: await txSubmitProvider,
      utxoProvider: await utxoProvider,
      walletProvider: await walletProvider
    }
  );

describe('SingleAddressWallet/delegation', () => {
  let wallet1: ObservableWallet;
  let wallet2: ObservableWallet;

  beforeAll(async () => {
    jest.setTimeout(180_000);
    wallet1 = await getWallet(0);
    wallet2 = await getWallet(1);
    await Promise.all([waitForWalletStateSettle(wallet1), waitForWalletStateSettle(wallet2)]);
  });

  afterAll(() => {
    wallet1.shutdown();
    wallet2.shutdown();
  });

  const chooseWallets = async (): Promise<[ObservableWallet, ObservableWallet]> => {
    const wallet1Balance = await firstValueFrom(wallet1.balance.available$);
    const wallet2Balance = await firstValueFrom(wallet2.balance.available$);
    return wallet1Balance.coins > wallet2Balance.coins ? [wallet1, wallet2] : [wallet2, wallet1];
  };

  test('delegation preconditions', () => {
    expect(wallet1.addresses$.value![0].rewardAccount).toBeTruthy();
    expect(wallet1.currentEpoch$.value!.epochNo).toBeGreaterThan(0);
  });

  // eslint-disable-next-line max-statements
  test('balance & transaction', async () => {
    // source wallet has the highest balance to begin with
    const [sourceWallet, destWallet] = await chooseWallets();
    const [{ rewardAccount }] = await firstValueFrom(sourceWallet.addresses$);

    const stakeKeyDeposit = BigInt(sourceWallet.protocolParameters$.value!.stakeKeyDeposit);
    const initialState = getWalletStateSnapshot(sourceWallet);
    expect(initialState.balance.total.coins).toBeGreaterThan(0n);
    expect(initialState.balance.total.coins).toBe(initialState.balance.available.coins);
    const tx1OutputCoins = 1_000_000n;

    const { poolId, certificates } = createDelegationCertificates(initialState);
    const initialDeposit = initialState.isStakeKeyRegistered ? stakeKeyDeposit : 0n;
    expect(initialState.balance.available.deposit).toBe(initialDeposit);

    // Make a 1st tx with key registration (if not already registered) and stake delegation
    // Also send some coin to another wallet
    const destAddresses = (await firstValueFrom(destWallet.addresses$))[0].address;
    const tx1Internals = await sourceWallet.initializeTx({
      certificates,
      outputs: new Set([{ address: destAddresses, value: { coins: tx1OutputCoins } }])
    });
    await sourceWallet.submitTx(await sourceWallet.finalizeTx(tx1Internals));

    // Test it locks available balance after tx is submitted
    await firstValueFromTimed(
      sourceWallet.transactions.outgoing.inFlight$.pipe(filter((inFlight) => inFlight.length === 1)),
      'No tx in flight'
    );

    const tx1PendingState = getWalletStateSnapshot(sourceWallet);
    expect(tx1PendingState.balance.total).toEqual(initialState.balance.total);
    const expectedCoinsWhileTxPending =
      initialState.balance.total.coins -
      Cardano.util.coalesceValueQuantities(
        tx1Internals.body.inputs.map(
          (txInput) => initialState.utxo.total.find(([txIn]) => txInEquals(txIn, txInput))![1].value
        )
      ).coins;
    expect(tx1PendingState.balance.available.coins).toBe(expectedCoinsWhileTxPending);

    await waitForTx(sourceWallet, tx1Internals);
    const tx1ConfirmedState = getWalletStateSnapshot(sourceWallet);

    // Updates total and available balance after tx is confirmed
    const expectedCoinsAfterTx1 =
      initialState.balance.total.coins -
      tx1OutputCoins -
      tx1Internals.body.fee -
      (initialState.isStakeKeyRegistered ? 0n : stakeKeyDeposit);
    expect(tx1ConfirmedState.balance.total.coins).toBe(expectedCoinsAfterTx1);
    expect(tx1ConfirmedState.balance.total).toEqual(tx1ConfirmedState.balance.available);

    expect(tx1ConfirmedState.rewardAccount.delegatee?.nextNextEpoch!.id).toEqual(poolId);
    // nothing changes for 2 epochs
    expect(tx1ConfirmedState.rewardAccount.delegatee?.nextEpoch).toEqual(
      initialState.rewardAccount?.delegatee?.nextEpoch
    );
    expect(tx1ConfirmedState.rewardAccount.delegatee?.currentEpoch).toEqual(
      initialState.rewardAccount?.delegatee?.currentEpoch
    );

    // Make a 2nd tx with key deregistration
    const tx2Internals = await sourceWallet.initializeTx({
      certificates: [
        {
          __typename: Cardano.CertificateType.StakeKeyDeregistration,
          stakeKeyHash: Cardano.Ed25519KeyHash.fromRewardAccount(rewardAccount)
        }
      ]
    });
    await sourceWallet.submitTx(await sourceWallet.finalizeTx(tx2Internals));
    await waitForTx(sourceWallet, tx2Internals);
    const tx2ConfirmedState = getWalletStateSnapshot(sourceWallet);

    // No longer delegating
    expect(tx2ConfirmedState.rewardAccount.delegatee?.nextNextEpoch?.id).toBeUndefined();

    // Deposit is returned to wallet balance
    const expectedCoinsAfterTx2 = expectedCoinsAfterTx1 + stakeKeyDeposit - tx2Internals.body.fee;
    expect(tx2ConfirmedState.balance.total.coins).toBe(expectedCoinsAfterTx2);
    expect(tx2ConfirmedState.balance.total).toEqual(tx2ConfirmedState.balance.available);
    expect(tx2ConfirmedState.balance.total.deposit).toBe(0n);
  });
});
