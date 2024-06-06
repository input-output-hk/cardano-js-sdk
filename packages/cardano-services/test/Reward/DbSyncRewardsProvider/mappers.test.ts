import { Cardano } from '@cardano-sdk/core';
import { rewardsToCore } from '../../../src/index.js';

describe('DbSyncRewardProvider mappers', () => {
  const rewardAddress1 = 'stake_test1uzxvhl83q8ujv2yvpy6n2krvpdlqqx28h7e9vsk6re43h3c3kufy6';
  const rewardAddress2 = 'stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27';
  const rewardsModels = [
    {
      address: rewardAddress1,
      epoch: 10,
      pool_id: 'pool1h8yl5mkyrfmfls2x9fu9mls3ry6egnw4q6efg34xr37zc243gkf',
      quantity: '10000000'
    }
  ];
  it('rewardsToCore returns core types', () => {
    const result = rewardsToCore(rewardsModels);

    expect(result.has(Cardano.RewardAccount(rewardAddress1))).toEqual(true);
    expect(result.get(Cardano.RewardAccount(rewardAddress1))![0]).toMatchShapeOf({ epoch: 10, rewards: 10_000_000n });
  });
  it('rewardsToCore empty rewards returns core types', () => {
    expect(rewardsToCore([]).size).toEqual(0);
  });
  it('rewardsToCore returns core types indexed by address', () => {
    const rewards = [
      {
        address: rewardAddress1,
        epoch: 11,
        pool_id: 'pool1h8yl5mkyrfmfls2x9fu9mls3ry6egnw4q6efg34xr37zc243gkf',
        quantity: '20000000'
      },
      {
        address: 'stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27',
        epoch: 15,
        pool_id: 'pool1h8yl5mkyrfmfls2x9fu9mls3ry6egnw4q6efg34xr37zc243gkf',
        quantity: '30000000'
      }
    ];

    const result = rewardsToCore([...rewardsModels, ...rewards]);

    expect(result.size).toEqual(2);
    expect(result.has(Cardano.RewardAccount(rewardAddress1))).toEqual(true);
    expect(result.get(Cardano.RewardAccount(rewardAddress1))![0]).toEqual({
      epoch: 10,
      poolId: Cardano.PoolId('pool1h8yl5mkyrfmfls2x9fu9mls3ry6egnw4q6efg34xr37zc243gkf'),
      rewards: 10_000_000n
    });
    expect(result.get(Cardano.RewardAccount(rewardAddress1))![1]).toEqual({
      epoch: 11,
      poolId: Cardano.PoolId('pool1h8yl5mkyrfmfls2x9fu9mls3ry6egnw4q6efg34xr37zc243gkf'),
      rewards: 20_000_000n
    });
    expect(result.has(Cardano.RewardAccount(rewardAddress2))).toEqual(true);
    expect(result.get(Cardano.RewardAccount(rewardAddress2))![0]).toEqual({
      epoch: 15,
      poolId: Cardano.PoolId('pool1h8yl5mkyrfmfls2x9fu9mls3ry6egnw4q6efg34xr37zc243gkf'),
      rewards: 30_000_000n
    });
  });
});
