import { Cardano, RewardAccountInfoProvider } from '@cardano-sdk/core';
import { rewardAccountBalance } from './mockData';
import { somePartialStakePools } from '../createStubStakePoolProvider';

export const mockRewardAccountInfoProvider = (): jest.Mocked<RewardAccountInfoProvider> => ({
  delegationPortfolio: jest.fn().mockResolvedValue(null),
  healthCheck: jest.fn().mockResolvedValue({ ok: true }),
  rewardAccountInfo: jest.fn().mockImplementation(
    (address) =>
      ({
        address,
        credentialStatus: Cardano.StakeCredentialStatus.Registered,
        delegatee: {
          currentEpoch: somePartialStakePools[0],
          nextEpoch: somePartialStakePools[0],
          nextNextEpoch: somePartialStakePools[0]
        },
        deposit: 2_000_000n,
        rewardBalance: rewardAccountBalance
      } as Cardano.RewardAccountInfo)
  )
});
