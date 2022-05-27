import { Balance, DelegationTracker, StakeKeyStatus, TransactionalObservables, TransactionalTracker } from './types';
import { BigIntMath } from '@cardano-sdk/util';
import { Cardano, ProtocolParametersRequiredByWallet } from '@cardano-sdk/core';

import { Observable, combineLatest, distinctUntilChanged, map } from 'rxjs';
import { TrackerSubject } from '@cardano-sdk/util-rxjs';
import { deepEquals } from './util';

const mapToBalances = map<[Cardano.Utxo[], Cardano.Lovelace, Cardano.Lovelace], Balance>(
  ([utxo, rewards, deposit]) => ({
    ...Cardano.util.coalesceValueQuantities(utxo.map(([_, txOut]) => txOut.value)),
    deposit,
    rewards
  })
);

const createDepositTracker = (
  protocolParameters$: Observable<ProtocolParametersRequiredByWallet>,
  numDeposits$: Observable<number>
) =>
  combineLatest([numDeposits$, protocolParameters$]).pipe(
    map(([registeredAccounts, { stakeKeyDeposit }]) => BigInt(registeredAccounts * stakeKeyDeposit)),
    distinctUntilChanged()
  );

const numRewardAccountsWithKeyStatus = (delegationTracker: DelegationTracker, keyStatuses: StakeKeyStatus[]) =>
  delegationTracker.rewardAccounts$.pipe(
    map((accounts) => accounts.filter((account) => keyStatuses.includes(account.keyStatus)).length)
  );

export const createBalanceTracker = (
  protocolParameters$: Observable<ProtocolParametersRequiredByWallet>,
  utxoTracker: TransactionalObservables<Cardano.Utxo[]>,
  delegationTracker: DelegationTracker
): TransactionalTracker<Balance> => {
  const depositTotal$ = createDepositTracker(
    protocolParameters$,
    numRewardAccountsWithKeyStatus(delegationTracker, [StakeKeyStatus.Registered, StakeKeyStatus.Unregistering])
  ).pipe(distinctUntilChanged());
  const depositRegistered$ = createDepositTracker(
    protocolParameters$,
    numRewardAccountsWithKeyStatus(delegationTracker, [StakeKeyStatus.Registered])
  );
  const depositUnregistering$ = createDepositTracker(
    protocolParameters$,
    numRewardAccountsWithKeyStatus(delegationTracker, [StakeKeyStatus.Unregistering])
  );
  const depositAvailable$ = combineLatest([depositRegistered$, depositUnregistering$]).pipe(
    map(([totalDeposit, depositBeingSpent]) => BigIntMath.max([totalDeposit - depositBeingSpent, 0n])!),
    distinctUntilChanged()
  );
  const rewardsAggregate$ = delegationTracker.rewardAccounts$.pipe(
    map((accounts) =>
      accounts.reduce(
        (sum, { rewardBalance: { available, total } }) => ({
          available: sum.available + available,
          total: sum.total + total
        }),
        {
          available: 0n,
          total: 0n
        }
      )
    ),
    distinctUntilChanged(deepEquals)
  );
  const available$ = new TrackerSubject<Balance>(
    combineLatest([
      utxoTracker.available$,
      rewardsAggregate$.pipe(map(({ available }) => available)),
      depositAvailable$
    ]).pipe(mapToBalances)
  );
  const total$ = new TrackerSubject<Balance>(
    combineLatest([utxoTracker.total$, rewardsAggregate$.pipe(map(({ total }) => total)), depositTotal$]).pipe(
      mapToBalances
    )
  );

  const unspendable$ = new TrackerSubject<Balance>(
    utxoTracker.unspendable$.pipe(
      map((utxo) => ({
        ...Cardano.util.coalesceValueQuantities(utxo.map(([_, txOut]) => txOut.value)),
        deposit: 0n,
        rewards: 0n
      }))
    )
  );

  return {
    available$,
    shutdown() {
      available$.complete();
      total$.complete();
    },
    total$,
    unspendable$
  };
};
