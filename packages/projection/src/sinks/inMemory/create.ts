import { AllProjections } from '../../projections';
import { InMemoryStabilityWindowBuffer } from './InMemoryStabilityWindowBuffer';
import { InMemoryStore, WithInMemoryStore } from './types';
import { Sink } from '../types';
import { applySinksSerially } from '../util';
import { map } from 'rxjs';
import { passthrough } from '@cardano-sdk/util-rxjs';
import { stakeKeys } from './stakeKeys';
import { stakePools } from './stakePools';
import { withStaticContext } from '../../operators';

export const createStore = (): InMemoryStore => ({
  stakeKeys: new Set(),
  stakePools: new Map()
});

const supportedProjections = { stakeKeys, stakePools };
type SupportedProjectionId = keyof typeof supportedProjections;
export type SupportedProjections = { [k in SupportedProjectionId]: AllProjections[k] };

const allSinks = Object.entries(supportedProjections).map(([id, sink]) => ({ id: id as SupportedProjectionId, sink }));

/**
 * @param store in-memory data store
 * @param buffer takes ownership of the buffer: calls handleEvents() to write blocks,
   Does **not** shutdown the buffer when unsubscribed.
 */
export const createSink =
  (store: InMemoryStore, buffer?: InMemoryStabilityWindowBuffer): Sink<SupportedProjections> =>
  (projections) =>
  (evt$) =>
    evt$.pipe(
      withStaticContext({ store }),
      applySinksSerially<WithInMemoryStore>()(projections, allSinks),
      buffer?.handleEvents() || passthrough(),
      map(({ store: _, ...evt }) => evt)
    );
