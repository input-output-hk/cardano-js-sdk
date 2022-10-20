import { Cardano } from '@cardano-sdk/core';
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
  address: Cardano.Address('addr_test1wrsexavz37208qda7mwwu4k7hcpg26cz0ce86f5e9kul3hqzlh22t')
};

export const txOutBaseWithDatum: Omit<Cardano.TxOut, 'value'> = {
  ...txOutBase,
  datum: Cardano.util.Hash32ByteBase16('c5dfa8c3cbd5a959829618a7b46e163078cb3f1b39f152514d0c3686d553529a')
};

export const txOutWithCoinOnly: Cardano.TxOut = { ...txOutBase, value: valueWithCoinOnly };

export const txOutWithAssets: Cardano.TxOut = { ...txOutBase, value: valueWithAssets };

export const txIn: Cardano.TxIn = {
  address: Cardano.Address('addr_test1wrsexavz37208qda7mwwu4k7hcpg26cz0ce86f5e9kul3hqzlh22t'),
  index: 0,
  txId: Cardano.TransactionId('cefd2fcf657e5e5d6c35975f4e052f427819391b153ebb16ad8aa107ba5a3819')
};

export const base = {
  auxiliaryData: {
    body: {
      blob: new Map()
    }
  },
  blockHeader: {
    blockNo: 3_157_934,
    hash: Cardano.BlockId('f03084089ec7e74a79e69a5929b2d3c0836d6f12279bd103d0875847c740ae27'),
    slot: 45_286_016
  } as Cardano.TxAlonzo['blockHeader'],
  body: {
    fee: 191_109n,
    inputs: [txIn],
    outputs: [txOutWithCoinOnly],
    validityInterval: {
      invalidBefore: undefined,
      invalidHereafter: undefined
    }
  } as Omit<Cardano.TxAlonzo['body'], 'outputs'>,
  id: Cardano.TransactionId('cefd2fcf657e5e5d6c35975f4e052f427819391b153ebb16ad8aa107ba5a3819'),
  index: 30,
  txSize: 711,
  witness: {
    signatures: new Map()
  }
};

export const withCoinOnly: Cardano.TxAlonzo = merge(base, {
  body: { outputs: [txOutWithCoinOnly] }
});

export const withAssets: Cardano.TxAlonzo = merge(base, {
  body: {
    ...base.body,
    outputs: [txOutWithAssets]
  },
  witness: {
    signatures: new Map()
  }
});

export const withMint: Cardano.TxAlonzo = merge(withAssets, {
  body: {
    mint: new Map([
      [Cardano.AssetId('57fca08abbaddee36da742a839f7d83a7e1d2419f1507fcbf3916522534245525259'), 10_000_000n]
    ])
  }
});

export const mint: Cardano.TokenMap = new Map([
  [Cardano.AssetId('57fca08abbaddee36da742a839f7d83a7e1d2419f1507fcbf3916522534245525259'), 10_000_000n]
]);

export const withAuxiliaryData: Cardano.TxAlonzo = merge(withAssets, {
  auxiliaryData: {
    body: {
      blob: new Map([[1, 'abc']])
    }
  }
});

export const delegationCertificate: Cardano.StakeDelegationCertificate = {
  __typename: Cardano.CertificateType.StakeDelegation,
  poolId: Cardano.PoolId('pool1cjm567pd9eqj7wlpuq2mnsasw2upewq0tchg4n8gktq5k7eepvr'),
  stakeKeyHash: Cardano.Ed25519KeyHash('f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80')
};

export const collateralInputs = [
  {
    address: 'addr_test1vryustw2u58ln2jhnp85mqzqntmtf076ywuvf8r03g2pw5q3xw00t',
    index: 0,
    txId: '4801e599cf8acc51364c7288d39f4b66ac8c480bbeac375d7138c485d0566197'
  }
];

export const withValidityInterval: Cardano.TxAlonzo = merge(withAssets, {
  body: {
    validityInterval: {
      invalidBefore: 1,
      invalidHereafter: 2
    }
  }
});

export const withWithdrawals: Cardano.TxAlonzo = merge(withAssets, {
  body: {
    // Todo: add withdrawal
    withdrawals: []
  }
});

export const witnessRedeemers = {
  redeemers: [
    {
      executionUnits: {
        memory: 1700,
        steps: 476_468
      },
      index: 0,
      purpose: 'spend',
      scriptHash: '67f33146617a5e61936081db3b2117cbf59bd2123748f58ac9678656'
    }
  ],
  signatures: {}
};

export const inputs = [
  {
    address:
      'addr_test1qpcncempf4svkpw0salztrsxzrfpr5ll323q5whw7lv94vyw0kz5rxvdaq6u6tslwfrrgz6l4n4lpcpnawn87yl9k6dsu4hhg2',
    index: 0,
    txId: '5293c1165896ab6bed6f7e969792fe4ac2202ddac5a5186d941ae2c9310b7056'
  }
];

export const outputs = [
  {
    address:
      'addr_test1qpcncempf4svkpw0salztrsxzrfpr5ll323q5whw7lv94vyw0kz5rxvdaq6u6tslwfrrgz6l4n4lpcpnawn87yl9k6dsu4hhg2',
    value: {
      coins: 13_499_999_999_819_540n
    }
  }
];

export const blockHeader: Cardano.TxAlonzo['blockHeader'] = {
  blockNo: 3_157_934,
  hash: Cardano.BlockId('f03084089ec7e74a79e69a5929b2d3c0836d6f12279bd103d0875847c740ae27'),
  slot: 45_286_016
};

export const tx = [
  base,
  withAssets,
  withAuxiliaryData,
  delegationCertificate,
  withCoinOnly,
  collateralInputs,
  withMint,
  witnessRedeemers,
  withValidityInterval,
  withWithdrawals,
  inputs,
  outputs,
  blockHeader
];
