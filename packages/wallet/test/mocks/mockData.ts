import { Cardano, EpochRewards, Seconds } from '@cardano-sdk/core';
import { KeyRole } from '@cardano-sdk/key-management';

export const rewardAccount = Cardano.RewardAccount('stake_test1up7pvfq8zn4quy45r2g572290p9vf99mr9tn7r9xrgy2l2qdsf58d');
export const stakeKeyHash = Cardano.RewardAccount.toHash(rewardAccount);

export const stakeKeyDerivationPath = {
  index: 0,
  role: KeyRole.Stake
};

export const rewardAccountBalance = 33_333n;

export const ledgerTip = {
  blockNo: Cardano.BlockNo(1_111_111),
  hash: '10d64cc11e9b20e15b6c46aa7b1fed11246f437e62225655a30ea47bf8cc22d0',
  slot: Cardano.Slot(37_834_496)
};

export const currentEpoch = {
  number: 157
};

export const protocolParameters = {
  coinsPerUtxoByte: 4310,
  maxCollateralInputs: 1,
  maxTxSize: 16_384,
  maxValueSize: 1000,
  minFeeCoefficient: 44,
  minFeeConstant: 155_381,
  minPoolCost: 340_000_000,
  poolDeposit: 500_000_000,
  prices: { memory: 0.0577, steps: 0.000_007_21 },
  protocolVersion: { major: 5, minor: 0 },
  stakeKeyDeposit: 2_000_000
};

export const epochRewards = [
  {
    epoch: Cardano.EpochNo(currentEpoch.number - 3),
    rewards: 10_000n
  },
  {
    epoch: Cardano.EpochNo(currentEpoch.number - 2),
    rewards: 11_000n
  }
];
export const rewardsHistory: Map<Cardano.RewardAccount, EpochRewards[]> = new Map([[rewardAccount, epochRewards]]);

export const genesisParameters: Cardano.CompactGenesis = {
  activeSlotsCoefficient: 0.05,
  epochLength: 432_000,
  maxKesEvolutions: 62,
  maxLovelaceSupply: 45_000_000_000_000_000n,
  networkId: 0,
  networkMagic: 764_824_073,
  securityParameter: 2160,
  slotLength: Seconds(1),
  slotsPerKesPeriod: 129_600,
  systemStart: new Date(1_506_203_091_000),
  updateQuorum: 5
};

export const rewardsHistory2 = new Map<Cardano.RewardAccount, EpochRewards[]>([
  [
    rewardAccount,
    [
      {
        epoch: Cardano.EpochNo(currentEpoch.number - 4),
        rewards: 10_000n
      },
      ...epochRewards
    ]
  ]
]);
export const rewardAccountBalance2 = rewardAccountBalance + 1n;

export const utxosWithLowCoins: Cardano.Utxo[] = [
  [
    {
      address: Cardano.Address(
        'addr_test1qzs0umu0s2ammmpw0hea0w2crtcymdjvvlqngpgqy76gpfnuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qp3y3vz'
      ),
      index: 1,
      txId: Cardano.TransactionId('c7c0973c6bbf1a04a9f306da7814b4fa564db649bf48b0bd93c273bd03143547')
    },
    {
      address: Cardano.Address(
        'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g'
      ),
      value: {
        coins: 3_289_566n
      }
    }
  ],
  [
    {
      address: Cardano.Address(
        'addr_test1qzs0umu0s2ammmpw0hea0w2crtcymdjvvlqngpgqy76gpfnuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qp3y3vz'
      ),
      index: 2,
      txId: Cardano.TransactionId('c7c0973c6bbf1a04a9f306da7814b4fa564db649bf48b0bd93c273bd03143547')
    },
    {
      address: Cardano.Address(
        'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g'
      ),
      value: {
        coins: 1_000_000n
      }
    }
  ]
];
