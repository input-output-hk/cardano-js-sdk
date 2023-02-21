import { AllProjections } from '../../projections';
import { InMemoryStabilityWindowBuffer } from './InMemoryStabilityWindowBuffer';
import { InMemoryStore } from './types';
import { Sinks } from '../types';
import { stakeKeys } from './stakeKeys';
import { stakePools } from './stakePools';
import { withStaticContext } from '../../operators';

export const createInMemoryStore = (): InMemoryStore => ({
  stakeKeys: new Set(),
  stakePools: new Map()
});

export const createInMemorySinks = (store: InMemoryStore): Sinks<AllProjections> => ({
  before: withStaticContext({ store }),
  buffer: new InMemoryStabilityWindowBuffer(),
  projectionSinks: {
    stakeKeys,
    stakePools
  }
});

export type InMemorySinks = ReturnType<typeof createInMemorySinks>;
