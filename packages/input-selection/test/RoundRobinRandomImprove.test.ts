import { MockChangeAddressResolver, SelectionConstraints } from './util/index.js';
import { TxTestUtil } from '@cardano-sdk/util-dev';
import { roundRobinRandomImprove } from '../src/RoundRobinRandomImprove/index.js';
import type { Cardano } from '@cardano-sdk/core';

describe('RoundRobinRandomImprove', () => {
  it('Recomputes fee after selecting an extra utxo due to change not meeting minimumCoinQuantity', async () => {
    const utxo = new Set([
      TxTestUtil.createUnspentTxOutput({ coins: 1_000_000n }),
      TxTestUtil.createUnspentTxOutput({ coins: 1_000_000n }),
      TxTestUtil.createUnspentTxOutput({ coins: 1_000_000n }),
      TxTestUtil.createUnspentTxOutput({ coins: 975_000_000n })
    ]);
    const outputs = new Set([TxTestUtil.createOutput({ coins: 1_000_000n })]);

    /**
     * Round robin:
     * 1. selects 1 coin
     * 2. attempts to select 975 which does not improve selection: only (1) is returned.
     *
     * Change algorithm:
     * 1. selects an extra 1 coin utxo due to fee (total 1.2 coin required by output+fee)
     * 2. selects an extra 1 coin utxo due to change value not meeting minimumCoinQuantity: 1+1-1.2=0.8
     */
    const random = jest.fn().mockReturnValue(0).mockReturnValueOnce(0).mockReturnValueOnce(0.99);

    const preSelectedUtxo = new Set<Cardano.Utxo>();
    const results = await roundRobinRandomImprove({
      changeAddressResolver: new MockChangeAddressResolver(),
      random
    }).select({
      constraints: SelectionConstraints.mockConstraintsToConstraints({
        ...SelectionConstraints.MOCK_NO_CONSTRAINTS,
        minimumCoinQuantity: 900_000n,
        minimumCostCoefficient: 200_000n
      }),
      outputs,
      preSelectedUtxo,
      utxo
    });
    expect(results.selection.inputs.size).toBe(3);
    expect(results.selection.fee).toBe(600_000n);
  });

  it('Always select the preSelected input', async () => {
    const utxo = new Set([
      TxTestUtil.createUnspentTxOutput({ coins: 1_000_000n }),
      TxTestUtil.createUnspentTxOutput({ coins: 1_000_000n }),
      TxTestUtil.createUnspentTxOutput({ coins: 1_000_000n })
    ]);

    const mockForeignInput = TxTestUtil.createUnspentTxOutput({ coins: 2_000_111n });
    const preSelectedUtxo = new Set([mockForeignInput]);
    const outputs = new Set([TxTestUtil.createOutput({ coins: 1_000_000n })]);
    const random = jest.fn().mockReturnValue(0).mockReturnValueOnce(0).mockReturnValueOnce(0.99);

    const results = await roundRobinRandomImprove({
      changeAddressResolver: new MockChangeAddressResolver(),
      random
    }).select({
      constraints: SelectionConstraints.mockConstraintsToConstraints({
        ...SelectionConstraints.MOCK_NO_CONSTRAINTS,
        minimumCoinQuantity: 900_000n,
        minimumCostCoefficient: 200_000n
      }),
      outputs,
      preSelectedUtxo,
      utxo
    });
    expect(results.selection.inputs.size).toBe(2);
    expect(results.selection.fee).toBe(400_000n);
    expect(
      [...results.selection.inputs.values()].some(
        (value) =>
          value[0].txId === mockForeignInput[0].txId &&
          value[0].index === mockForeignInput[0].index &&
          value[1].value.coins === mockForeignInput[1].value.coins
      )
    ).toBeTruthy();
  });
});
