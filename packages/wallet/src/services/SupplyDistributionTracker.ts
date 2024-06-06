import { PersistentDocumentTrackerSubject } from './util/index.js';
import { coldObservableProvider } from '@cardano-sdk/util-rxjs';
import isEqual from 'lodash/isEqual.js';
import type { Logger } from 'ts-log';
import type { NetworkInfoProvider } from '@cardano-sdk/core';
import type { Observable } from 'rxjs';
import type { RetryBackoffConfig } from 'backoff-rxjs';
import type { SupplyDistributionStores } from '../persistence/index.js';

export type SupplyDistributionNetworkInfoProvider = Pick<NetworkInfoProvider, 'stake' | 'lovelaceSupply'>;

export interface SupplyDistributionTrackerProps {
  /** SupplyDistribution re-fetch trigger. */
  trigger$: Observable<unknown>;
  /** Failed request retry strategy */
  retryBackoffConfig?: RetryBackoffConfig;
  onFatalError?: (value: unknown) => void;
}

export interface SupplyDistributionTrackerDependencies {
  logger: Logger;
  stores: SupplyDistributionStores;
  /** Compatible with NetworkInfoProvider. */
  networkInfoProvider: SupplyDistributionNetworkInfoProvider;
}

/**
 * @returns object that continuously fetches and emits network stats (StakeSummary and SupplySummary)
 */
export const createSupplyDistributionTracker = (
  {
    trigger$,
    retryBackoffConfig = { initialInterval: 1000, maxInterval: 60_000 },
    onFatalError
  }: SupplyDistributionTrackerProps,
  { logger, stores, networkInfoProvider }: SupplyDistributionTrackerDependencies
) => {
  const stake$ = new PersistentDocumentTrackerSubject(
    coldObservableProvider({
      equals: isEqual,
      onFatalError,
      provider: networkInfoProvider.stake,
      retryBackoffConfig,
      trigger$
    }),
    stores.stake
  );

  const lovelaceSupply$ = new PersistentDocumentTrackerSubject(
    coldObservableProvider({
      equals: isEqual,
      onFatalError,
      provider: networkInfoProvider.lovelaceSupply,
      retryBackoffConfig,
      trigger$
    }),
    stores.lovelaceSupply
  );

  return {
    lovelaceSupply$,
    shutdown() {
      logger.debug('Shutting down SupplyDistributionTracker');
      stake$.complete();
      lovelaceSupply$.complete();
    },
    stake$
  };
};

export type SupplyDistributionTracker = ReturnType<typeof createSupplyDistributionTracker>;
