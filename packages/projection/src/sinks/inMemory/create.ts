import { AllProjections } from '../../projections';
import { InMemoryStabilityWindowBuffer } from './InMemoryStabilityWindowBuffer';
import { InMemoryStore } from './types';
import { Sinks, SinksFactory } from '../types';
import { stakeKeys } from './stakeKeys';
import { stakePools } from './stakePools';
import { withStaticContext } from '../../operators';

export const createStore = (): InMemoryStore => ({
  stakeKeys: new Set(),
  stakePools: new Map()
});

type SupportedProjections = Pick<AllProjections, 'stakeKeys' | 'stakePools'>;

export const createSinks = (store: InMemoryStore): Sinks<SupportedProjections> => ({
  before: withStaticContext({ store }),
  buffer: new InMemoryStabilityWindowBuffer(),
  projectionSinks: {
    stakeKeys,
    stakePools
  }
});

export const createSinksFactory =
  (store: InMemoryStore): SinksFactory<SupportedProjections> =>
  () =>
    createSinks(store);

export type InMemorySinks = ReturnType<typeof createSinks>;
