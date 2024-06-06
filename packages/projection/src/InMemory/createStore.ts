import type { InMemoryStore } from './types.js';

export const createStore = (): InMemoryStore => ({
  stakeKeys: new Set(),
  stakePools: new Map()
});
