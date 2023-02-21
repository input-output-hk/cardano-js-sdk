import { Projections } from '../src';
import { combineProjections } from '../src/combineProjections';

describe('combineProjections', () => {
  it('deduplicates operators', () => {
    expect(
      combineProjections({
        stakeKeys: Projections.stakeKeys,
        stakePools: Projections.stakePools
      }).length
    ).toBeLessThan(Projections.stakeKeys.length + Projections.stakePools.length);
  });
});
