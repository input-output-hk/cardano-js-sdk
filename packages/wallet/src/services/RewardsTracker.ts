import { BigIntMath, Cardano, WalletProvider } from '@cardano-sdk/core';
import { KeyManager } from '../KeyManagement';
import { Observable, combineLatest, from, map } from 'rxjs';
import { ProviderTrackerSubject, SourceTrackerConfig, TrackerSubject } from './util';
import { SimpleProvider, SourceTransactionalTracker } from './types';

export interface RewardsTrackerProps {
  rewardsProvider: SimpleProvider<Cardano.Lovelace>;
  transactionsInFlight$: Observable<Cardano.NewTxAlonzo[]>;
  addresses: Cardano.Address[];
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

const getWithdrawalQuantity = (tx: Cardano.NewTxAlonzo, addresses: string[]): Cardano.Lovelace => {
  const { withdrawals } = tx.body;
  if (!withdrawals) return 0n;
  // Review: this to_bech32() doesn't take in prefix as argument.
  // I didn't check, but if I had to guess it's "addr" and not "stake", so this is likely a bug.
  // Should we be decoding it and comparing the key hash?
  // I feel like we're likely to be having bugs due to
  // using string for different types of hashes and addresses.
  // Maybe we should wrap those strings in object types in order to be more explicit?
  return BigIntMath.sum(
    withdrawals.filter(({ address }) => addresses.includes(address)).map(({ quantity }) => quantity)
  );
};

export const createRewardsTracker = (
  { rewardsProvider, transactionsInFlight$, addresses, config }: RewardsTrackerProps,
  { rewardsSource$ = new ProviderTrackerSubject({ config, provider: rewardsProvider }) }: RewardsTrackerInternals = {}
): SourceTransactionalTracker<Cardano.Lovelace> => {
  const available$ = new TrackerSubject<Cardano.Lovelace>(
    combineLatest([rewardsSource$, transactionsInFlight$]).pipe(
      // filter to rewards that are not included in in-flight transactions
      map(
        ([rewards, transactionsInFlight]) =>
          rewards - transactionsInFlight.reduce((total, tx) => total + getWithdrawalQuantity(tx, addresses), 0n)
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
