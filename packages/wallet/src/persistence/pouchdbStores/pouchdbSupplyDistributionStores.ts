import { CreatePouchdbStoresDependencies } from './types';
import { EMPTY, map } from 'rxjs';
import { PouchdbDocumentStore } from './PouchdbDocumentStore';
import { StakeSummary, SupplySummary } from '@cardano-sdk/core';
import { SupplyDistributionStores } from '../types';

export class PouchdbStakeSummaryStore extends PouchdbDocumentStore<StakeSummary> {}
export class PouchdbSupplySummaryStore extends PouchdbDocumentStore<SupplySummary> {}

/**
 * @param {string} baseName used to derive underlying db names, like a network ID and/or wallet name
 */
export const createPouchdbSupplyDistributionStores = (
  baseName: string,
  { logger }: CreatePouchdbStoresDependencies
): SupplyDistributionStores => {
  const baseDbName = baseName.replace(/[^\da-z]/gi, '');
  const docsDbName = `${baseDbName}SupplyDistribution`;
  return {
    destroy() {
      if (!this.destroyed) {
        this.destroyed = true;
        logger.debug('Destroying pouchdb SupplyDistributionStores...');
        // since the database of document stores is shared, destroying any document store destroys all of them
        return this.lovelaceSupply.destroy().pipe(map(() => void 0));
      }
      return EMPTY;
    },
    destroyed: false,
    lovelaceSupply: new PouchdbSupplySummaryStore(docsDbName, 'lovelaceSupply', logger),
    stake: new PouchdbStakeSummaryStore(docsDbName, 'stake', logger)
  };
};
