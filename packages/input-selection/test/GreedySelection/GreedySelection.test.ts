import { Cardano } from '@cardano-sdk/core';
import { GreedyInputSelector } from '../../src';
import { MOCK_NO_CONSTRAINTS, mockConstraintsToConstraints } from '../util/selectionConstraints';
import { TxTestUtil } from '@cardano-sdk/util-dev';
import {
  asAssetId,
  asPaymentAddress,
  asTokenMap,
  assertInputSelectionProperties,
  getCoinValueForAddress
} from '../util';

describe('GreedySelection', () => {
  it('consumes all the UTXOs in the set and returns that total amount distributed in the change minus the fee', async () => {
    const selector = new GreedyInputSelector({
      getChangeAddresses: async () =>
        new Map([
          [asPaymentAddress('A'), 1],
          [asPaymentAddress('B'), 1],
          [asPaymentAddress('C'), 1]
        ])
    });

    const preSelectedUtxo = new Set<Cardano.Utxo>();

    const utxo = new Set([
      TxTestUtil.createUnspentTxOutput({ coins: 2_000_000n }),
      TxTestUtil.createUnspentTxOutput({ coins: 2_000_000n }),
      TxTestUtil.createUnspentTxOutput({ coins: 2_000_000n }),
      TxTestUtil.createUnspentTxOutput({ coins: 2_000_000n }),
      TxTestUtil.createUnspentTxOutput({ coins: 2_000_000n })
    ]);
    const outputs = new Set<Cardano.TxOut>();
    const expectedFee = 500n;
    const implicitValue = {};
    const constraints = {
      ...MOCK_NO_CONSTRAINTS,
      minimumCostCoefficient: 100n
    };

    const results = await selector.select({
      constraints: mockConstraintsToConstraints(constraints),
      implicitValue,
      outputs,
      preSelectedUtxo,
      utxo
    });

    const {
      remainingUTxO,
      selection: { change, fee, inputs }
    } = results;

    expect(inputs).toEqual(utxo);
    expect(remainingUTxO.size).toEqual(0);
    expect(fee).toEqual(expectedFee);

    expect(getCoinValueForAddress('A', change)).toEqual(3_333_334n - expectedFee);
    expect(getCoinValueForAddress('B', change)).toEqual(3_333_334n);
    expect(getCoinValueForAddress('C', change)).toEqual(3_333_332n);

    expect(change).toEqual([
      { address: 'A', value: { assets: new Map([]), coins: 1_666_167n } },
      { address: 'B', value: { coins: 1_666_667n } },
      { address: 'C', value: { coins: 1_666_666n } },
      { address: 'A', value: { coins: 833_334n } },
      { address: 'B', value: { coins: 833_334n } },
      { address: 'C', value: { coins: 833_333n } },
      { address: 'A', value: { coins: 416_667n } },
      { address: 'B', value: { coins: 416_667n } },
      { address: 'C', value: { coins: 416_667n } },
      { address: 'A', value: { coins: 208_333n } },
      { address: 'B', value: { coins: 208_333n } },
      { address: 'C', value: { coins: 208_333n } },
      { address: 'A', value: { coins: 104_167n } },
      { address: 'B', value: { coins: 104_167n } },
      { address: 'C', value: { coins: 104_167n } },
      { address: 'A', value: { coins: 52_083n } },
      { address: 'A', value: { coins: 52_083n } },
      { address: 'B', value: { coins: 52_083n } },
      { address: 'B', value: { coins: 52_083n } },
      { address: 'C', value: { coins: 52_083n } },
      { address: 'C', value: { coins: 52_083n } }
    ]);

    assertInputSelectionProperties({
      constraints,
      implicitValue,
      outputs,
      results,
      utxo
    });
  });

  it('consumes the pre selected inputs plus all available UTXOs in the set and returns that total amount distributed in the change minus the fee', async () => {
    const selector = new GreedyInputSelector({
      getChangeAddresses: async () =>
        new Map([
          [asPaymentAddress('A'), 1],
          [asPaymentAddress('B'), 1]
        ])
    });

    const preSelectedUtxo = new Set([
      TxTestUtil.createUnspentTxOutput({ coins: 2_000_000n }),
      TxTestUtil.createUnspentTxOutput({ coins: 2_000_000n }),
      TxTestUtil.createUnspentTxOutput({ coins: 2_000_000n }),
      TxTestUtil.createUnspentTxOutput({ coins: 2_000_000n }),
      TxTestUtil.createUnspentTxOutput({ coins: 2_000_000n })
    ]);

    const utxo = new Set([
      TxTestUtil.createUnspentTxOutput({ coins: 2_000_000n }),
      TxTestUtil.createUnspentTxOutput({ coins: 2_000_000n }),
      TxTestUtil.createUnspentTxOutput({ coins: 2_000_000n }),
      TxTestUtil.createUnspentTxOutput({ coins: 2_000_000n }),
      TxTestUtil.createUnspentTxOutput({ coins: 2_000_000n })
    ]);
    const outputs = new Set<Cardano.TxOut>();
    const expectedFee = 1000n;
    const implicitValue = {};
    const constraints = {
      ...MOCK_NO_CONSTRAINTS,
      minimumCostCoefficient: 100n
    };

    const results = await selector.select({
      constraints: mockConstraintsToConstraints(constraints),
      implicitValue,
      outputs,
      preSelectedUtxo,
      utxo
    });

    const {
      remainingUTxO,
      selection: { change, fee, inputs }
    } = results;

    expect(inputs).toEqual(new Set([...utxo, ...preSelectedUtxo]));
    expect(remainingUTxO.size).toEqual(0);
    expect(fee).toEqual(expectedFee);

    expect(getCoinValueForAddress('A', change)).toEqual(10_000_000n - expectedFee);
    expect(getCoinValueForAddress('B', change)).toEqual(10_000_000n);

    expect(change).toEqual([
      { address: 'A', value: { assets: new Map([]), coins: 4_999_000n } },
      { address: 'B', value: { coins: 5_000_000n } },
      { address: 'A', value: { coins: 2_500_000n } },
      { address: 'B', value: { coins: 2_500_000n } },
      { address: 'A', value: { coins: 1_250_000n } },
      { address: 'B', value: { coins: 1_250_000n } },
      { address: 'A', value: { coins: 625_000n } },
      { address: 'B', value: { coins: 625_000n } },
      { address: 'A', value: { coins: 312_500n } },
      { address: 'A', value: { coins: 312_500n } },
      { address: 'B', value: { coins: 312_500n } },
      { address: 'B', value: { coins: 312_500n } }
    ]);

    assertInputSelectionProperties({
      constraints,
      implicitValue,
      outputs,
      results,
      utxo
    });
  });

  it('correctly accounts for outputs and returns the remaining amount distributed in the change minus the fee', async () => {
    const selector = new GreedyInputSelector({
      getChangeAddresses: async () =>
        new Map([
          [asPaymentAddress('A'), 1],
          [asPaymentAddress('B'), 1],
          [asPaymentAddress('C'), 1],
          [asPaymentAddress('D'), 1],
          [asPaymentAddress('E'), 1]
        ])
    });

    const preSelectedUtxo = new Set<Cardano.Utxo>();

    const utxo = new Set([
      TxTestUtil.createUnspentTxOutput({ coins: 5_000_000n }),
      TxTestUtil.createUnspentTxOutput({ coins: 4_000_000n }),
      TxTestUtil.createUnspentTxOutput({ coins: 4_000_000n }),
      TxTestUtil.createUnspentTxOutput({ coins: 4_000_000n }),
      TxTestUtil.createUnspentTxOutput({ coins: 4_000_000n })
    ]);

    const outputs = new Set([
      TxTestUtil.createOutput({ coins: 1_000_000n }),
      TxTestUtil.createOutput({ coins: 2_000_000n }),
      TxTestUtil.createOutput({ coins: 3_000_000n })
    ]);

    const expectedFee = 500n;
    const implicitValue = {};
    const constraints = {
      ...MOCK_NO_CONSTRAINTS,
      minimumCostCoefficient: 100n
    };

    const results = await selector.select({
      constraints: mockConstraintsToConstraints(constraints),
      implicitValue,
      outputs,
      preSelectedUtxo,
      utxo
    });

    const {
      remainingUTxO,
      selection: { change, fee, inputs }
    } = results;

    expect(inputs).toEqual(utxo);
    expect(remainingUTxO.size).toEqual(0);
    expect(fee).toEqual(expectedFee);

    expect(getCoinValueForAddress('A', change)).toEqual(3_000_000n - expectedFee);
    expect(getCoinValueForAddress('B', change)).toEqual(3_000_000n);
    expect(getCoinValueForAddress('C', change)).toEqual(3_000_000n);
    expect(getCoinValueForAddress('D', change)).toEqual(3_000_000n);
    expect(getCoinValueForAddress('E', change)).toEqual(3_000_000n);

    expect(change).toEqual([
      { address: 'A', value: { assets: new Map([]), coins: 1_499_500n } },
      { address: 'B', value: { coins: 1_500_000n } },
      { address: 'C', value: { coins: 1_500_000n } },
      { address: 'D', value: { coins: 1_500_000n } },
      { address: 'E', value: { coins: 1_500_000n } },
      { address: 'A', value: { coins: 750_000n } },
      { address: 'B', value: { coins: 750_000n } },
      { address: 'C', value: { coins: 750_000n } },
      { address: 'D', value: { coins: 750_000n } },
      { address: 'E', value: { coins: 750_000n } },
      { address: 'A', value: { coins: 375_000n } },
      { address: 'B', value: { coins: 375_000n } },
      { address: 'C', value: { coins: 375_000n } },
      { address: 'D', value: { coins: 375_000n } },
      { address: 'E', value: { coins: 375_000n } },
      { address: 'A', value: { coins: 187_500n } },
      { address: 'B', value: { coins: 187_500n } },
      { address: 'C', value: { coins: 187_500n } },
      { address: 'D', value: { coins: 187_500n } },
      { address: 'E', value: { coins: 187_500n } },
      { address: 'A', value: { coins: 93_750n } },
      { address: 'B', value: { coins: 93_750n } },
      { address: 'C', value: { coins: 93_750n } },
      { address: 'D', value: { coins: 93_750n } },
      { address: 'E', value: { coins: 93_750n } },
      { address: 'A', value: { coins: 46_875n } },
      { address: 'A', value: { coins: 46_875n } },
      { address: 'B', value: { coins: 46_875n } },
      { address: 'B', value: { coins: 46_875n } },
      { address: 'C', value: { coins: 46_875n } },
      { address: 'C', value: { coins: 46_875n } },
      { address: 'D', value: { coins: 46_875n } },
      { address: 'D', value: { coins: 46_875n } },
      { address: 'E', value: { coins: 46_875n } },
      { address: 'E', value: { coins: 46_875n } }
    ]);

    assertInputSelectionProperties({
      constraints,
      implicitValue,
      outputs,
      results,
      utxo
    });
  });

  it('allocates native assets evenly', async () => {
    const selector = new GreedyInputSelector({
      getChangeAddresses: async () =>
        new Map([
          [asPaymentAddress('A'), 1],
          [asPaymentAddress('B'), 1],
          [asPaymentAddress('C'), 1],
          [asPaymentAddress('D'), 1]
        ])
    });

    const preSelectedUtxo = new Set<Cardano.Utxo>();

    const utxo = new Set([
      TxTestUtil.createUnspentTxOutput({
        assets: asTokenMap([
          [asAssetId('0'), 100n],
          [asAssetId('1'), 23n]
        ]),
        coins: 5_000_000n
      }),
      TxTestUtil.createUnspentTxOutput({
        assets: asTokenMap([
          [asAssetId('2'), 1n],
          [asAssetId('3'), 1000n]
        ]),
        coins: 4_000_000n
      }),
      TxTestUtil.createUnspentTxOutput({
        assets: asTokenMap([[asAssetId('4'), 1500n]]),
        coins: 4_000_000n
      }),
      TxTestUtil.createUnspentTxOutput({
        assets: asTokenMap([[asAssetId('5'), 500n]]),
        coins: 4_000_000n
      }),
      TxTestUtil.createUnspentTxOutput({
        coins: 4_000_000n
      })
    ]);

    const outputs = new Set([
      TxTestUtil.createOutput({ coins: 2_000_000n }),
      TxTestUtil.createOutput({ coins: 2_000_000n })
    ]);

    const expectedFee = 500n;
    const implicitValue = {};
    const constraints = {
      ...MOCK_NO_CONSTRAINTS,
      minimumCostCoefficient: 100n
    };

    const results = await selector.select({
      constraints: mockConstraintsToConstraints(constraints),
      implicitValue,
      outputs,
      preSelectedUtxo,
      utxo
    });

    const {
      remainingUTxO,
      selection: { change, fee, inputs }
    } = results;

    expect(inputs).toEqual(utxo);
    expect(remainingUTxO.size).toEqual(0);
    expect(fee).toEqual(expectedFee);

    expect(getCoinValueForAddress('A', change)).toEqual(4_250_000n - expectedFee);
    expect(getCoinValueForAddress('B', change)).toEqual(4_250_000n);
    expect(getCoinValueForAddress('C', change)).toEqual(4_250_000n);
    expect(getCoinValueForAddress('D', change)).toEqual(4_250_000n);

    expect(change).toEqual([
      {
        address: 'A',
        value: {
          assets: asTokenMap([[asAssetId('0'), 100n]]),
          coins: 2_124_500n
        }
      },
      { address: 'B', value: { assets: asTokenMap([[asAssetId('1'), 23n]]), coins: 2_125_000n } },
      { address: 'C', value: { assets: asTokenMap([[asAssetId('2'), 1n]]), coins: 2_125_000n } },
      { address: 'D', value: { assets: asTokenMap([[asAssetId('3'), 1000n]]), coins: 2_125_000n } },
      { address: 'A', value: { assets: asTokenMap([[asAssetId('4'), 1500n]]), coins: 1_062_500n } },
      { address: 'B', value: { assets: asTokenMap([[asAssetId('5'), 500n]]), coins: 1_062_500n } },
      { address: 'C', value: { coins: 1_062_500n } },
      { address: 'D', value: { coins: 1_062_500n } },
      { address: 'A', value: { coins: 531_250n } },
      { address: 'B', value: { coins: 531_250n } },
      { address: 'C', value: { coins: 531_250n } },
      { address: 'D', value: { coins: 531_250n } },
      { address: 'A', value: { coins: 265_625n } },
      { address: 'B', value: { coins: 265_625n } },
      { address: 'C', value: { coins: 265_625n } },
      { address: 'D', value: { coins: 265_625n } },
      { address: 'A', value: { coins: 132_813n } },
      { address: 'B', value: { coins: 132_813n } },
      { address: 'C', value: { coins: 132_813n } },
      { address: 'D', value: { coins: 132_813n } },
      { address: 'A', value: { coins: 66_406n } },
      { address: 'B', value: { coins: 66_406n } },
      { address: 'C', value: { coins: 66_406n } },
      { address: 'D', value: { coins: 66_406n } },
      { address: 'A', value: { coins: 33_203n } },
      { address: 'A', value: { coins: 33_203n } },
      { address: 'B', value: { coins: 33_203n } },
      { address: 'B', value: { coins: 33_203n } },
      { address: 'C', value: { coins: 33_203n } },
      { address: 'C', value: { coins: 33_203n } },
      { address: 'D', value: { coins: 33_203n } },
      { address: 'D', value: { coins: 33_203n } }
    ]);

    assertInputSelectionProperties({
      constraints,
      implicitValue,
      outputs,
      results,
      utxo
    });
  });

  it('distributes native assets if they dont fit in a single output', async () => {
    const selector = new GreedyInputSelector({
      getChangeAddresses: async () =>
        new Map([
          [asPaymentAddress('A'), 2],
          [asPaymentAddress('B'), 1],
          [asPaymentAddress('C'), 1]
        ])
    });

    const preSelectedUtxo = new Set<Cardano.Utxo>();
    const utxo = new Set([
      TxTestUtil.createUnspentTxOutput({
        assets: asTokenMap([
          [asAssetId('0'), 100n],
          [asAssetId('1'), 23n]
        ]),
        coins: 5_000_000n
      }),
      TxTestUtil.createUnspentTxOutput({
        assets: asTokenMap([
          [asAssetId('2'), 1n],
          [asAssetId('3'), 1000n]
        ]),
        coins: 4_000_000n
      }),
      TxTestUtil.createUnspentTxOutput({
        assets: asTokenMap([[asAssetId('4'), 1500n]]),
        coins: 4_000_000n
      }),
      TxTestUtil.createUnspentTxOutput({
        assets: asTokenMap([[asAssetId('5'), 500n]]),
        coins: 4_000_000n
      }),
      TxTestUtil.createUnspentTxOutput({
        coins: 4_000_000n
      })
    ]);

    const outputs = new Set([
      TxTestUtil.createOutput({ coins: 2_000_000n }),
      TxTestUtil.createOutput({ coins: 2_000_000n })
    ]);

    const expectedFee = 1_000_000n;
    const implicitValue = {};
    const constraints = {
      ...MOCK_NO_CONSTRAINTS,
      maxTokenBundleSize: 2,
      minimumCoinQuantity: 2_000_000n,
      minimumCostCoefficient: 200_000n
    };

    const results = await selector.select({
      constraints: mockConstraintsToConstraints(constraints),
      implicitValue,
      outputs,
      preSelectedUtxo,
      utxo
    });

    const {
      remainingUTxO,
      selection: { change, fee, inputs }
    } = results;

    expect(inputs).toEqual(utxo);
    expect(remainingUTxO.size).toEqual(0);
    expect(fee).toEqual(expectedFee);

    expect(getCoinValueForAddress('A', change)).toEqual(8_500_000n - expectedFee);
    expect(getCoinValueForAddress('B', change)).toEqual(4_250_000n);
    expect(getCoinValueForAddress('C', change)).toEqual(4_250_000n);

    expect(change).toEqual([
      {
        address: 'A',
        value: {
          assets: asTokenMap([
            [asAssetId('0'), 100n],
            [asAssetId('4'), 1500n]
          ]),
          coins: 3_250_000n
        }
      },
      {
        address: 'A',
        value: {
          assets: asTokenMap([
            [asAssetId('1'), 23n],
            [asAssetId('5'), 500n]
          ]),
          coins: 4_250_000n
        }
      },
      {
        address: 'B',
        value: {
          assets: asTokenMap([[asAssetId('2'), 1n]]),
          coins: 4_250_000n
        }
      },
      { address: 'C', value: { assets: asTokenMap([[asAssetId('3'), 1000n]]), coins: 4_250_000n } }
    ]);

    assertInputSelectionProperties({
      constraints,
      implicitValue,
      outputs,
      results,
      utxo
    });
  });

  it('accounts for implicit coin', async () => {
    const selector = new GreedyInputSelector({
      // eslint-disable-next-line sonarjs/no-identical-functions
      getChangeAddresses: async () =>
        new Map([
          [asPaymentAddress('A'), 1],
          [asPaymentAddress('B'), 1]
        ])
    });

    const preSelectedUtxo = new Set<Cardano.Utxo>();

    const utxo = new Set([
      TxTestUtil.createUnspentTxOutput({ coins: 2_000_000n }),
      TxTestUtil.createUnspentTxOutput({ coins: 2_000_000n })
    ]);
    const outputs = new Set<Cardano.TxOut>();
    const expectedFee = 200n;
    const implicitValue = {
      coin: {
        deposit: 1_000_000n,
        input: 5_000_000n
      }
    };
    const constraints = {
      ...MOCK_NO_CONSTRAINTS,
      minimumCostCoefficient: 100n
    };

    const results = await selector.select({
      constraints: mockConstraintsToConstraints(constraints),
      implicitValue,
      outputs,
      preSelectedUtxo,
      utxo
    });

    const {
      remainingUTxO,
      selection: { change, fee, inputs }
    } = results;

    expect(inputs).toEqual(utxo);
    expect(remainingUTxO.size).toEqual(0);
    expect(fee).toEqual(expectedFee);

    expect(getCoinValueForAddress('A', change)).toEqual(4_000_000n - expectedFee);
    expect(getCoinValueForAddress('B', change)).toEqual(4_000_000n);

    expect(change).toEqual([
      { address: 'A', value: { assets: new Map([]), coins: 1_999_800n } },
      { address: 'B', value: { coins: 2_000_000n } },
      { address: 'A', value: { coins: 1_000_000n } },
      { address: 'B', value: { coins: 1_000_000n } },
      { address: 'A', value: { coins: 500_000n } },
      { address: 'B', value: { coins: 500_000n } },
      { address: 'A', value: { coins: 250_000n } },
      { address: 'B', value: { coins: 250_000n } },
      { address: 'A', value: { coins: 125_000n } },
      { address: 'B', value: { coins: 125_000n } },
      { address: 'A', value: { coins: 62_500n } },
      { address: 'B', value: { coins: 62_500n } },
      { address: 'A', value: { coins: 31_250n } },
      { address: 'A', value: { coins: 31_250n } },
      { address: 'B', value: { coins: 31_250n } },
      { address: 'B', value: { coins: 31_250n } }
    ]);

    assertInputSelectionProperties({
      constraints,
      implicitValue,
      outputs,
      results,
      utxo
    });
  });

  it('accounts for implicit asset (mint)', async () => {
    const selector = new GreedyInputSelector({
      getChangeAddresses: async () => new Map([[asPaymentAddress('A'), 1]])
    });

    const utxo = new Set([
      TxTestUtil.createUnspentTxOutput({
        coins: 5_000_000n
      }),
      TxTestUtil.createUnspentTxOutput({
        coins: 5_000_000n
      })
    ]);

    const preSelectedUtxo = new Set<Cardano.Utxo>();
    const outputs = new Set<Cardano.TxOut>();
    const expectedFee = 200n;
    const implicitValue = {
      mint: asTokenMap([[asAssetId('0'), 1n]])
    };
    const constraints = {
      ...MOCK_NO_CONSTRAINTS,
      minimumCostCoefficient: 100n
    };

    const results = await selector.select({
      constraints: mockConstraintsToConstraints(constraints),
      implicitValue,
      outputs,
      preSelectedUtxo,
      utxo
    });

    const {
      remainingUTxO,
      selection: { change, fee, inputs }
    } = results;

    expect(inputs).toEqual(utxo);
    expect(remainingUTxO.size).toEqual(0);
    expect(fee).toEqual(expectedFee);

    expect(getCoinValueForAddress('A', change)).toEqual(10_000_000n - expectedFee);

    expect(change).toEqual([
      { address: 'A', value: { assets: asTokenMap([[asAssetId('0'), 1n]]), coins: 4_999_800n } },
      { address: 'A', value: { coins: 2_500_000n } },
      { address: 'A', value: { coins: 1_250_000n } },
      { address: 'A', value: { coins: 625_000n } },
      { address: 'A', value: { coins: 312_500n } },
      { address: 'A', value: { coins: 312_500n } }
    ]);

    assertInputSelectionProperties({
      constraints,
      implicitValue,
      outputs,
      results,
      utxo
    });
  });

  it('accounts for implicit asset (burn)', async () => {
    const selector = new GreedyInputSelector({
      getChangeAddresses: async () => new Map([[asPaymentAddress('A'), 1]])
    });

    const utxo = new Set([
      TxTestUtil.createUnspentTxOutput({
        assets: asTokenMap([[asAssetId('0'), 1500n]]),
        coins: 5_000_000n
      }),
      TxTestUtil.createUnspentTxOutput({
        coins: 5_000_000n
      })
    ]);

    const preSelectedUtxo = new Set<Cardano.Utxo>();
    const outputs = new Set<Cardano.TxOut>();
    const expectedFee = 200n;
    const implicitValue = {
      mint: asTokenMap([[asAssetId('0'), -1000n]])
    };
    const constraints = {
      ...MOCK_NO_CONSTRAINTS,
      minimumCostCoefficient: 100n
    };

    const results = await selector.select({
      constraints: mockConstraintsToConstraints(constraints),
      implicitValue,
      outputs,
      preSelectedUtxo,
      utxo
    });

    const {
      remainingUTxO,
      selection: { change, fee, inputs }
    } = results;

    expect(inputs).toEqual(utxo);
    expect(remainingUTxO.size).toEqual(0);
    expect(fee).toEqual(expectedFee);

    expect(getCoinValueForAddress('A', change)).toEqual(10_000_000n - expectedFee);

    expect(change).toEqual([
      { address: 'A', value: { assets: asTokenMap([[asAssetId('0'), 500n]]), coins: 4_999_800n } },
      { address: 'A', value: { coins: 2_500_000n } },
      { address: 'A', value: { coins: 1_250_000n } },
      { address: 'A', value: { coins: 625_000n } },
      { address: 'A', value: { coins: 312_500n } },
      { address: 'A', value: { coins: 312_500n } }
    ]);

    assertInputSelectionProperties({
      constraints,
      implicitValue,
      outputs,
      results,
      utxo
    });
  });

  it('correctly distributes native assets when not all outputs can hold assets', async () => {
    const selector = new GreedyInputSelector({
      getChangeAddresses: async () =>
        new Map([
          [asPaymentAddress('X'), 1],
          [asPaymentAddress('Y'), 1]
        ])
    });

    const utxo = new Set([
      TxTestUtil.createUnspentTxOutput({
        assets: asTokenMap([
          [asAssetId('0'), 1500n],
          [asAssetId('2'), 1500n],
          [asAssetId('3'), 1500n],
          [asAssetId('4'), 1500n],
          [asAssetId('5'), 1500n],
          [asAssetId('6'), 1500n],
          [asAssetId('7'), 1500n],
          [asAssetId('8'), 1500n],
          [asAssetId('9'), 1500n],
          [asAssetId('10'), 1500n],
          [asAssetId('11'), 1500n],
          [asAssetId('12'), 1500n],
          [asAssetId('13'), 1500n],
          [asAssetId('14'), 1500n],
          [asAssetId('15'), 1500n]
        ]),
        coins: 7_500_000n
      }),
      TxTestUtil.createUnspentTxOutput({
        coins: 7_500_000n
      })
    ]);

    const preSelectedUtxo = new Set<Cardano.Utxo>();
    const outputs = new Set<Cardano.TxOut>();
    const implicitValue = {
      coin: { deposit: 4_000_000n }
    };
    const constraints = mockConstraintsToConstraints({
      ...MOCK_NO_CONSTRAINTS,
      minimumCoinQuantity: 500_000n
    });

    constraints.computeMinimumCoinQuantity = (output: Cardano.TxOut) =>
      BigInt(output.value.assets ? output.value.assets?.size : 1n) * 500_000n;

    const results = await selector.select({
      constraints,
      implicitValue,
      outputs,
      preSelectedUtxo,
      utxo
    });

    const {
      remainingUTxO,
      selection: { change, inputs }
    } = results;

    expect(inputs).toEqual(utxo);
    expect(remainingUTxO.size).toEqual(0);
    expect(getCoinValueForAddress('X', change)).toEqual(5_500_000n);
    expect(getCoinValueForAddress('Y', change)).toEqual(5_500_000n);

    expect(change).toEqual([
      {
        address: 'X',
        value: {
          assets: asTokenMap([
            [asAssetId('0'), 1500n],
            [asAssetId('9'), 1500n],
            [asAssetId('13'), 1500n]
          ]),
          coins: 2_750_000n
        }
      },
      {
        address: 'Y',
        value: {
          assets: asTokenMap([
            [asAssetId('2'), 1500n],
            [asAssetId('10'), 1500n],
            [asAssetId('14'), 1500n],
            [asAssetId('15'), 1500n]
          ]),
          coins: 2_750_000n
        }
      },
      {
        address: 'X',
        value: {
          assets: asTokenMap([
            [asAssetId('3'), 1500n],
            [asAssetId('11'), 1500n]
          ]),
          coins: 1_375_000n
        }
      },
      {
        address: 'Y',
        value: {
          assets: asTokenMap([
            [asAssetId('4'), 1500n],
            [asAssetId('12'), 1500n]
          ]),
          coins: 1_375_000n
        }
      },
      {
        address: 'Y',
        value: {
          assets: asTokenMap([[asAssetId('7'), 1500n]]),
          coins: 687_500n
        }
      },
      {
        address: 'X',
        value: {
          assets: asTokenMap([[asAssetId('5'), 1500n]]),
          coins: 687_500n
        }
      },
      {
        address: 'Y',
        value: {
          assets: asTokenMap([[asAssetId('8'), 1500n]]),
          coins: 687_500n
        }
      },
      {
        address: 'X',
        value: {
          assets: asTokenMap([[asAssetId('6'), 1500n]]),
          coins: 687_500n
        }
      }
    ]);

    assertInputSelectionProperties({
      constraints: {
        ...MOCK_NO_CONSTRAINTS,
        minimumCoinQuantity: 500_000n
      },
      implicitValue,
      outputs,
      results,
      utxo
    });
  });
});
