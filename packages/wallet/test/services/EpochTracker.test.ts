import { Cardano } from '@cardano-sdk/core';
import { createTestScheduler, testnetEraSummaries } from '@cardano-sdk/util-dev';
import type { EraSummary } from '@cardano-sdk/core';

import { currentEpochTracker } from '../../src/services/index.js';

describe('currentEpochTracker', () => {
  it('computes epoch info from eraSummaries$ and tip$', () => {
    createTestScheduler().run(({ hot, expectObservable }) => {
      const tip$ = hot('-a-b', {
        a: { slot: Cardano.Slot(123_456) } as Cardano.Tip,
        b: { slot: Cardano.Slot(1_234_567) } as Cardano.Tip
      });
      const eraSummaries$ = hot('a---', {
        a: testnetEraSummaries as EraSummary[]
      });
      const currentEpoch$ = currentEpochTracker(tip$, eraSummaries$);
      expectObservable(currentEpoch$).toBe('-a-b', {
        a: {
          epochNo: 5,
          firstSlot: {
            date: new Date('2019-08-18T20:20:16.000Z'),
            slot: 108_000
          },
          lastSlot: {
            date: new Date('2019-08-23T20:19:56.000Z'),
            slot: 129_599
          }
        },
        b: {
          epochNo: 57,
          firstSlot: {
            date: new Date('2020-05-04T20:20:16.000Z'),
            slot: 1_231_200
          },
          lastSlot: {
            date: new Date('2020-05-09T20:19:56.000Z'),
            slot: 1_252_799
          }
        }
      });
    });
  });
});
