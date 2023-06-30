import { Cardano } from '@cardano-sdk/core';
import { GreedyInputSelector } from '../../src';
import { MOCK_NO_CONSTRAINTS, mockConstraintsToConstraints } from '../util/selectionConstraints';
import { TxTestUtil } from '@cardano-sdk/util-dev';
import { asAssetId, asPaymentAddress, asTokenMap, assertInputSelectionProperties } from '../util';

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
      utxo
    });

    const {
      remainingUTxO,
      selection: { change, fee, inputs }
    } = results;

    expect(inputs).toEqual(utxo);
    expect(remainingUTxO.size).toEqual(0);
    expect(fee).toEqual(expectedFee);
    expect(change.length).toEqual(3);
    expect(change[0].address).toEqual(asPaymentAddress('A'));
    expect(change[0].value.coins).toEqual(3_333_334n - expectedFee);
    expect(change[1].address).toEqual(asPaymentAddress('B'));
    expect(change[1].value.coins).toEqual(3_333_334n);
    expect(change[2].address).toEqual(asPaymentAddress('C'));
    expect(change[2].value.coins).toEqual(3_333_332n);

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
      utxo
    });

    const {
      remainingUTxO,
      selection: { change, fee, inputs }
    } = results;

    expect(inputs).toEqual(utxo);
    expect(remainingUTxO.size).toEqual(0);
    expect(fee).toEqual(expectedFee);
    expect(change.length).toEqual(5);
    expect(change[0].address).toEqual(asPaymentAddress('A'));
    expect(change[0].value.coins).toEqual(3_000_000n - expectedFee);
    expect(change[1].address).toEqual(asPaymentAddress('B'));
    expect(change[1].value.coins).toEqual(3_000_000n);
    expect(change[2].address).toEqual(asPaymentAddress('C'));
    expect(change[2].value.coins).toEqual(3_000_000n);
    expect(change[3].address).toEqual(asPaymentAddress('D'));
    expect(change[3].value.coins).toEqual(3_000_000n);
    expect(change[4].address).toEqual(asPaymentAddress('E'));
    expect(change[4].value.coins).toEqual(3_000_000n);

    assertInputSelectionProperties({
      constraints,
      implicitValue,
      outputs,
      results,
      utxo
    });
  });

  it('allocates native assets to the biggest output (before fees)', async () => {
    const selector = new GreedyInputSelector({
      getChangeAddresses: async () =>
        new Map([
          [asPaymentAddress('A'), 1],
          [asPaymentAddress('B'), 1],
          [asPaymentAddress('C'), 1],
          [asPaymentAddress('D'), 1]
        ])
    });

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
      utxo
    });

    const {
      remainingUTxO,
      selection: { change, fee, inputs }
    } = results;

    expect(inputs).toEqual(utxo);
    expect(remainingUTxO.size).toEqual(0);
    expect(fee).toEqual(expectedFee);
    expect(change.length).toEqual(4);
    expect(change[0].address).toEqual(asPaymentAddress('A'));
    expect(change[0].value.coins).toEqual(4_250_000n - expectedFee);
    expect(change[0].value.assets).toEqual(
      asTokenMap([
        [asAssetId('0'), 100n],
        [asAssetId('1'), 23n],
        [asAssetId('2'), 1n],
        [asAssetId('3'), 1000n],
        [asAssetId('4'), 1500n],
        [asAssetId('5'), 500n]
      ])
    );
    expect(change[1].address).toEqual(asPaymentAddress('B'));
    expect(change[1].value.coins).toEqual(4_250_000n);
    expect(change[1].value.assets).toBeUndefined();
    expect(change[2].address).toEqual(asPaymentAddress('C'));
    expect(change[2].value.coins).toEqual(4_250_000n);
    expect(change[2].value.assets).toBeUndefined();
    expect(change[3].address).toEqual(asPaymentAddress('D'));
    expect(change[3].value.coins).toEqual(4_250_000n);
    expect(change[2].value.assets).toBeUndefined();

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
      maxTokenBundleSize: 2,
      minimumCostCoefficient: 100n
    };

    const results = await selector.select({
      constraints: mockConstraintsToConstraints(constraints),
      implicitValue,
      outputs,
      utxo
    });

    const {
      remainingUTxO,
      selection: { change, fee, inputs }
    } = results;

    expect(inputs).toEqual(utxo);
    expect(remainingUTxO.size).toEqual(0);
    expect(fee).toEqual(expectedFee);
    expect(change.length).toEqual(3);
    expect(change[0].address).toEqual(asPaymentAddress('A'));
    expect(change[0].value.coins).toEqual(8_500_000n - expectedFee);
    expect(change[0].value.assets).toEqual(
      asTokenMap([
        [asAssetId('4'), 1500n],
        [asAssetId('5'), 500n]
      ])
    );
    expect(change[1].address).toEqual(asPaymentAddress('B'));
    expect(change[1].value.coins).toEqual(4_250_000n);
    expect(change[1].value.assets).toEqual(
      asTokenMap([
        [asAssetId('2'), 1n],
        [asAssetId('3'), 1000n]
      ])
    );
    expect(change[2].address).toEqual(asPaymentAddress('C'));
    expect(change[2].value.coins).toEqual(4_250_000n);
    expect(change[2].value.assets).toEqual(
      asTokenMap([
        [asAssetId('0'), 100n],
        [asAssetId('1'), 23n]
      ])
    );

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
      getChangeAddresses: async () =>
        new Map([
          [asPaymentAddress('A'), 1],
          [asPaymentAddress('B'), 1]
        ])
    });

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
      utxo
    });

    const {
      remainingUTxO,
      selection: { change, fee, inputs }
    } = results;

    expect(inputs).toEqual(utxo);
    expect(remainingUTxO.size).toEqual(0);
    expect(fee).toEqual(expectedFee);
    expect(change.length).toEqual(2);
    expect(change[0].address).toEqual(asPaymentAddress('A'));
    expect(change[0].value.coins).toEqual(4_000_000n - expectedFee);
    expect(change[1].address).toEqual(asPaymentAddress('B'));
    expect(change[1].value.coins).toEqual(4_000_000n);

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
      utxo
    });

    const {
      remainingUTxO,
      selection: { change, fee, inputs }
    } = results;

    expect(inputs).toEqual(utxo);
    expect(remainingUTxO.size).toEqual(0);
    expect(fee).toEqual(expectedFee);
    expect(change.length).toEqual(1);
    expect(change[0].address).toEqual(asPaymentAddress('A'));
    expect(change[0].value.coins).toEqual(10_000_000n - expectedFee);
    expect(change[0].value.assets).toEqual(asTokenMap([[asAssetId('0'), 1n]]));

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
      utxo
    });

    const {
      remainingUTxO,
      selection: { change, fee, inputs }
    } = results;

    expect(inputs).toEqual(utxo);
    expect(remainingUTxO.size).toEqual(0);
    expect(fee).toEqual(expectedFee);
    expect(change.length).toEqual(1);
    expect(change[0].address).toEqual(asPaymentAddress('A'));
    expect(change[0].value.coins).toEqual(10_000_000n - expectedFee);
    expect(change[0].value.assets).toEqual(asTokenMap([[asAssetId('0'), 500n]]));

    assertInputSelectionProperties({
      constraints,
      implicitValue,
      outputs,
      results,
      utxo
    });
  });
});
