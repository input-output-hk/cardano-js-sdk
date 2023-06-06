import { Cardano } from '@cardano-sdk/core';
import { DelegatedStake, PersonalWallet, createUtxoBalanceByAddressTracker } from '@cardano-sdk/wallet';
import { MINUTE, getWallet } from '../../../src';
import { Observable, filter, firstValueFrom, map, tap } from 'rxjs';
import { Percent } from '@cardano-sdk/util';
import { createLogger } from '@cardano-sdk/util-dev';
import { firstValueFromTimed, submitAndConfirm, walletReady } from '../../util';
import { getEnv, walletVariables } from '../../../src/environment';

const env = getEnv(walletVariables);
const logger = createLogger();
const TEST_FUNDS = 1_000_000_000n;

/** Distribute the wallet funds evenly across all its addresses */
const distributeFunds = async (wallet: PersonalWallet) => {
  await walletReady(wallet, 0n);
  const addresses = await firstValueFrom(wallet.addresses$);
  expect(addresses.length).toBeGreaterThan(1);

  // Check that we have enough funds. Otherwise, fund it from wallet account at index 0
  let { coins: totalCoins } = await firstValueFrom(wallet.balance.utxo.available$);

  const coinDeficit = TEST_FUNDS - totalCoins;
  if (coinDeficit > 10_000_000n) {
    logger.debug(
      `Insufficient funds in wallet account index 1. Missing ${coinDeficit}. Transferring from wallet account index 0`
    );
    const fundingWallet = (await getWallet({ env, idx: 0, logger, name: 'WalletAcct0', polling: { interval: 50 } }))
      .wallet;
    await walletReady(fundingWallet);
    const fundingTxBuilder = fundingWallet.createTxBuilder();
    const { tx } = await fundingTxBuilder
      .addOutput(fundingTxBuilder.buildOutput().address(addresses[0].address).coin(coinDeficit).toTxOut())
      .build()
      .sign();
    await submitAndConfirm(fundingWallet, tx);
    await walletReady(wallet);
    totalCoins = (await firstValueFrom(wallet.balance.utxo.available$)).coins;
  }

  const coinsPerAddress = totalCoins / BigInt(addresses.length);

  const txBuilder = wallet.createTxBuilder();

  logger.debug(`Sending ${coinsPerAddress} to the ${addresses.length - 1} derived addresses`);
  // The first one was generated when the wallet was created.
  for (let i = 1; i < addresses.length; ++i) {
    const derivedAddress = addresses[i];
    txBuilder.addOutput(txBuilder.buildOutput().address(derivedAddress.address).coin(coinsPerAddress).toTxOut());
  }

  const { tx: signedTx } = await txBuilder.build().sign();
  await submitAndConfirm(wallet, signedTx);
};

/** await for rewardAccounts$ to be registered, unregistered, as defined in states   */
const rewardAccountStatuses = async (
  rewardAccounts$: Observable<Cardano.RewardAccountInfo[]>,
  statuses: Cardano.StakeKeyStatus[]
) =>
  firstValueFromTimed(
    rewardAccounts$.pipe(
      tap((accts) => accts.map(({ address, keyStatus }) => logger.debug(address, keyStatus))),
      map((accts) => accts.map(({ keyStatus }) => keyStatus)),
      filter((statusArr) => statusArr.every((s) => statuses.includes(s)))
    ),
    `Timeout waiting for all reward accounts stake keys to be one of ${statuses.join('|')}`,
    MINUTE
  );

/** Create stakeKey deregistration transaction for all reward accounts */
const deregisterAllStakeKeys = async (wallet: PersonalWallet): Promise<void> => {
  const txBuilder = wallet.createTxBuilder();
  txBuilder.delegate();
  const { tx: deregTx } = await txBuilder.build().sign();
  await submitAndConfirm(wallet, deregTx);

  await rewardAccountStatuses(wallet.delegation.rewardAccounts$, [
    Cardano.StakeKeyStatus.Unregistered,
    Cardano.StakeKeyStatus.Unregistering
  ]);
  logger.debug('Deregistered all stake keys');
};

const createStakeKeyRegistrationCert = (rewardAccount: Cardano.RewardAccount): Cardano.Certificate => ({
  __typename: Cardano.CertificateType.StakeKeyRegistration,
  stakeKeyHash: Cardano.RewardAccount.toHash(rewardAccount)
});

const createDelegationCert = (rewardAccount: Cardano.RewardAccount, poolId: Cardano.PoolId): Cardano.Certificate => ({
  __typename: Cardano.CertificateType.StakeDelegation,
  poolId,
  stakeKeyHash: Cardano.RewardAccount.toHash(rewardAccount)
});

const getPoolIds = async (wallet: PersonalWallet, count: number): Promise<Cardano.StakePool[]> => {
  const activePools = await wallet.stakePoolProvider.queryStakePools({
    filters: { status: [Cardano.StakePoolStatus.Active] },
    pagination: { limit: count, startAt: 0 }
  });
  expect(activePools.pageResults.length).toBeGreaterThanOrEqual(count);
  return Array.from({ length: count }).map((_, index) => activePools.pageResults[index]);
};

const delegateToMultiplePools = async (wallet: PersonalWallet) => {
  // Delegating to multiple pools should be added in TxBuilder. Doing it manually for now.
  // Prepare stakeKey registration certificates
  const rewardAccounts = await firstValueFrom(wallet.delegation.rewardAccounts$);
  const stakeKeyRegCertificates = rewardAccounts.map(({ address }) => createStakeKeyRegistrationCert(address));

  const poolIds = await getPoolIds(wallet, rewardAccounts.length);
  const delegationCertificates = rewardAccounts.map(({ address }, index) =>
    createDelegationCert(address, poolIds[index].id)
  );

  logger.debug(
    `Delegating to pools ${poolIds.map(({ id }) => id)} and registering ${stakeKeyRegCertificates.length} stake keys`
  );

  const txBuilder = wallet.createTxBuilder();
  // Artificially add the certificates in TxBuilder. An api improvement will make the UX better
  txBuilder.partialTxBody.certificates = [...stakeKeyRegCertificates, ...delegationCertificates];
  const { tx } = await txBuilder.build().sign();
  await submitAndConfirm(wallet, tx);
  return poolIds;
};

describe('PersonalWallet/delegationDistribution', () => {
  let wallet: PersonalWallet;

  beforeAll(async () => {
    wallet = (await getWallet({ env, idx: 1, logger, name: 'Wallet', polling: { interval: 50 } })).wallet;
    await distributeFunds(wallet);
    await deregisterAllStakeKeys(wallet);
  });

  afterAll(() => {
    wallet.shutdown();
  });

  it('reports observable wallet multi delegation as delegationDistribution by pool', async () => {
    await walletReady(wallet);
    const walletAddresses = await firstValueFromTimed(wallet.addresses$);
    const rewardAccounts = await firstValueFrom(wallet.delegation.rewardAccounts$);

    // No stake distribution initially
    const delegationDistribution = await firstValueFrom(wallet.delegation.distribution$);
    expect(delegationDistribution).toEqual(new Map());

    const poolIds = await delegateToMultiplePools(wallet);

    // Check that reward addresses were delegated
    await walletReady(wallet);
    await rewardAccountStatuses(wallet.delegation.rewardAccounts$, [
      Cardano.StakeKeyStatus.Registering,
      Cardano.StakeKeyStatus.Registered
    ]);
    logger.debug('Delegations successfully done');

    const totalBalance = await firstValueFrom(wallet.balance.utxo.total$);
    const perAddrBalance = await Promise.all(
      rewardAccounts.map((_, index) => {
        const address = walletAddresses[index].address;
        return firstValueFrom(
          createUtxoBalanceByAddressTracker(wallet.utxo, [address]).utxo.total$.pipe(map(({ coins }) => coins))
        );
      })
    );

    // Check delegation.delegationDistribution$ has the delegation information
    const expectedDelegationDistribution: DelegatedStake[] = rewardAccounts.map(({ address }, index) => ({
      percentage: Percent(Number(perAddrBalance[index]) / Number(totalBalance.coins)),
      pool: expect.objectContaining({ id: poolIds[index].id }),
      rewardAccounts: [address],
      stake: perAddrBalance[index]
    }));
    const actualDelegationDistribution = await firstValueFrom(wallet.delegation.distribution$);

    expect([...actualDelegationDistribution.values()]).toEqual(expectedDelegationDistribution);

    // Send all coins to the last address. Check that stake distribution is 100 for that address and 0 for the rest
    const { coins: totalCoins } = await firstValueFrom(wallet.balance.utxo.total$);
    let txBuilder = wallet.createTxBuilder();
    const { tx: txMoveFunds } = await txBuilder
      .addOutput(
        txBuilder
          .buildOutput()
          .address(walletAddresses[walletAddresses.length - 1].address)
          .coin(totalCoins - 2_000_000n) // leave some behind for fees
          .toTxOut()
      )
      .build()
      .sign();
    await submitAndConfirm(wallet, txMoveFunds);

    let simplifiedDelegationDistribution: Partial<DelegatedStake>[] = await firstValueFrom(
      wallet.delegation.distribution$.pipe(
        map((delegatedStake) =>
          [...delegatedStake.values()].map(({ pool, percentage }) => ({
            id: pool.id,
            name: pool.metadata?.name,
            percentage
          }))
        )
      )
    );
    expect(simplifiedDelegationDistribution).toEqual(
      rewardAccounts.map((_, index) => ({
        id: poolIds[index].id,
        name: poolIds[index].metadata?.name,
        // Expect approx 100% allocation to the last address
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        percentage: (expect as any).closeTo(index === walletAddresses.length - 1 ? 1 : 0)
      }))
    );

    // Delegate all reward accounts to the same pool. delegationDistribution$ should have 1 entry with 100% distribution
    txBuilder = wallet.createTxBuilder();
    const { tx: txDelegateTo1Pool } = await txBuilder.delegate(poolIds[0].id).build().sign();
    await submitAndConfirm(wallet, txDelegateTo1Pool);
    simplifiedDelegationDistribution = await firstValueFrom(
      wallet.delegation.distribution$.pipe(
        map((distribution) =>
          [...distribution.values()].map((delegatedStake) => ({
            id: delegatedStake.pool.id,
            name: delegatedStake.pool.metadata?.name,
            percentage: delegatedStake.percentage,
            rewardAccounts: delegatedStake.rewardAccounts
          }))
        )
      )
    );
    expect(simplifiedDelegationDistribution).toEqual([
      {
        id: poolIds[0].id,
        name: poolIds[0].metadata?.name,
        percentage: Percent(1),
        rewardAccounts: rewardAccounts.map(({ address }) => address)
      }
    ]);
  });
});
