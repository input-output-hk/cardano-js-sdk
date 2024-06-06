import { Cardano, CardanoNodeUtil } from '../../../src/index.js';
import { mockStakeDistribution } from '../mocks.js';

describe('stakeDistribution', () => {
  describe('toLiveStake', () => {
    it('returns the live network stake from a given stake distribution', () => {
      const liveStake = CardanoNodeUtil.toLiveStake(mockStakeDistribution);
      expect(liveStake).toBe(
        mockStakeDistribution.get(Cardano.PoolId('pool1la4ghj4w4f8p4yk4qmx0qvqmzv6592ee9rs0vgla5w6lc2nc8w5'))!.stake
          .pool +
          mockStakeDistribution.get(Cardano.PoolId('pool1lad5j5kawu60qljfqh02vnazxrahtaaj6cpaz4xeluw5xf023cg'))!.stake
            .pool +
          mockStakeDistribution.get(Cardano.PoolId('pool1llugtz5r4t6m7xz6es4qu7cszllm5y3uvx3ast5a9jzlv7h3xdu'))!.stake
            .pool +
          mockStakeDistribution.get(Cardano.PoolId('pool1lu6ll4rcxm92059ggy6uym2p804s5hcwqyyn5vyqhy35kuxtn2f'))!.stake
            .pool
      );
    });
    it('returns 0 if the distribution contains no pools, rather than throwing', () => {
      const liveStake = CardanoNodeUtil.toLiveStake(new Map());
      expect(liveStake).toBe(0n);
    });
  });
});
