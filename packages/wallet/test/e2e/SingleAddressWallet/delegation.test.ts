import { Cardano } from '@cardano-sdk/core';
import { SingleAddressWallet, StakeKeyStatus, Wallet } from '../../../src';
import { TX_TIMEOUT, firstValueFromTimed, waitForWalletStateSettle } from '../../util';
import { TxInternals } from '../../../src/Transaction';
import {
  assetProvider,
  keyAgentReady,
  poolId1,
  poolId2,
  stakePoolSearchProvider,
  timeSettingsProvider,
  txSubmitProvider,
  walletProvider
} from '../config';
import { combineLatest, filter, firstValueFrom } from 'rxjs';

const faucetAddress = Cardano.Address(
  'addr_test1qqr585tvlc7ylnqvz8pyqwauzrdu0mxag3m7q56grgmgu7sxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flknswgndm3'
);

const getWalletStateSnapshot = (wallet: Wallet) => {
  const [rewardAccount] = wallet.delegation.rewardAccounts$.value!;
  return {
    balance: { available: wallet.balance.available$.value!, total: wallet.balance.total$.value! },
    epoch: wallet.networkInfo$.value!.currentEpoch.number,
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
  return {
    certificates: [
      ...(isStakeKeyRegistered
        ? []
        : ([{ __typename: Cardano.CertificateType.StakeKeyRegistration, rewardAccount }] as Cardano.Certificate[])),
      { __typename: Cardano.CertificateType.StakeDelegation, epoch, poolId, rewardAccount }
    ] as Cardano.Certificate[],
    poolId
  };
};

const waitForTx = async (wallet: Wallet, { hash }: TxInternals) => {
  await firstValueFromTimed(
    combineLatest([
      wallet.transactions.history.all$.pipe(filter((txs) => txs.some(({ tx: { id } }) => id === hash))),
      // test that confirmed$ works
      wallet.transactions.outgoing.confirmed$.pipe(filter(({ id }) => id === hash))
    ]),
    'Tx not confirmed for too long',
    TX_TIMEOUT
  );
  await waitForWalletStateSettle(wallet);
};

describe('SingleAddressWallet/delegation', () => {
  let rewardAccount: Cardano.RewardAccount;
  let wallet: Wallet;

  beforeAll(async () => {
    wallet = new SingleAddressWallet(
      { name: 'Test Wallet' },
      {
        assetProvider: await assetProvider,
        keyAgent: await keyAgentReady,
        stakePoolSearchProvider,
        timeSettingsProvider,
        txSubmitProvider: await txSubmitProvider,
        walletProvider: await walletProvider
      }
    );
    await waitForWalletStateSettle(wallet);
    [{ rewardAccount }] = await firstValueFrom(wallet.addresses$);
  });

  afterAll(() => wallet.shutdown());

  it('has an address', async () => {
    expect(wallet.addresses$.value![0].address.startsWith('addr')).toBe(true);
  });

  // eslint-disable-next-line max-statements
  test('balance & transaction', async () => {
    const stakeKeyDeposit = BigInt(wallet.protocolParameters$.value!.stakeKeyDeposit);
    const initialState = getWalletStateSnapshot(wallet);
    expect(initialState.balance.total.coins).toBeGreaterThan(0n);
    expect(initialState.balance.total.coins).toBe(initialState.balance.available.coins);
    const tx1OutputCoins = 1_000_000n;

    const { poolId, certificates } = createDelegationCertificates(initialState);
    const initialDeposit = initialState.isStakeKeyRegistered ? stakeKeyDeposit : 0n;
    expect(initialState.balance.available.deposit).toBe(initialDeposit);

    // Make a 1st tx with key registration (if not already registered) and stake delegation
    // Also send some coin to faucet
    const tx1Internals = await wallet.initializeTx({
      certificates,
      outputs: new Set([{ address: faucetAddress, value: { coins: tx1OutputCoins } }])
    });
    await wallet.submitTx(await wallet.finalizeTx(tx1Internals));

    // Test it locks available balance after tx is submitted
    await firstValueFromTimed(
      wallet.transactions.outgoing.inFlight$.pipe(filter((inFlight) => inFlight.length === 1)),
      'No tx in flight'
    );

    const tx1PendingState = getWalletStateSnapshot(wallet);
    expect(tx1PendingState.balance.total).toEqual(initialState.balance.total);
    const expectedCoinsWhileTxPending =
      initialState.balance.total.coins -
      Cardano.util.coalesceValueQuantities(
        tx1Internals.body.inputs.map(
          (txInput) => initialState.utxo.total.find(([txIn]) => txIn.txId === txInput.txId)![1].value
        )
      ).coins;
    // TODO: this sometimes fails with 1_000_000n available which is probably just 1 utxo
    expect(tx1PendingState.balance.available.coins).toBe(expectedCoinsWhileTxPending);

    await waitForTx(wallet, tx1Internals);
    const tx1ConfirmedState = getWalletStateSnapshot(wallet);

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
    const tx2Internals = await wallet.initializeTx({
      certificates: [{ __typename: Cardano.CertificateType.StakeKeyDeregistration, rewardAccount }]
    });
    await wallet.submitTx(await wallet.finalizeTx(tx2Internals));
    await waitForTx(wallet, tx2Internals);
    const tx2ConfirmedState = getWalletStateSnapshot(wallet);

    // No longer delegating
    expect(tx2ConfirmedState.rewardAccount.delegatee?.nextNextEpoch?.id).toBeUndefined();

    // Deposit is returned to wallet balance
    const expectedCoinsAfterTx2 = expectedCoinsAfterTx1 + stakeKeyDeposit - tx2Internals.body.fee;
    expect(tx2ConfirmedState.balance.total.coins).toBe(expectedCoinsAfterTx2);
    expect(tx2ConfirmedState.balance.total).toEqual(tx2ConfirmedState.balance.available);
    expect(tx2ConfirmedState.balance.total.deposit).toBe(0n);
  });
});
