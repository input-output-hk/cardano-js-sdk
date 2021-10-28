import { CSL, Cardano, WalletProvider, cslUtil } from '@cardano-sdk/core';
import { KeyManager } from '../KeyManagement';
import { NewTx, SimpleProvider, SourceTransactionalTracker } from '../prototype/types';
import { Observable, combineLatest, from, map } from 'rxjs';
import { ProviderTrackerSubject, SourceTrackerConfig } from './util';
import { TrackerSubject } from './util/TrackerSubject';

export interface RewardsTrackerProps {
  rewardsProvider: SimpleProvider<Cardano.Lovelace>;
  transactionsInFlight$: Observable<NewTx[]>;
  keyManager: KeyManager;
  config: SourceTrackerConfig;
}

export interface RewardsTrackerInternals {
  rewardsSource$?: ProviderTrackerSubject<Cardano.Lovelace>;
}

const getStakeKeyHash = (keyManager: KeyManager): string =>
  Buffer.from(keyManager.stakeKey.hash().to_bytes()).toString('hex');

export const createRewardsProvider$ =
  (
    walletProvider: WalletProvider,
    addresses: Cardano.Address[],
    keyManager: KeyManager
  ): (() => Observable<Cardano.Lovelace>) =>
  () =>
    from(
      walletProvider
        .utxoDelegationAndRewards(addresses, getStakeKeyHash(keyManager))
        .then(({ delegationAndRewards: { rewards } }) => rewards || 0n)
    );

const getWithdrawalQuantity = (tx: NewTx, keyManager: KeyManager): Cardano.Lovelace => {
  const withdrawals = tx.body().withdrawals();
  if (!withdrawals) return 0n;
  const ownStakeCredential = CSL.StakeCredential.from_keyhash(keyManager.stakeKey.hash());
  const withdrawalKeys = withdrawals.keys();
  let withdrawalTotal = 0n;
  for (let withdrawalKeyIdx = 0; withdrawalKeyIdx < withdrawalKeys.len(); withdrawalKeyIdx++) {
    const rewardAddress = withdrawalKeys.get(withdrawalKeyIdx);
    if (cslUtil.bytewiseEquals(rewardAddress.payment_cred(), ownStakeCredential)) {
      withdrawalTotal += BigInt(withdrawals.get(rewardAddress)!.to_str());
    }
  }
  return withdrawalTotal;
};

export const createRewardsTracker = (
  { rewardsProvider, transactionsInFlight$, keyManager, config }: RewardsTrackerProps,
  { rewardsSource$ = new ProviderTrackerSubject({ config, provider: rewardsProvider }) }: RewardsTrackerInternals = {}
): SourceTransactionalTracker<Cardano.Lovelace> => {
  const available$ = new TrackerSubject<Cardano.Lovelace>(
    combineLatest([rewardsSource$, transactionsInFlight$]).pipe(
      // filter to rewards that are not included in in-flight transactions
      map(
        ([rewards, transactionsInFlight]) =>
          rewards - transactionsInFlight.reduce((total, tx) => total + getWithdrawalQuantity(tx, keyManager), 0n)
      )
    )
  );
  return {
    available$,
    shutdown: () => {
      rewardsSource$.complete();
      available$.complete();
    },

    sync: () => rewardsSource$.sync(),
    total$: rewardsSource$
  };
};
