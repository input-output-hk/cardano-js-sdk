import { Asset, CSL, Cardano, coreToCsl } from '../../src';

const txIn: Cardano.TxIn = {
  txId: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5',
  index: 0,
  address:
    'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
};
const txOut: Cardano.TxOut = {
  address:
    'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp',
  value: {
    coins: 10n,
    assets: {
      '2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740': 20n,
      '659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba8254534c41': 50n
    }
  }
};

describe('coreToCsl', () => {
  it('txIn', () => {
    expect(coreToCsl.txIn(txIn)).toBeInstanceOf(CSL.TransactionInput);
  });
  it('txOut', () => {
    expect(coreToCsl.txOut(txOut)).toBeInstanceOf(CSL.TransactionOutput);
  });
  it('utxo', () => {
    expect(coreToCsl.utxo([[txIn, txOut]])[0]).toBeInstanceOf(CSL.TransactionUnspentOutput);
  });
  describe('value', () => {
    it('coin only', () => {
      const quantities = { coins: 100_000n };
      const value = coreToCsl.value(quantities);
      expect(value.coin().to_str()).toEqual(quantities.coins.toString());
      expect(value.multiasset()).toBeUndefined();
    });
    it('coin with assets', () => {
      const value = coreToCsl.value(txOut.value);
      expect(value.coin().to_str()).toEqual(txOut.value.coins.toString());
      const multiasset = value.multiasset()!;
      expect(multiasset.len()).toBe(2);
      for (const assetId in txOut.value.assets) {
        const { scriptHash, assetName } = Asset.util.parseAssetId(assetId);
        const assetQuantity = BigInt(multiasset.get(scriptHash)!.get(assetName)!.to_str());
        expect(assetQuantity).toBe(txOut.value.assets[assetId]);
      }
      expect(value).toBeInstanceOf(CSL.Value);
    });
  });
});
