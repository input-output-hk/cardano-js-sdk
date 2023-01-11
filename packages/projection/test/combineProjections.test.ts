import { combineProjections } from '../src/combineProjections';
import { projections } from '../src';

describe('combineProjections', () => {
  it('deduplicates operators', () => {
    expect(
      combineProjections({
        stakeKeys: projections.stakeKeys,
        stakePools: projections.stakePools
      }).length
    ).toBeLessThan(projections.stakeKeys.length + projections.stakePools.length);
  });
});
