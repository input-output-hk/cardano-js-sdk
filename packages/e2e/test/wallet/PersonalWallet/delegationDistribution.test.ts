import { Cardano } from '@cardano-sdk/core';
import { DelegatedStake, PersonalWallet, createUtxoBalanceByAddressTracker } from '@cardano-sdk/wallet';
import { MINUTE, firstValueFromTimed, getWallet, submitAndConfirm, walletReady } from '../../../src';
import { Observable, filter, firstValueFrom, map, tap } from 'rxjs';
import { Percent } from '@cardano-sdk/util';
import { createLogger } from '@cardano-sdk/util-dev';
import { getEnv, walletVariables } from '../../../src/environment';

const env = getEnv(walletVariables);
const logger = createLogger();
const TEST_FUNDS = 1_000_000_000n;
const POOLS_COUNT = 5;
const distributionMessage = 'ObservableWallet.delegation.distribution$:';

/** Distribute the wallet funds evenly across all its addresses */
const fundWallet = async (wallet: PersonalWallet) => {
  await walletReady(wallet, 0n);
  const addresses = await firstValueFrom(wallet.addresses$);

  // Check that we have enough funds. Otherwise, fund it from wallet account at index 0
  let { coins: totalCoins } = await firstValueFrom(wallet.balance.utxo.available$);

  const coinDeficit = TEST_FUNDS - totalCoins;
  if (coinDeficit > 10_000_000n) {
    logger.info(
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
};

/** await for rewardAccounts$ to be registered, unregistered, as defined in states   */
const rewardAccountStatuses = async (
  rewardAccounts$: Observable<Cardano.RewardAccountInfo[]>,
  statuses: Cardano.StakeKeyStatus[],
  timeout = MINUTE
) =>
  firstValueFromTimed(
    rewardAccounts$.pipe(
      tap((accts) => accts.map(({ address, keyStatus }) => logger.debug(address, keyStatus))),
      map((accts) => accts.map(({ keyStatus }) => keyStatus)),
      filter((statusArr) => statusArr.every((s) => statuses.includes(s)))
    ),
    `Timeout waiting for all reward accounts stake keys to be one of ${statuses.join('|')}`,
    timeout
  );

/** Create stakeKey deregistration transaction for all reward accounts */
const deregisterAllStakeKeys = async (wallet: PersonalWallet): Promise<void> => {
  await walletReady(wallet, 0n);
  try {
    await rewardAccountStatuses(
      wallet.delegation.rewardAccounts$,
      [Cardano.StakeKeyStatus.Unregistered, Cardano.StakeKeyStatus.Unregistering],
      0
    );
    logger.info('Stake keys are already deregistered');
  } catch {
    // Some stake keys are registered. Deregister them
    const txBuilder = wallet.createTxBuilder();
    txBuilder.delegatePortfolio(null);
    const { tx: deregTx } = await txBuilder.build().sign();
    await submitAndConfirm(wallet, deregTx);

    await rewardAccountStatuses(wallet.delegation.rewardAccounts$, [
      Cardano.StakeKeyStatus.Unregistered,
      Cardano.StakeKeyStatus.Unregistering
    ]);
    logger.info('Deregistered all stake keys');
  }
};

const getPoolIds = async (wallet: PersonalWallet): Promise<Cardano.StakePool[]> => {
  const activePools = await wallet.stakePoolProvider.queryStakePools({
    filters: { status: [Cardano.StakePoolStatus.Active] },
    pagination: { limit: POOLS_COUNT, startAt: 0 }
  });
  expect(activePools.pageResults.length).toBeGreaterThanOrEqual(POOLS_COUNT);
  return Array.from({ length: POOLS_COUNT }).map((_, index) => activePools.pageResults[index]);
};

/** Delegate to unique POOLS_COUNT pools. Use even distribution as default. */
const delegateToMultiplePools = async (
  wallet: PersonalWallet,
  weights = Array.from({ length: POOLS_COUNT }).map(() => 1)
) => {
  const poolIds = await getPoolIds(wallet);
  const portfolio: Pick<Cardano.Cip17DelegationPortfolio, 'pools'> = {
    pools: poolIds.map(({ hexId: id }, idx) => ({ id, weight: weights[idx] }))
  };
  logger.debug('Delegating portfolio', portfolio);

  const { tx } = await wallet.createTxBuilder().delegatePortfolio(portfolio).build().sign();
  await submitAndConfirm(wallet, tx);
  return poolIds;
};

const delegateAllToSinglePool = async (wallet: PersonalWallet): Promise<void> => {
  // This is a negative testcase, simulating an HD wallet that has multiple stake keys delegated
  // to the same stake pool. txBuilder.delegatePortfolio does not support this scenario.
  const [{ id: poolId }] = await getPoolIds(wallet);
  const txBuilder = wallet.createTxBuilder();
  const rewardAccounts = await firstValueFrom(wallet.delegation.rewardAccounts$);
  txBuilder.partialTxBody.certificates = rewardAccounts.map(({ address }) =>
    Cardano.createDelegationCert(address, poolId)
  );

  logger.debug(`Delegating all stake keys to pool ${poolId}`);
  const { tx } = await txBuilder.build().sign();
  await submitAndConfirm(wallet, tx);
};

describe('PersonalWallet/delegationDistribution', () => {
  let wallet: PersonalWallet;

  beforeAll(async () => {
    wallet = (await getWallet({ env, idx: 3, logger, name: 'Wallet', polling: { interval: 50 } })).wallet;
    await fundWallet(wallet);
    await deregisterAllStakeKeys(wallet);
  });

  afterAll(() => {
    wallet.shutdown();
  });

  it('reports observable wallet multi delegation as delegationDistribution by pool', async () => {
    await walletReady(wallet);

    // No stake distribution initially
    const delegationDistribution = await firstValueFrom(wallet.delegation.distribution$);
    logger.info('Empty delegation distribution initially');
    expect(delegationDistribution).toEqual(new Map());

    const poolIds = await delegateToMultiplePools(wallet);
    const walletAddresses = await firstValueFromTimed(wallet.addresses$);
    const rewardAccounts = await firstValueFrom(wallet.delegation.rewardAccounts$);

    expect(rewardAccounts.length).toBe(POOLS_COUNT);

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

    logger.info('Funds were distributed evenly across the addresses.');
    logger.info(distributionMessage, actualDelegationDistribution);

    expect([...actualDelegationDistribution.values()]).toEqual(expectedDelegationDistribution);

    // Delegate so that last address has all funds
    await delegateToMultiplePools(
      wallet,
      Array.from({ length: POOLS_COUNT }).map((_, idx) => (POOLS_COUNT === idx + 1 ? 1 : 0))
    );

    let simplifiedDelegationDistribution: Partial<DelegatedStake>[] = await firstValueFrom(
      wallet.delegation.distribution$.pipe(
        tap((delegatedStake) => {
          logger.info('All funds were moved to', walletAddresses[walletAddresses.length - 1].address);
          logger.info(distributionMessage, delegatedStake);
        }),
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
    await delegateAllToSinglePool(wallet);
    simplifiedDelegationDistribution = await firstValueFrom(
      wallet.delegation.distribution$.pipe(
        tap((distribution) => {
          logger.info('All stake keys are delegated to poolId:', poolIds[0].id);
          logger.info(distributionMessage, distribution);
        }),
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
