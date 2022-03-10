/* eslint-disable max-len */
import { AssetId } from '@cardano-sdk/util-dev';
import { Cardano, EpochRewards, WalletProvider } from '@cardano-sdk/core';

export const rewardAccount = Cardano.RewardAccount('stake_test1up7pvfq8zn4quy45r2g572290p9vf99mr9tn7r9xrgy2l2qdsf58d');

export const utxo: Cardano.Utxo[] = [
  [
    {
      address: Cardano.Address(
        'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g'
      ),
      index: 1,
      txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
    },
    {
      address: Cardano.Address(
        'addr_test1qzs0umu0s2ammmpw0hea0w2crtcymdjvvlqngpgqy76gpfnuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qp3y3vz'
      ),
      value: {
        assets: new Map([
          [AssetId.PXL, 5n],
          [AssetId.TSLA, 10n]
        ]),
        coins: 4_027_026_465n
      }
    }
  ],
  [
    {
      address: Cardano.Address(
        'addr_test1qzs0umu0s2ammmpw0hea0w2crtcymdjvvlqngpgqy76gpfnuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qp3y3vz'
      ),
      index: 0,
      txId: Cardano.TransactionId('c7c0973c6bbf1a04a9f306da7814b4fa564db649bf48b0bd93c273bd03143547')
    },
    {
      address: Cardano.Address(
        'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g'
      ),
      value: {
        assets: new Map([[AssetId.TSLA, 15n]]),
        coins: 3_289_566n
      }
    }
  ],
  [
    {
      address: Cardano.Address(
        'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g'
      ),
      index: 2,
      txId: Cardano.TransactionId('ea1517b8c36fea3148df9aa1f49bbee66ff59a5092331a67bd8b3c427e1d79d7')
    },
    {
      address: Cardano.Address(
        'addr_test1qqydn46r6mhge0kfpqmt36m6q43knzsd9ga32n96m89px3nuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qypp3m9'
      ),
      value: {
        coins: 9_825_963n
      }
    }
  ]
];

export const delegate = 'pool185g59xpqzt7gf0ljr8v8f3akl95qnmardf2f8auwr3ffx7atjj5';
export const rewards = 33_333n;
export const delegationAndRewards = { delegate, rewards };

export const ledgerTip = {
  blockNo: 1_111_111,
  hash: '10d64cc11e9b20e15b6c46aa7b1fed11246f437e62225655a30ea47bf8cc22d0',
  slot: 37_834_496
};

export const currentEpoch = {
  end: {
    date: new Date(1_632_687_616)
  },
  number: 158,
  start: {
    date: new Date(1_632_255_616)
  }
};

export const queryTransactionsResult: Cardano.TxAlonzo[] = [
  {
    blockHeader: {
      slot: ledgerTip.slot - 100_000
    },
    body: {
      certificates: [
        {
          __typename: Cardano.CertificateType.StakeKeyRegistration
        },
        {
          __typename: Cardano.CertificateType.StakeDelegation,
          epoch: currentEpoch.number - 10
        }
      ],
      inputs: [
        {
          address: Cardano.Address(
            'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g'
          ),
          index: 0,
          txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
        }
      ],
      outputs: [
        {
          address: Cardano.Address(
            'addr_test1qpfhhfy2qgls50r9u4yh0l7z67xpg0a5rrhkmvzcuqrd0znuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q9gw0lz'
          ),
          value: { coins: 5_000_000n }
        },
        {
          address: Cardano.Address(
            'addr_test1qplfzem2xsc29wxysf8wkdqrm4s4mmncd40qnjq9sk84l3tuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q52ukj5'
          ),
          value: { coins: 5_000_000n }
        },
        {
          address: Cardano.Address(
            'addr_test1qqydn46r6mhge0kfpqmt36m6q43knzsd9ga32n96m89px3nuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qypp3m9'
          ),
          value: { coins: 9_825_963n }
        }
      ],
      validityInterval: {
        invalidHereafter: ledgerTip.slot + 1
      }
    }
  } as Cardano.TxAlonzo
];
const queryTransactions = () => jest.fn().mockResolvedValue(queryTransactionsResult);

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

export const rewardsHistory: EpochRewards[] = [
  {
    epoch: currentEpoch.number - 3,
    rewards: 10_000n
  },
  {
    epoch: currentEpoch.number - 2,
    rewards: 11_000n
  }
];

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

/**
 * Provider stub for testing
 *
 * returns WalletProvider-compatible object
 */
export const mockWalletProvider = (): WalletProvider => ({
  currentWalletProtocolParameters: jest.fn().mockResolvedValue(protocolParameters),
  genesisParameters: jest.fn().mockResolvedValue(genesisParameters),
  ledgerTip: jest.fn().mockResolvedValue(ledgerTip),
  networkInfo: jest.fn().mockResolvedValue({
    currentEpoch,
    lovelaceSupply: {
      circulating: 42_064_399_450_423_723n,
      max: 45_000_000_000_000_000n,
      total: 40_267_211_394_073_980n
    },
    stake: {
      active: 1_060_378_314_781_343n,
      live: 15_001_884_895_856_815n
    }
  }),
  queryBlocksByHashes: jest.fn().mockResolvedValue([{ epoch: currentEpoch.number - 3 } as Cardano.Block]),
  queryTransactionsByAddresses: queryTransactions(),
  queryTransactionsByHashes: queryTransactions(),
  rewardsHistory: jest.fn().mockResolvedValue(rewardsHistory),
  stakePoolStats: async () => ({
    qty: {
      active: 1000,
      retired: 500,
      retiring: 5
    }
  }),
  utxoDelegationAndRewards: jest.fn().mockResolvedValue({ delegationAndRewards, utxo })
});

export type WalletProviderStub = ReturnType<typeof mockWalletProvider>;
