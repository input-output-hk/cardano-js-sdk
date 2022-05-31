import { Cardano, EpochRewards } from '@cardano-sdk/core';

export const rewardAccount = Cardano.RewardAccount('stake_test1up7pvfq8zn4quy45r2g572290p9vf99mr9tn7r9xrgy2l2qdsf58d');
export const stakeKeyHash = Cardano.Ed25519KeyHash.fromRewardAccount(rewardAccount);

export const rewardAccountBalance = 33_333n;

export const ledgerTip = {
  blockNo: 1_111_111,
  hash: '10d64cc11e9b20e15b6c46aa7b1fed11246f437e62225655a30ea47bf8cc22d0',
  slot: 37_834_496
};

export const currentEpoch = {
  number: 157
};

export const protocolParameters = {
  coinsPerUtxoWord: 34_482,
  maxCollateralInputs: 1,
  maxTxSize: 16_384,
  maxValueSize: 1000,
  minFeeCoefficient: 44,
  minFeeConstant: 155_381,
  minPoolCost: 340_000_000,
  poolDeposit: 500_000_000,
  protocolVersion: { major: 5, minor: 0 },
  stakeKeyDeposit: 2_000_000
};

export const epochRewards = [
  {
    epoch: currentEpoch.number - 3,
    rewards: 10_000n
  },
  {
    epoch: currentEpoch.number - 2,
    rewards: 11_000n
  }
];
export const rewardsHistory: Map<Cardano.RewardAccount, EpochRewards[]> = new Map([[rewardAccount, epochRewards]]);

export const genesisParameters = {
  activeSlotsCoefficient: 0.05,
  epochLength: 432_000,
  maxKesEvolutions: 62,
  maxLovelaceSupply: 45_000_000_000_000_000n,
  networkMagic: 764_824_073,
  securityParameter: 2160,
  slotLength: 1,
  slotsPerKesPeriod: 129_600,
  systemStart: new Date(1_506_203_091_000),
  updateQuorum: 5
};
