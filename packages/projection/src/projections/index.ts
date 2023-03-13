import { stakeKeys } from './stakeKeys';
import { stakePoolMetadata, stakePoolMetrics, stakePools } from './stakePools';

export * from './stakeKeys';
export * from './stakePools';
export * from './utils';
export * from './types';

export const allProjections = {
  stakeKeys,
  stakePoolMetadata,
  stakePoolMetrics,
  stakePools
};

export type AllProjections = typeof allProjections;
