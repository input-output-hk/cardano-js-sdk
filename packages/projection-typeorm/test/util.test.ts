import { Projections } from '@cardano-sdk/projection';
import { applySinks, shouldEnablePgBossExtension } from '../src/util';
import { stakePoolMetadata, stakePools } from '../src/sinks';
import pick from 'lodash/pick';

describe('typeorm util', () => {
  describe('shouldEnablePgBossExtension', () => {
    it('returns true if any least one projection specifies it', () => {
      expect(shouldEnablePgBossExtension(pick(Projections.allProjections, 'stakePoolMetadata'))).toBe(true);
    });
    it('returns false if no projections specifies it', () => {
      expect(shouldEnablePgBossExtension(pick(Projections.allProjections, ['stakeKeys', 'stakePools']))).toBe(false);
    });
  });

  describe('applySinks', () => {
    it('applies sinks in topological order', () => {
      const pipe = jest.fn();
      applySinks(pick(Projections.allProjections, ['stakePoolMetadata', 'stakePools']), [
        ['stakePoolMetadata', stakePoolMetadata],
        ['stakePools', stakePools]
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
      ])({ pipe } as any);
      expect(pipe).toBeCalledWith(stakePools.sink$, stakePoolMetadata.sink$);
    });
  });
});
