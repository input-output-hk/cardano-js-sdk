import { Cardano } from '@cardano-sdk/core';
import { SelectionConstraints } from './util';
import { TxTestUtil } from '@cardano-sdk/util-dev';
import { roundRobinRandomImprove } from '../src/RoundRobinRandomImprove';

const changeAddress =
  'addr_test1qqydn46r6mhge0kfpqmt36m6q43knzsd9ga32n96m89px3nuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qypp3m9' as Cardano.PaymentAddress;

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

    const results = await roundRobinRandomImprove({ getChangeAddress: async () => changeAddress, random }).select({
      constraints: SelectionConstraints.mockConstraintsToConstraints({
        ...SelectionConstraints.MOCK_NO_CONSTRAINTS,
        minimumCoinQuantity: 900_000n,
        minimumCostCoefficient: 200_000n
      }),
      outputs,
      utxo
    });
    expect(results.selection.inputs.size).toBe(3);
    expect(results.selection.fee).toBe(600_000n);
  });
});
