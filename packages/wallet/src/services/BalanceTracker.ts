import { BalanceTracker, DelegationTracker, TransactionalObservables } from './types';
import { Cardano, coalesceValueQuantities } from '@cardano-sdk/core';

import { Observable, combineLatest, distinctUntilChanged, map } from 'rxjs';
import { utxoEquals } from './util';

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

const numRewardAccountsWithKeyStatus = (
  delegationTracker: DelegationTracker,
  keyStatuses: Cardano.StakeCredentialStatus[]
) =>
  delegationTracker.rewardAccounts$.pipe(
    map((accounts) => accounts.filter((account) => keyStatuses.includes(account.credentialStatus)).length)
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
      numRewardAccountsWithKeyStatus(delegationTracker, [
        Cardano.StakeCredentialStatus.Registered,
        Cardano.StakeCredentialStatus.Registering
      ])
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

/** Returns utxos filtered by the txOut.addresses or all utxos if addresses are undefined or empty array */
const filterUtxosByAddress = (addresses?: Cardano.PaymentAddress[]) => (utxos$: Observable<Cardano.Utxo[]>) =>
  utxos$.pipe(map((utxos) => utxos.filter(([, txOut]) => !addresses?.length || addresses.includes(txOut.address))));

/** Creates utxo balance aggregated by txOut.address. If addresses are undefined or an empty array, it creates a single balance from all utxos */
export const createUtxoBalanceByAddressTracker = (
  utxoTracker: TransactionalObservables<Cardano.Utxo[]>,
  addresses?: Cardano.PaymentAddress[]
): Pick<BalanceTracker, 'utxo'> => ({
  utxo: {
    available$: utxoTracker.available$.pipe(
      filterUtxosByAddress(addresses),
      distinctUntilChanged(utxoEquals),
      mapUtxoValue
    ),
    total$: utxoTracker.total$.pipe(filterUtxosByAddress(addresses), distinctUntilChanged(utxoEquals), mapUtxoValue),
    unspendable$: utxoTracker.unspendable$.pipe(
      filterUtxosByAddress(addresses),
      distinctUntilChanged(utxoEquals),
      mapUtxoValue
    )
  }
});
