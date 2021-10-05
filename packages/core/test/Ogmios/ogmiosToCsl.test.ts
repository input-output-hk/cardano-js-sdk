import { CardanoSerializationLib, loadCardanoSerializationLib } from '../../src/CSL';
import { OgmiosToCsl, ogmiosToCsl } from '../../src/Ogmios';
import * as OgmiosSchema from '@cardano-ogmios/schema';
import { Asset } from '../../src';

const txIn: OgmiosSchema.TxIn = { txId: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5', index: 0 };
const txOut: OgmiosSchema.TxOut = {
  address:
    'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp',
  value: {
    coins: 10,
    assets: {
      '2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740': 20n,
      '659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba8254534c41': 50n
    }
  }
};

describe('ogmiosToCsl', () => {
  let csl: CardanoSerializationLib;
  let otc: OgmiosToCsl;
  beforeAll(async () => {
    csl = await loadCardanoSerializationLib();
    otc = ogmiosToCsl(csl);
  });
  it('txIn', () => {
    expect(otc.txIn(txIn)).toBeInstanceOf(csl.TransactionInput);
  });
  it('txOut', () => {
    expect(otc.txOut(txOut)).toBeInstanceOf(csl.TransactionOutput);
  });
  it('utxo', () => {
    expect(otc.utxo([[txIn, txOut]])[0]).toBeInstanceOf(csl.TransactionUnspentOutput);
  });
  describe('value', () => {
    it('coin only', () => {
      const quantities = { coins: 100_000n };
      const value = otc.value(quantities);
      expect(value.coin().to_str()).toEqual(quantities.coins.toString());
      expect(value.multiasset()).toBeUndefined();
    });
    it('coin with assets', () => {
      const value = otc.value(txOut.value);
      expect(value.coin().to_str()).toEqual(txOut.value.coins.toString());
      const multiasset = value.multiasset()!;
      expect(multiasset.len()).toBe(2);
      for (const assetId in txOut.value.assets) {
        const { scriptHash, assetName } = Asset.util.parseAssetId(assetId, csl);
        const assetQuantity = BigInt(multiasset.get(scriptHash)!.get(assetName)!.to_str());
        expect(assetQuantity).toBe(txOut.value.assets[assetId]);
      }
      expect(value).toBeInstanceOf(csl.Value);
    });
  });
});
