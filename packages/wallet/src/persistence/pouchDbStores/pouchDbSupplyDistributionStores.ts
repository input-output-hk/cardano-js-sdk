import { EMPTY, map } from 'rxjs';
import { PouchDbDocumentStore } from './PouchDbDocumentStore.js';
import type { CreatePouchDbStoresDependencies } from './types.js';
import type { StakeSummary, SupplySummary } from '@cardano-sdk/core';
import type { SupplyDistributionStores } from '../types.js';

export class PouchDbStakeSummaryStore extends PouchDbDocumentStore<StakeSummary> {}
export class PouchDbSupplySummaryStore extends PouchDbDocumentStore<SupplySummary> {}

/**
 * @param {string} baseName used to derive underlying db names, like a network ID and/or wallet name
 */
export const createPouchDbSupplyDistributionStores = (
  baseName: string,
  { logger }: CreatePouchDbStoresDependencies
): SupplyDistributionStores => {
  const baseDbName = baseName.replace(/[^\da-z]/gi, '');
  const docsDbName = `${baseDbName}SupplyDistribution`;
  return {
    destroy() {
      if (!this.destroyed) {
        this.destroyed = true;
        logger.debug('Destroying PouchDb SupplyDistributionStores...');
        // since the database of document stores is shared, destroying any document store destroys all of them
        return this.lovelaceSupply.destroy().pipe(map(() => void 0));
      }
      return EMPTY;
    },
    destroyed: false,
    lovelaceSupply: new PouchDbSupplySummaryStore(docsDbName, 'lovelaceSupply', logger),
    stake: new PouchDbStakeSummaryStore(docsDbName, 'stake', logger)
  };
};
