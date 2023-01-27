import { AllProjections } from '../../projections';
import { InMemoryStabilityWindowBuffer } from './InMemoryStabilityWindowBuffer';
import { InMemoryStore } from './types';
import { Sinks } from '../types';
import { WithNetworkInfo, withStaticContext } from '../../operators';
import { stakeKeys } from './stakeKeys';
import { stakePools } from './stakePools';

export const createInMemorySinks = (
  networkInfo: Pick<WithNetworkInfo, 'genesisParameters'>,
  store: InMemoryStore
): Sinks<AllProjections> => ({
  before: withStaticContext({ store }),
  buffer: new InMemoryStabilityWindowBuffer(networkInfo),
  projectionSinks: {
    stakeKeys,
    stakePools
  }
});

export type InMemorySinks = ReturnType<typeof createInMemorySinks>;
