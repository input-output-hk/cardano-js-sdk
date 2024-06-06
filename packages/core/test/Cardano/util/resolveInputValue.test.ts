import { Cardano } from '../../../src/index.js';

describe('Cardano.util.resolveInputValue', () => {
  const txs: Cardano.HydratedTx[] = [
    {
      body: {
        outputs: [{ value: { coins: 5_000_000n } }, { value: { coins: 1_000_000n } }, { value: { coins: 9_825_963n } }]
      },
      id: Cardano.TransactionId('12fa9af65e21b36ec4dc4cbce478e911d52585adb46f2b4fe3d6563e7ee5a61a')
    } as Cardano.HydratedTx,
    {
      body: { outputs: [{ value: { coins: 3_000_000n } }] },
      id: Cardano.TransactionId('6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99cad')
    } as Cardano.HydratedTx
  ];
  it('should resolve the value for the input from the list of transactions', () => {
    const input1 = {
      index: 1,
      txId: Cardano.TransactionId('12fa9af65e21b36ec4dc4cbce478e911d52585adb46f2b4fe3d6563e7ee5a61a')
    } as Cardano.HydratedTxIn;
    const input2 = {
      index: 0,
      txId: Cardano.TransactionId('6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99cad')
    } as Cardano.HydratedTxIn;
    expect(Cardano.util.resolveInputValue(input1, txs)).toEqual({ coins: 1_000_000n });
    expect(Cardano.util.resolveInputValue(input2, txs)).toEqual({ coins: 3_000_000n });
  });
  it('should return undefined if there was no tx with the same id as the input', () => {
    const input = {
      index: 0,
      txId: Cardano.TransactionId('01d7366549986d83edeea262e97b68eca3430d3bb052ed1c37d2202fd5458872')
    } as Cardano.HydratedTxIn;
    expect(Cardano.util.resolveInputValue(input, txs)).toEqual(undefined);
  });
  it('should return undefined if the input could match the transaction but not the output index', () => {
    const input = {
      index: 4,
      txId: Cardano.TransactionId('12fa9af65e21b36ec4dc4cbce478e911d52585adb46f2b4fe3d6563e7ee5a61a')
    } as Cardano.HydratedTxIn;
    expect(Cardano.util.resolveInputValue(input, txs)).toEqual(undefined);
  });
});
