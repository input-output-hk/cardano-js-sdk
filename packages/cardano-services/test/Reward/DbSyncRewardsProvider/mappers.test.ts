import { rewardsToCore } from '../../../src';

describe('DbSyncRewardProvider mappers', () => {
  const rewardsModels = [
    {
      address: 'stake_test1uzxvhl83q8ujv2yvpy6n2krvpdlqqx28h7e9vsk6re43h3c3kufy6',
      epoch: 10,
      quantity: '10000000'
    }
  ];
  it('rewardsToCore returns core types', () => {
    expect(rewardsToCore(rewardsModels)).toMatchSnapshot();
  });
  it('rewardsToCore empty rewards returns core types', () => {
    expect(rewardsToCore([])).toMatchSnapshot();
  });
  it('rewardsToCore returns core types indexed by address', () => {
    const rewards = [
      {
        address: 'stake_test1uzxvhl83q8ujv2yvpy6n2krvpdlqqx28h7e9vsk6re43h3c3kufy6',
        epoch: 11,
        quantity: '20000000'
      },
      {
        address: 'stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27',
        epoch: 15,
        quantity: '30000000'
      }
    ];
    expect(rewardsToCore([...rewardsModels, ...rewards])).toMatchSnapshot();
  });
});
