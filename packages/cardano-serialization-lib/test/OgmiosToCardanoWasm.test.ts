import CardanoWasm from '@emurgo/cardano-serialization-lib-nodejs';
import { OgmiosToCardanoWasm } from '@src/OgmiosToCardanoWasm';
import * as OgmiosSchema from '@cardano-ogmios/schema';

const txIn: OgmiosSchema.TxIn = { txId: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5', index: 0 };
const txOut: OgmiosSchema.TxOut = {
  address:
    'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp',
  value: { coins: 10, assets: { '2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740': 20n } }
};

describe('OgmiosToCardanoWasm', () => {
  test('txIn', () => {
    expect(OgmiosToCardanoWasm.txIn(txIn)).toBeInstanceOf(CardanoWasm.TransactionInput);
  });
  test('txOut', () => {
    expect(OgmiosToCardanoWasm.txOut(txOut)).toBeInstanceOf(CardanoWasm.TransactionOutput);
  });
  test('utxo', () => {
    expect(OgmiosToCardanoWasm.utxo([[txIn, txOut]])[0]).toBeInstanceOf(CardanoWasm.TransactionUnspentOutput);
  });
  test('value', () => {
    expect(OgmiosToCardanoWasm.value(txOut.value)).toBeInstanceOf(CardanoWasm.Value);
  });
});
