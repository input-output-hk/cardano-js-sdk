import { InMemoryStore } from './types';

export const createStore = (): InMemoryStore => ({
  stakeKeys: new Set(),
  stakePools: new Map()
});
