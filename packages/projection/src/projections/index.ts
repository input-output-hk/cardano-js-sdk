import { stakeKeys } from './stakeKeys';
import { stakePools } from './stakePools';

export * from './stakeKeys';
export * from './stakePools';
export * from './utils';
export * from './types';

export const allProjections = {
  stakeKeys,
  stakePools
};

export type AllProjections = typeof allProjections;
