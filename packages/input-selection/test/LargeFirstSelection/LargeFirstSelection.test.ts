import { Cardano } from '@cardano-sdk/core';
import { LargeFirstSelector } from '../../src';
import { MOCK_NO_CONSTRAINTS, mockConstraintsToConstraints } from '../util/selectionConstraints';
import {
  MockChangeAddressResolver,
  asAssetId,
  asTokenMap,
  assertInputSelectionProperties,
  getCoinValueForAddress,
  mockChangeAddress
} from '../util';
import { TxTestUtil } from '@cardano-sdk/util-dev';

describe('LargeFirstSelection', () => {
  it('picks the largest ADA UTxOs first', async () => {
    const selector = new LargeFirstSelector({
      changeAddressResolver: new MockChangeAddressResolver()
    });

    const utxo = new Set([
      TxTestUtil.createUnspentTxOutput({ coins: 3_000_000n }),
      TxTestUtil.createUnspentTxOutput({ coins: 2_000_000n }),
      TxTestUtil.createUnspentTxOutput({ coins: 5_000_000n }),
      TxTestUtil.createUnspentTxOutput({ coins: 4_000_000n }),
      TxTestUtil.createUnspentTxOutput({ coins: 1_000_000n })
    ]);

    const outputs = new Set([TxTestUtil.createOutput({ coins: 6_000_000n })]);

    const constraints = mockConstraintsToConstraints({
      ...MOCK_NO_CONSTRAINTS,
      minimumCostCoefficient: 100n
    });

    const results = await selector.select({
      constraints,
      implicitValue: {},
      outputs,
      preSelectedUtxo: new Set(),
      utxo
    });

    const { selection, remainingUTxO } = results;

    expect(selection.inputs.size).toBe(2);
    expect(remainingUTxO.size).toBe(3);

    const inputValues = new Set([...selection.inputs.entries()].map(([[_, output]]) => output.value.coins));
    expect(inputValues.has(5_000_000n)).toBe(true);
    expect(inputValues.has(4_000_000n)).toBe(true);

    const expectedFee = BigInt(selection.inputs.size) * 100n;
    expect(selection.fee).toBe(expectedFee);

    expect(getCoinValueForAddress(mockChangeAddress, selection.change)).toBe(2_999_800n);

    assertInputSelectionProperties({
      constraints: {
        ...MOCK_NO_CONSTRAINTS,
        minimumCostCoefficient: 100n
      },
      implicitValue: {},
      outputs,
      results,
      utxo
    });
  });

  it('picks the largest ADA UTxOs first as change', async () => {
    const selector = new LargeFirstSelector({
      changeAddressResolver: new MockChangeAddressResolver()
    });

    const utxo = new Set([
      TxTestUtil.createUnspentTxOutput({ coins: 2_000_000n }),
      TxTestUtil.createUnspentTxOutput({ coins: 5_000_000n }),
      TxTestUtil.createUnspentTxOutput({ coins: 4_000_000n }),
      TxTestUtil.createUnspentTxOutput({ coins: 1_000_000n }),
      TxTestUtil.createUnspentTxOutput({ coins: 3_000_000n })
    ]);

    const outputs = new Set([TxTestUtil.createOutput({ coins: 9_000_000n })]);

    const constraints = mockConstraintsToConstraints({
      ...MOCK_NO_CONSTRAINTS,
      minimumCostCoefficient: 1n
    });

    const results = await selector.select({
      constraints,
      implicitValue: {},
      outputs,
      preSelectedUtxo: new Set(),
      utxo
    });

    const { selection, remainingUTxO } = results;

    expect(selection.inputs.size).toBe(3);
    expect(remainingUTxO.size).toBe(2);

    const inputValues = new Set([...selection.inputs.entries()].map(([[_, output]]) => output.value.coins));
    expect(inputValues.has(5_000_000n)).toBe(true);
    expect(inputValues.has(4_000_000n)).toBe(true);

    const expectedFee = BigInt(selection.inputs.size);
    expect(selection.fee).toBe(expectedFee);

    expect(getCoinValueForAddress(mockChangeAddress, selection.change)).toBe(2_999_997n);

    assertInputSelectionProperties({
      constraints: {
        ...MOCK_NO_CONSTRAINTS,
        minimumCostCoefficient: 100n
      },
      implicitValue: {},
      outputs,
      results,
      utxo
    });
  });

  it('picks the largest native asset UTxOs first', async () => {
    const selector = new LargeFirstSelector({
      changeAddressResolver: new MockChangeAddressResolver()
    });

    const assetX = asAssetId('X');

    const utxo = new Set([
      TxTestUtil.createUnspentTxOutput({
        assets: asTokenMap([[assetX, 20n]]),
        coins: 3_000_000n
      }),
      TxTestUtil.createUnspentTxOutput({
        assets: asTokenMap([[assetX, 80n]]),
        coins: 3_000_000n
      }),
      TxTestUtil.createUnspentTxOutput({
        assets: asTokenMap([[assetX, 50n]]),
        coins: 3_000_000n
      }),
      TxTestUtil.createUnspentTxOutput({
        assets: asTokenMap([[assetX, 100n]]),
        coins: 3_000_000n
      }),
      TxTestUtil.createUnspentTxOutput({ coins: 3_000_000n })
    ]);

    const outputs = new Set([
      TxTestUtil.createOutput({
        assets: asTokenMap([[assetX, 130n]]),
        coins: 2_000_000n
      })
    ]);

    const constraints = mockConstraintsToConstraints({
      ...MOCK_NO_CONSTRAINTS,
      minimumCostCoefficient: 100n
    });

    const results = await selector.select({
      constraints,
      implicitValue: {},
      outputs,
      preSelectedUtxo: new Set(),
      utxo
    });

    const { selection, remainingUTxO } = results;

    expect(selection.inputs.size).toBe(2);
    const coinsPicked = new Set([...selection.inputs].map(([, o]) => o.value.assets?.get(assetX) ?? 0n));
    expect(coinsPicked.has(100n)).toBe(true);
    expect(coinsPicked.has(80n)).toBe(true);
    expect(remainingUTxO.size).toBe(3);

    const expectedFee = BigInt(selection.inputs.size) * 100n;
    expect(selection.fee).toBe(expectedFee);

    expect(selection.change.some((txOut) => txOut.value.assets?.get(assetX) === 50n)).toBe(true);

    assertInputSelectionProperties({
      constraints: {
        ...MOCK_NO_CONSTRAINTS,
        minimumCostCoefficient: 100n
      },
      implicitValue: {},
      outputs,
      results,
      utxo
    });
  });

  it('consumes just enough ADA UTxOs needed and leaves the remainder', async () => {
    const selector = new LargeFirstSelector({
      changeAddressResolver: new MockChangeAddressResolver()
    });

    const utxo = new Set([
      TxTestUtil.createUnspentTxOutput({ coins: 3_000_000n }),
      TxTestUtil.createUnspentTxOutput({ coins: 3_000_000n }),
      TxTestUtil.createUnspentTxOutput({ coins: 3_000_000n }),
      TxTestUtil.createUnspentTxOutput({ coins: 3_000_000n }),
      TxTestUtil.createUnspentTxOutput({ coins: 3_000_000n })
    ]);
    const outputs = new Set([TxTestUtil.createOutput({ coins: 5_000_000n })]);

    const constraints = mockConstraintsToConstraints({
      ...MOCK_NO_CONSTRAINTS,
      minimumCostCoefficient: 100n
    });

    const results = await selector.select({
      constraints,
      implicitValue: {},
      outputs,
      preSelectedUtxo: new Set(),
      utxo
    });

    const { selection, remainingUTxO } = results;

    expect(selection.inputs.size).toBe(2);
    expect(remainingUTxO.size).toBe(3);

    const expectedFee = BigInt(selection.inputs.size) * 100n;
    expect(selection.fee).toBe(expectedFee);

    expect(getCoinValueForAddress(mockChangeAddress, selection.change)).toBe(999_800n);

    assertInputSelectionProperties({
      constraints: {
        ...MOCK_NO_CONSTRAINTS,
        minimumCostCoefficient: 100n
      },
      implicitValue: {},
      outputs,
      results,
      utxo
    });
  });

  it('picks the single largest UTxO for each required asset', async () => {
    const selector = new LargeFirstSelector({
      changeAddressResolver: new MockChangeAddressResolver()
    });

    const utxo = new Set([
      TxTestUtil.createUnspentTxOutput({
        assets: asTokenMap([[asAssetId('0'), 100n]]),
        coins: 3_000_000n
      }),
      TxTestUtil.createUnspentTxOutput({
        assets: asTokenMap([[asAssetId('0'), 50n]]),
        coins: 3_000_000n
      }),
      TxTestUtil.createUnspentTxOutput({
        assets: asTokenMap([[asAssetId('1'), 8n]]),
        coins: 4_000_000n
      }),
      TxTestUtil.createUnspentTxOutput({ coins: 4_000_000n })
    ]);

    // Need 90 of asset-0 and 5 of asset-1, plus 2000000 Ada
    const outputs = new Set([
      TxTestUtil.createOutput({
        assets: asTokenMap([
          [asAssetId('0'), 90n],
          [asAssetId('1'), 5n]
        ]),
        coins: 2_000_000n
      })
    ]);

    const constraints = mockConstraintsToConstraints({
      ...MOCK_NO_CONSTRAINTS,
      minimumCostCoefficient: 100n
    });

    const results = await selector.select({
      constraints,
      implicitValue: {},
      outputs,
      preSelectedUtxo: new Set(),
      utxo
    });

    expect(results.selection.inputs.has([...utxo][0])).toBe(true); // 100-token-0
    expect(results.selection.inputs.has([...utxo][2])).toBe(true); //   8-token-1
    expect(results.remainingUTxO.has([...utxo][1])).toBe(true);

    assertInputSelectionProperties({
      constraints: {
        ...MOCK_NO_CONSTRAINTS,
        minimumCostCoefficient: 100n
      },
      implicitValue: {},
      outputs,
      results,
      utxo
    });
  });

  it('accounts for implicit deposits, withdrawals, and mint', async () => {
    const selector = new LargeFirstSelector({
      changeAddressResolver: new MockChangeAddressResolver()
    });

    const utxo = new Set([
      TxTestUtil.createUnspentTxOutput({ coins: 3_000_000n }),
      TxTestUtil.createUnspentTxOutput({ coins: 3_000_000n })
    ]);

    const outputs = new Set<Cardano.TxOut>();

    const implicitValue = {
      coin: { deposit: 1_000_000n, input: 5_000_000n },
      mint: asTokenMap([[asAssetId('XYZ'), 2n]])
    };

    const constraints = mockConstraintsToConstraints({
      ...MOCK_NO_CONSTRAINTS,
      minimumCostCoefficient: 100n
    });

    const { selection, remainingUTxO } = await selector.select({
      constraints,
      implicitValue,
      outputs,
      preSelectedUtxo: new Set(),
      utxo
    });

    const expectedFee = BigInt(selection.inputs.size) * 100n;
    expect(selection.fee).toBe(expectedFee);
    expect(getCoinValueForAddress(mockChangeAddress, selection.change)).toBe(6_999_900n);
    expect(selection.change[0].value.assets?.get(asAssetId('XYZ'))).toBe(2n);

    expect(remainingUTxO.size).toBe(1);
  });
});
