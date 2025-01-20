import { Cardano, Paginated, RewardsProvider, StakePoolProvider } from '@cardano-sdk/core';
import { Percent } from '@cardano-sdk/util';
import { epochRewards, rewardAccountBalance, rewardsHistory, rewardsHistory2 } from './mockData';
import { getRandomTxId } from './mockChainHistoryProvider';
import delay from 'delay';

export const mockRewardsProvider = ({
  rewardAccount
}: { rewardAccount?: Cardano.RewardAccount } = {}): jest.Mocked<RewardsProvider> => ({
  healthCheck: jest.fn().mockResolvedValue({ ok: true }),
  rewardAccountBalance: jest.fn().mockResolvedValue(rewardAccountBalance),
  rewardsHistory: jest.fn().mockResolvedValue(rewardAccount ? new Map([[rewardAccount, epochRewards]]) : rewardsHistory)
});

export const mockRewardsProvider2 = (delayMs: number) => {
  const delayedJestFn = <T>(resolvedValue: T) =>
    jest.fn().mockImplementation(() => delay(delayMs).then(() => resolvedValue));
  return {
    healthCheck: delayedJestFn({ ok: true }),
    rewardAccountBalance: delayedJestFn(rewardAccountBalance),
    rewardsHistory: delayedJestFn(rewardsHistory2)
  };
};

export const generateStakePools = (qty: number): Cardano.StakePool[] =>
  [...Array.from({ length: qty }).keys()].map(() => ({
    cost: 340_000_000n,
    hexId: Cardano.PoolIdHex('5d99282bbb4840380bb98c075498ed1983aee18a4a0925b9b44d93f1'),
    id: Cardano.PoolId('pool1tkvjs2amfpqrszae3sr4fx8drxp6acv2fgyjtwd5fkflzguqp96'),
    margin: {
      denominator: 1000,
      numerator: 27
    },
    metadata: {
      description: 'Pool a of the banderini devtest stake pools',
      homepage: 'http://www.banderini.net',
      name: 'banderini-devtest-a',
      ticker: 'BANDA'
    },
    metadataJson: {
      // Hash type would create a dependency on 'crypto' package
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      hash: getRandomTxId() as any,
      url: 'https://git.io/JJ7wm'
    },
    metrics: {
      apy: Percent(0),
      blocksCreated: 0,
      delegators: 1,
      lastRos: Percent(0),
      livePledge: 495_463_149n,
      ros: Percent(0),
      saturation: Percent(0.000_035_552_103_558_591_88),
      size: {
        active: Percent(1),
        live: Percent(0)
      },
      stake: {
        active: 2_986_376_991n,
        live: 0n
      }
    },
    owners: [],
    pledge: 100_000_000n,
    relays: [],
    rewardAccount: Cardano.RewardAccount('stake_test1upx9faamuf54pm7alg4lna5l7ll08pz833rj45tgr9m2jyceasqjt'),
    status: Cardano.StakePoolStatus.Active,
    vrf: Cardano.VrfVkHex(getRandomTxId())
  }));

export const stakePoolsPaginated: Paginated<Cardano.StakePool> = {
  pageResults: generateStakePools(10),
  totalResultCount: 1
};

const stakePoolStatsMock = {
  qty: {
    activating: 0,
    active: 5,
    retired: 5,
    retiring: 5
  }
};

export const mockStakePoolsProvider = (): StakePoolProvider => ({
  healthCheck: jest.fn().mockResolvedValue({ ok: true }),
  queryStakePools: jest.fn().mockResolvedValue(stakePoolsPaginated),
  stakePoolStats: jest.fn().mockResolvedValue(stakePoolStatsMock)
});

export type RewardsProviderStub = ReturnType<typeof mockRewardsProvider>;
