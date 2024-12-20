import { Logger } from 'ts-log';
import { NetworkInfoProvider } from '@cardano-sdk/core';
import { Observable } from 'rxjs';
import { PersistentDocumentTrackerSubject, pollProvider } from './util';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { SupplyDistributionStores } from '../persistence';
import isEqual from 'lodash/isEqual.js';

export type SupplyDistributionNetworkInfoProvider = Pick<NetworkInfoProvider, 'stake' | 'lovelaceSupply'>;

export interface SupplyDistributionTrackerProps {
  /** SupplyDistribution re-fetch trigger. */
  trigger$: Observable<unknown>;
  /** Failed request retry strategy */
  retryBackoffConfig?: RetryBackoffConfig;
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
  { trigger$, retryBackoffConfig = { initialInterval: 1000, maxInterval: 60_000 } }: SupplyDistributionTrackerProps,
  { logger, stores, networkInfoProvider }: SupplyDistributionTrackerDependencies
) => {
  const stake$ = new PersistentDocumentTrackerSubject(
    pollProvider({
      equals: isEqual,
      logger,
      retryBackoffConfig,
      sample: networkInfoProvider.stake,
      trigger$
    }),
    stores.stake
  );

  const lovelaceSupply$ = new PersistentDocumentTrackerSubject(
    pollProvider({
      equals: isEqual,
      logger,
      retryBackoffConfig,
      sample: networkInfoProvider.lovelaceSupply,
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
