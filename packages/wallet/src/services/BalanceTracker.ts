import { Balance, Delegation, DelegationKeyStatus, TransactionalObservables, TransactionalTracker } from './types';
import { Cardano, ProtocolParametersRequiredByWallet } from '@cardano-sdk/core';
import { Observable, combineLatest, distinctUntilChanged, map, share } from 'rxjs';
import { TrackerSubject } from './util';

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

const numRewardAccountsWithKeyStatus = (delegationTracker: Delegation, keyStatus: DelegationKeyStatus) =>
  delegationTracker.rewardAccounts$.pipe(
    map((accounts) => accounts.filter((account) => account.keyStatus === keyStatus).length)
  );

export const createBalanceTracker = (
  protocolParameters$: Observable<ProtocolParametersRequiredByWallet>,
  utxoTracker: TransactionalObservables<Cardano.Utxo[]>,
  rewardsTracker: TransactionalObservables<Cardano.Lovelace>,
  delegationTracker: Delegation
): TransactionalTracker<Balance> => {
  const depositTotal$ = createDepositTracker(
    protocolParameters$,
    numRewardAccountsWithKeyStatus(delegationTracker, DelegationKeyStatus.Registered)
  ).pipe(share());
  const depositAvailable$ = combineLatest([
    depositTotal$,
    createDepositTracker(
      protocolParameters$,
      numRewardAccountsWithKeyStatus(delegationTracker, DelegationKeyStatus.Unregistering)
    )
  ]).pipe(map(([totalDeposit, depositBeingSpent]) => totalDeposit - depositBeingSpent));
  const available$ = new TrackerSubject<Balance>(
    combineLatest([utxoTracker.available$, rewardsTracker.available$, depositAvailable$]).pipe(mapToBalances)
  );
  const total$ = new TrackerSubject<Balance>(
    combineLatest([utxoTracker.total$, rewardsTracker.total$, depositTotal$]).pipe(mapToBalances)
  );
  return {
    available$,
    shutdown() {
      available$.complete();
      total$.complete();
    },
    total$
  };
};
