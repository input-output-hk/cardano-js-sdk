import { BigIntMath, Cardano, WalletProvider } from '@cardano-sdk/core';
import { KeyManager } from '../KeyManagement';
import { Observable, combineLatest, distinctUntilChanged, map } from 'rxjs';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { TrackerSubject, coldObservableProvider, strictEquals } from './util';
import { TransactionalTracker } from './types';

const getStakeKeyHash = (keyManager: KeyManager): string =>
  Buffer.from(keyManager.stakeKey.hash().to_bytes()).toString('hex');

export const createRewardsProvider = (
  epoch$: Observable<Cardano.Epoch>,
  walletProvider: WalletProvider,
  keyManager: KeyManager,
  retryBackoffConfig: RetryBackoffConfig
) =>
  coldObservableProvider(
    () => walletProvider.utxoDelegationAndRewards([], getStakeKeyHash(keyManager)),
    retryBackoffConfig,
    epoch$
  ).pipe(map(({ delegationAndRewards: { rewards } }) => rewards || 0n));

export interface RewardsTrackerProps {
  walletProvider: WalletProvider;
  keyManager: KeyManager;
  retryBackoffConfig: RetryBackoffConfig;
  transactionsInFlight$: Observable<Cardano.NewTxAlonzo[]>;
  epoch$: Observable<Cardano.Epoch>;
}

export interface RewardsTrackerInternals {
  rewardsProvider$?: Observable<bigint>;
  rewardsSource$?: TrackerSubject<Cardano.Lovelace>;
}

const getWithdrawalQuantity = ({ body: { withdrawals } }: Cardano.NewTxAlonzo): Cardano.Lovelace =>
  BigIntMath.sum(withdrawals?.map(({ quantity }) => quantity) || []);

export const createRewardsTracker = (
  { walletProvider, keyManager, retryBackoffConfig, transactionsInFlight$, epoch$ }: RewardsTrackerProps,
  {
    rewardsSource$ = new TrackerSubject(createRewardsProvider(epoch$, walletProvider, keyManager, retryBackoffConfig))
  }: RewardsTrackerInternals = {}
): TransactionalTracker<Cardano.Lovelace> => {
  const available$ = new TrackerSubject<Cardano.Lovelace>(
    combineLatest([rewardsSource$, transactionsInFlight$]).pipe(
      // filter to rewards that are not included in in-flight transactions
      map(
        ([rewards, transactionsInFlight]) =>
          rewards - transactionsInFlight.reduce((total, tx) => total + getWithdrawalQuantity(tx), 0n)
      ),
      distinctUntilChanged(strictEquals) // TODO: test this
    )
  );
  return {
    available$,
    shutdown: () => {
      rewardsSource$.complete();
      available$.complete();
    },
    total$: rewardsSource$
  };
};
