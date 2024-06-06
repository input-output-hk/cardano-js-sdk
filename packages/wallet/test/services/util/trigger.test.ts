import { Cardano } from '@cardano-sdk/core';
import { createTestScheduler, testnetEraSummaries } from '@cardano-sdk/util-dev';
import merge from 'lodash/merge.js';
import type { EraSummary } from '@cardano-sdk/core';

import { distinctBlock, distinctEraSummaries } from '../../../src/services/util/index.js';

describe('trigger', () => {
  it('distinctBlock subscribes to tip$ on each subscription and emits when tip$ has new blockNo', () => {
    createTestScheduler().run(({ cold, expectObservable }) => {
      const tip$ = cold('a--b--c', {
        a: { blockNo: Cardano.BlockNo(100) } as Cardano.Tip,
        b: { blockNo: Cardano.BlockNo(100) } as Cardano.Tip,
        c: { blockNo: Cardano.BlockNo(101) } as Cardano.Tip
      });
      const distinctTip$ = distinctBlock(tip$);
      expectObservable(distinctTip$).toBe('a-----b', {
        a: 100,
        b: 101
      });
      expectObservable(distinctTip$, '-^-----').toBe('-a-----b', {
        a: 100,
        b: 101
      });
    });
  });

  it('distinctEraSummaries emits when eraSummaries changes', () => {
    createTestScheduler().run(({ cold, expectObservable }) => {
      const eraSummaries1 = testnetEraSummaries;
      const latestEraSummary = eraSummaries1[eraSummaries1.length - 1];
      const eraSummaries2 = [
        ...testnetEraSummaries,
        merge({}, latestEraSummary, {
          parameters: { epochLength: 1, slotLength: 1 },
          start: { slot: latestEraSummary.start.slot + 10_000 }
        })
      ];
      const eraSummaries$ = cold('-a--b-c', {
        a: eraSummaries1 as EraSummary[],
        b: [...eraSummaries1] as EraSummary[],
        c: eraSummaries2 as EraSummary[]
      });
      expectObservable(distinctEraSummaries(eraSummaries$)).toBe('-a----b', {
        a: eraSummaries1,
        b: eraSummaries2
      });
    });
  });
});
