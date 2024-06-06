import { BigIntMath, Percent, calcPercentages, sameArrayItems } from '@cardano-sdk/util';
import { Cardano } from '@cardano-sdk/core';
import { combineLatest, combineLatestWith, distinctUntilChanged, iif, map, of, switchMap, withLatestFrom } from 'rxjs';
import { createUtxoBalanceByAddressTracker } from '../BalanceTracker.js';
import { delegatedStakeEquals } from '../util/index.js';
import _groupBy from 'lodash/groupBy.js';
import _map from 'lodash/map.js';
import type { DelegatedStake } from '../types.js';
import type { DelegationTrackerProps } from './DelegationTracker.js';
import type { Observable } from 'rxjs';

type DelegationDistributionTrackerProps = Pick<DelegationTrackerProps, 'knownAddresses$' | 'utxoTracker'> & {
  rewardAccounts$: Observable<Cardano.RewardAccountInfo[]>;
};

export const createDelegationDistributionTracker = ({
  rewardAccounts$,
  knownAddresses$,
  utxoTracker
}: DelegationDistributionTrackerProps): Observable<Map<Cardano.PoolId, DelegatedStake>> => {
  const balanceAllUtxosTracker = createUtxoBalanceByAddressTracker(utxoTracker);

  const delegatedAccounts$ = rewardAccounts$.pipe(
    map((rewardsAccounts) =>
      rewardsAccounts.filter(
        (account) =>
          account.credentialStatus === Cardano.StakeCredentialStatus.Registered && account.delegatee?.nextNextEpoch
      )
    )
  );

  const hydratedDelegatedAccounts$ = delegatedAccounts$.pipe(
    withLatestFrom(knownAddresses$),
    map(([delegatedAccounts, knownAddresses]) =>
      delegatedAccounts.map((delegatedAccount) => {
        const groupedAddresses = knownAddresses.filter(
          (knownAddr) => knownAddr.rewardAccount === delegatedAccount.address
        );
        return {
          balance: createUtxoBalanceByAddressTracker(
            utxoTracker,
            groupedAddresses.map(({ address }) => address)
          ),
          delegatedAccount,
          groupedAddresses
        };
      })
    )
  );

  return hydratedDelegatedAccounts$.pipe(
    switchMap((accts) =>
      iif(
        () => accts.length === 0,
        of([]),
        combineLatest(
          accts.map((acct) =>
            acct.balance.utxo.total$.pipe(
              map(
                (perAccountTotal): DelegatedStake => ({
                  // Percentage will be calculated in the next step
                  percentage: Percent(0),
                  pool: acct.delegatedAccount.delegatee!.nextNextEpoch!,
                  rewardAccounts: [acct.delegatedAccount.address],
                  stake: perAccountTotal.coins + acct.delegatedAccount.rewardBalance
                })
              )
            )
          )
        )
      )
    ),
    // Merge rewardAccounts delegating to the same pool
    map((delegatedStakes) =>
      _map(
        _groupBy(delegatedStakes, ({ pool: { id } }) => id),
        (pools): DelegatedStake =>
          pools.reduce((mergedPool, pool) => ({
            ...pool,
            rewardAccounts: [...new Set([...mergedPool.rewardAccounts, ...pool.rewardAccounts])],
            stake: pool.stake + mergedPool.stake || 0n
          }))
      )
    ),
    // calculate percentages
    combineLatestWith(
      balanceAllUtxosTracker.utxo.total$,
      rewardAccounts$.pipe(map((accts) => BigIntMath.sum(accts.map(({ rewardBalance }) => rewardBalance))))
    ),
    map(([delegatedStakes, utxoBalance, totalRewards]) => {
      const totalBalance = utxoBalance.coins + totalRewards;
      const percentages = calcPercentages(
        delegatedStakes.map(({ stake: value }) => Number(value)),
        Number(totalBalance)
      );
      return delegatedStakes.map((pool, idx) => ({ ...pool, percentage: percentages[idx] }));
    }),
    distinctUntilChanged((a, b) => sameArrayItems(a, b, delegatedStakeEquals)),
    map((delegatedStakes) => new Map(delegatedStakes.map((delegation) => [delegation.pool.id, delegation])))
  );
};
