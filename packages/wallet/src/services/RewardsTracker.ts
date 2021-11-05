import { BigIntMath, Cardano, WalletProvider } from '@cardano-sdk/core';
import { KeyManager } from '../KeyManagement';
import { Observable, combineLatest, from, map } from 'rxjs';
import { ProviderTrackerSubject, SourceTrackerConfig, TrackerSubject, strictEquals } from './util';
import { SimpleProvider, SourceTransactionalTracker } from './types';

export interface RewardsTrackerProps {
  rewardsProvider: SimpleProvider<Cardano.Lovelace>;
  transactionsInFlight$: Observable<Cardano.NewTxAlonzo[]>;
  config: SourceTrackerConfig;
}

export interface RewardsTrackerInternals {
  rewardsSource$?: ProviderTrackerSubject<Cardano.Lovelace>;
}

const getStakeKeyHash = (keyManager: KeyManager): string =>
  Buffer.from(keyManager.stakeKey.hash().to_bytes()).toString('hex');

export const createRewardsProvider =
  (walletProvider: WalletProvider, keyManager: KeyManager): (() => Observable<Cardano.Lovelace>) =>
  () =>
    from(
      walletProvider
        .utxoDelegationAndRewards([], getStakeKeyHash(keyManager))
        .then(({ delegationAndRewards: { rewards } }) => rewards || 0n)
    );

const getWithdrawalQuantity = ({ body: { withdrawals } }: Cardano.NewTxAlonzo): Cardano.Lovelace =>
  BigIntMath.sum(withdrawals?.map(({ quantity }) => quantity) || []);

export const createRewardsTracker = (
  { rewardsProvider, transactionsInFlight$, config }: RewardsTrackerProps,
  {
    rewardsSource$ = new ProviderTrackerSubject({ config, equals: strictEquals, provider: rewardsProvider })
  }: RewardsTrackerInternals = {}
): SourceTransactionalTracker<Cardano.Lovelace> => {
  const available$ = new TrackerSubject<Cardano.Lovelace>(
    combineLatest([rewardsSource$, transactionsInFlight$]).pipe(
      // filter to rewards that are not included in in-flight transactions
      map(
        ([rewards, transactionsInFlight]) =>
          rewards - transactionsInFlight.reduce((total, tx) => total + getWithdrawalQuantity(tx), 0n)
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
