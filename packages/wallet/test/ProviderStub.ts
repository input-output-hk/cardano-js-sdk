/* eslint-disable max-len */
import * as Schema from '@cardano-ogmios/schema';

export const stakeKeyHash = 'stake_test1up7pvfq8zn4quy45r2g572290p9vf99mr9tn7r9xrgy2l2qdsf58d';

export const utxo: Schema.Utxo = [
  [
    {
      txId: 'bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0',
      index: 1
    },
    {
      address:
        'addr_test1qzs0umu0s2ammmpw0hea0w2crtcymdjvvlqngpgqy76gpfnuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qp3y3vz',
      value: {
        coins: 4_027_026_465
      },
      datum: null
    }
  ],
  [
    {
      txId: 'c7c0973c6bbf1a04a9f306da7814b4fa564db649bf48b0bd93c273bd03143547',
      index: 0
    },
    {
      address:
        'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g',
      value: {
        coins: 3_289_566
      },
      datum: null
    }
  ],
  [
    {
      txId: 'ea1517b8c36fea3148df9aa1f49bbee66ff59a5092331a67bd8b3c427e1d79d7',
      index: 2
    },
    {
      address:
        'addr_test1qqydn46r6mhge0kfpqmt36m6q43knzsd9ga32n96m89px3nuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qypp3m9',
      value: {
        coins: 9_825_963
      },
      datum: null
    }
  ]
];

export const delegate = 'pool185g59xpqzt7gf0ljr8v8f3akl95qnmardf2f8auwr3ffx7atjj5';
export const rewards = 33_333;
export const delegationAndRewards = { delegate, rewards };

export const queryTransactionsResult = [
  {
    hash: 'ea1517b8c36fea3148df9aa1f49bbee66ff59a5092331a67bd8b3c427e1d79d7',
    inputs: [
      {
        txId: 'bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0',
        index: 0
      }
    ],
    outputs: [
      {
        address:
          'addr_test1qpfhhfy2qgls50r9u4yh0l7z67xpg0a5rrhkmvzcuqrd0znuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q9gw0lz',
        value: { coins: 5_000_000 }
      },
      {
        address:
          'addr_test1qplfzem2xsc29wxysf8wkdqrm4s4mmncd40qnjq9sk84l3tuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q52ukj5',
        value: { coins: 5_000_000 }
      },
      {
        address:
          'addr_test1qqydn46r6mhge0kfpqmt36m6q43knzsd9ga32n96m89px3nuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qypp3m9',
        value: { coins: 9_825_963 }
      }
    ]
  }
];
const queryTransactions = () => jest.fn().mockResolvedValue(queryTransactionsResult);

export const ledgerTip = {
  blockNo: 1_111_111,
  hash: '10d64cc11e9b20e15b6c46aa7b1fed11246f437e62225655a30ea47bf8cc22d0',
  slot: 37_834_496
};

/**
 * Provider stub for testing
 *
 * returns CardanoProvider-compatible object
 */
export const providerStub = () => ({
  ledgerTip: jest.fn().mockResolvedValue(ledgerTip),
  networkInfo: async () => ({
    currentEpoch: {
      number: 158,
      start: {
        date: new Date(1_632_255_616)
      },
      end: {
        date: new Date(1_632_687_616)
      }
    },
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
  submitTx: jest.fn().mockResolvedValue(void 0),
  stakePoolStats: async () => ({
    qty: {
      active: 1000,
      retired: 500,
      retiring: 5
    }
  }),
  utxoDelegationAndRewards: jest.fn().mockResolvedValue({ utxo, delegationAndRewards }),
  queryTransactionsByAddresses: queryTransactions(),
  queryTransactionsByHashes: queryTransactions(),
  currentWalletProtocolParameters: async () => ({
    minFeeCoefficient: 44,
    minFeeConstant: 155_381,
    stakeKeyDeposit: 2_000_000,
    poolDeposit: 500_000_000,
    protocolVersion: { major: 5, minor: 0 },
    minPoolCost: 340_000_000,
    maxTxSize: 16_384,
    maxValueSize: 1000,
    maxCollateralInputs: 1,
    coinsPerUtxoWord: 34_482
  })
});

export type ProviderStub = ReturnType<typeof providerStub>;
