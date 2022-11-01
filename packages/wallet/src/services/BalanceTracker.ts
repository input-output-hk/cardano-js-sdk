import { BalanceTracker, DelegationTracker, StakeKeyStatus, TransactionalObservables } from './types';
import { Cardano, coalesceValueQuantities } from '@cardano-sdk/core';

import { Observable, combineLatest, distinctUntilChanged, map } from 'rxjs';

const mapUtxoValue = map<Cardano.Utxo[], Cardano.Value>((utxo) =>
  coalesceValueQuantities(utxo.map(([_, txOut]) => txOut.value))
);

const computeDepositCoin = (
  protocolParameters$: Observable<Cardano.ProtocolParameters>,
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
  protocolParameters$: Observable<Cardano.ProtocolParameters>,
  utxoTracker: TransactionalObservables<Cardano.Utxo[]>,
  delegationTracker: DelegationTracker
): BalanceTracker => ({
  rewardAccounts: {
    // 'Unregistering' balance will be reflected in utxo
    deposit$: computeDepositCoin(
      protocolParameters$,
      numRewardAccountsWithKeyStatus(delegationTracker, [StakeKeyStatus.Registered, StakeKeyStatus.Registering])
    ),
    rewards$: delegationTracker.rewardAccounts$.pipe(
      map((accounts) => accounts.reduce((sum, { rewardBalance }) => sum + rewardBalance, 0n)),
      distinctUntilChanged()
    )
  },
  utxo: {
    available$: utxoTracker.available$.pipe(mapUtxoValue),
    total$: utxoTracker.total$.pipe(mapUtxoValue),
    unspendable$: utxoTracker.unspendable$.pipe(mapUtxoValue)
  }
});
