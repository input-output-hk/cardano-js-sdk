import { Cardano } from '@cardano-sdk/core';
import { Hash28ByteBase16, Hash32ByteBase16 } from '@cardano-sdk/crypto';

import merge from 'lodash/merge';

export const valueWithCoinOnly: Cardano.Value = {
  coins: 7_420_514n
};

export const valueWithAssets: Cardano.Value = {
  ...valueWithCoinOnly,
  assets: new Map([
    [Cardano.AssetId('57fca08abbaddee36da742a839f7d83a7e1d2419f1507fcbf3916522534245525259'), 10_000_000n]
  ])
};

export const txOutBase: Omit<Cardano.TxOut, 'value' | 'datum'> = {
  address: Cardano.PaymentAddress('addr_test1wrsexavz37208qda7mwwu4k7hcpg26cz0ce86f5e9kul3hqzlh22t')
};

export const txOutBaseWithDatum: Omit<Cardano.TxOut, 'value'> = {
  ...txOutBase,
  datumHash: Hash32ByteBase16('c5dfa8c3cbd5a959829618a7b46e163078cb3f1b39f152514d0c3686d553529a')
};

export const txOutWithCoinOnly: Cardano.TxOut = { ...txOutBase, value: valueWithCoinOnly };

export const txOutWithAssets: Cardano.TxOut = { ...txOutBase, value: valueWithAssets };

export const txIn: Cardano.HydratedTxIn = {
  address: Cardano.PaymentAddress('addr_test1wrsexavz37208qda7mwwu4k7hcpg26cz0ce86f5e9kul3hqzlh22t'),
  index: 0,
  txId: Cardano.TransactionId('cefd2fcf657e5e5d6c35975f4e052f427819391b153ebb16ad8aa107ba5a3819')
};

export const base = {
  auxiliaryData: {
    blob: new Map()
  },
  blockHeader: {
    blockNo: Cardano.BlockNo(3_157_934),
    hash: Cardano.BlockId('f03084089ec7e74a79e69a5929b2d3c0836d6f12279bd103d0875847c740ae27'),
    slot: Cardano.Slot(45_286_016)
  } as Cardano.HydratedTx['blockHeader'],
  body: {
    fee: 191_109n,
    inputs: [txIn],
    outputs: [txOutWithCoinOnly],
    validityInterval: {
      invalidBefore: undefined,
      invalidHereafter: undefined
    }
  } as Omit<Cardano.HydratedTx['body'], 'outputs'>,
  id: Cardano.TransactionId('cefd2fcf657e5e5d6c35975f4e052f427819391b153ebb16ad8aa107ba5a3819'),
  index: 30,
  txSize: 711,
  witness: {
    signatures: new Map()
  }
};

export const withCoinOnly: Cardano.HydratedTx = merge(base, {
  body: { outputs: [txOutWithCoinOnly] },
  inputSource: Cardano.InputSource.inputs
});

export const withAssets: Cardano.HydratedTx = merge(base, {
  body: {
    ...base.body,
    outputs: [txOutWithAssets]
  },
  inputSource: Cardano.InputSource.inputs,
  witness: {
    signatures: new Map()
  }
});

export const withMint: Cardano.HydratedTx = merge(withAssets, {
  body: {
    mint: new Map([
      [Cardano.AssetId('57fca08abbaddee36da742a839f7d83a7e1d2419f1507fcbf3916522534245525259'), 10_000_000n]
    ])
  },
  inputSource: Cardano.InputSource.inputs
});

export const mint: Cardano.TokenMap = new Map([
  [Cardano.AssetId('57fca08abbaddee36da742a839f7d83a7e1d2419f1507fcbf3916522534245525259'), 10_000_000n]
]);

export const withAuxiliaryData: Cardano.HydratedTx = merge(withAssets, {
  auxiliaryData: {
    body: {
      blob: new Map([[1, 'abc']])
    }
  },
  inputSource: Cardano.InputSource.inputs
});

export const delegationCertificate: Cardano.StakeDelegationCertificate = {
  __typename: Cardano.CertificateType.StakeDelegation,
  poolId: Cardano.PoolId('pool1cjm567pd9eqj7wlpuq2mnsasw2upewq0tchg4n8gktq5k7eepvr'),
  stakeCredential: {
    hash: Hash28ByteBase16('f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80'),
    type: Cardano.CredentialType.KeyHash
  }
};

export const collateralInputs = [
  {
    address: 'addr_test1vryustw2u58ln2jhnp85mqzqntmtf076ywuvf8r03g2pw5q3xw00t',
    index: 0,
    txId: '4801e599cf8acc51364c7288d39f4b66ac8c480bbeac375d7138c485d0566197'
  }
];

export const withValidityInterval: Cardano.HydratedTx = merge(withAssets, {
  body: {
    validityInterval: {
      invalidBefore: 1,
      invalidHereafter: 2
    }
  },
  inputSource: Cardano.InputSource.inputs
});

export const withdrawals = [
  {
    quantity: 1_834_170_201n,
    stakeAddress: 'stake_test1uzfef3dmd0ykz9wfm3zx35pq4xdtla929hk6sx6tcen9h6s3vf52j'
  }
];

export const withWithdrawals: Cardano.HydratedTx = merge(withAssets, {
  body: {
    withdrawals
  },
  inputSource: Cardano.InputSource.inputs
});

export const witnessRedeemers = {
  redeemers: [
    {
      data: {},
      executionUnits: {
        memory: 1700,
        steps: 476_468
      },
      index: 0,
      purpose: 'spend'
    }
  ],
  signatures: {}
};

export const input = {
  address:
    'addr_test1qpcncempf4svkpw0salztrsxzrfpr5ll323q5whw7lv94vyw0kz5rxvdaq6u6tslwfrrgz6l4n4lpcpnawn87yl9k6dsu4hhg2',
  index: 0,
  txId: '5293c1165896ab6bed6f7e969792fe4ac2202ddac5a5186d941ae2c9310b7056'
};

export const inputs = [input];

export const output = {
  address:
    'addr_test1qpcncempf4svkpw0salztrsxzrfpr5ll323q5whw7lv94vyw0kz5rxvdaq6u6tslwfrrgz6l4n4lpcpnawn87yl9k6dsu4hhg2',
  value: {
    coins: 13_499_999_999_819_540n
  }
};

export const outputWithInlineDatum = {
  address:
    'addr_test1qpcncempf4svkpw0salztrsxzrfpr5ll323q5whw7lv94vyw0kz5rxvdaq6u6tslwfrrgz6l4n4lpcpnawn87yl9k6dsu4hhg2',
  datum: 42n,
  value: {
    coins: 13_499_999_999_819_540n
  }
};

export const outputs = [output];

export const blockHeader: Cardano.HydratedTx['blockHeader'] = {
  blockNo: Cardano.BlockNo(3_157_934),
  hash: Cardano.BlockId('f03084089ec7e74a79e69a5929b2d3c0836d6f12279bd103d0875847c740ae27'),
  slot: Cardano.Slot(45_286_016)
};

export const txInput = {
  address:
    // eslint-disable-next-line max-len
    'addr_test1qpv5muwgjmmtqh2ta0kq9pmz0nurg9kmw7dryueqt57mncynjnzmk67fvy2unhzydrgzp2v6hl625t0d4qd5h3nxt04qu0ww7k',
  id: '0',
  index: 0,
  txInputId: '0000000000000000000000000000000000000000000000000000000000000000',
  txSourceId: '0000000000000000000000000000000000000000000000000000000000000000'
};

export const txOut = {
  address:
    // eslint-disable-next-line max-len
    'addr_test1qpv5muwgjmmtqh2ta0kq9pmz0nurg9kmw7dryueqt57mncynjnzmk67fvy2unhzydrgzp2v6hl625t0d4qd5h3nxt04qu0ww7k',
  // datumHash: undefined,
  index: 0,
  txId: '59f3ea1bb67b39447aad523f35daa1950c833472bf9232b6c0abac968f45bad9',
  value: { /* assets: undefined,*/ coins: 3_061_089_499_500n }
};

export const txTokenMap = new Map<string, bigint>([
  ['ea53552348385c7421003f315b43271aee7e65ad900c195ce57fa0903030303030', 10n]
]);

export const withdrawal = {
  quantity: 1_834_170_201n,
  stakeAddress: 'stake_test1uzfef3dmd0ykz9wfm3zx35pq4xdtla929hk6sx6tcen9h6s3vf52j'
};

export const certificate = {
  __typename: 'StakeDelegationCertificate',
  poolId: 'pool19yv4rswp06fdnwg5zq0uk876gttewt86kytqrlt3ermnq3reky0',
  stakeCredential: {
    hash: '9394c5bb6bc96115c9dc4468d020a99abff4aa2deda81b4bc6665bea',
    type: 0
  }
};

export const redeemer = {
  data: {},
  executionUnits: {
    memory: 0,
    steps: 0
  },
  index: 0,
  purpose: 'spend'
};

export const tx = [
  base,
  certificate,
  withAssets,
  withAuxiliaryData,
  delegationCertificate,
  withCoinOnly,
  collateralInputs,
  withMint,
  witnessRedeemers,
  withValidityInterval,
  withWithdrawals,
  withdrawal,
  inputs,
  outputs,
  blockHeader,
  txInput,
  txOut,
  txTokenMap,
  redeemer,
  input,
  withdrawals,
  outputWithInlineDatum
];
