import { EMPTY, combineLatest, map } from 'rxjs';
import { InMemoryDocumentStore } from './InMemoryDocumentStore.js';
import type { StakeSummary, SupplySummary } from '@cardano-sdk/core';
import type { SupplyDistributionStores } from '../types.js';

export class InMemoryStakeSummaryStore extends InMemoryDocumentStore<StakeSummary> {}
export class InMemorySupplySummaryStore extends InMemoryDocumentStore<SupplySummary> {}

export const createInMemorySupplyDistributionStores = (): SupplyDistributionStores => ({
  destroy() {
    if (!this.destroyed) {
      this.destroyed = true;
      return combineLatest([this.stake.destroy(), this.lovelaceSupply.destroy()]).pipe(map(() => void 0));
    }
    return EMPTY;
  },
  destroyed: false,
  lovelaceSupply: new InMemorySupplySummaryStore(),
  stake: new InMemoryStakeSummaryStore()
});
