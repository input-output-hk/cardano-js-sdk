/* eslint-disable max-len */
import { Asset, CSL, Cardano, SerializationFailure, coreToCsl } from '../../src';
import { BigNum } from '@emurgo/cardano-serialization-lib-nodejs';
import { signature, tx, txBody, txIn, txOut, valueCoinOnly, valueWithAssets, vkey } from './testData';

const txOutByron = {
  ...txOut,
  address: Cardano.Address(
    'DdzFFzCqrhsw3prhfMFDNFowbzUku3QmrMwarfjUbWXRisodn97R436SHc1rimp4MhPNmbdYb1aTdqtGSJixMVMi5MkArDQJ6Sc1n3Ez'
  )
};

describe('coreToCsl', () => {
  it('txIn', () => {
    expect(coreToCsl.txIn(txIn)).toBeInstanceOf(CSL.TransactionInput);
  });
  it('txOut', () => {
    expect(coreToCsl.txOut(txOut)).toBeInstanceOf(CSL.TransactionOutput);
    expect(coreToCsl.txOut(txOutByron)).toBeInstanceOf(CSL.TransactionOutput);
  });
  it('utxo', () => {
    expect(coreToCsl.utxo([[txIn, txOut]])[0]).toBeInstanceOf(CSL.TransactionUnspentOutput);
  });
  describe('value', () => {
    it('coin only', () => {
      const value = coreToCsl.value(valueCoinOnly);
      expect(value.coin().to_str()).toEqual(valueCoinOnly.coins.toString());
      expect(value.multiasset()).toBeUndefined();
    });
    it('coin with assets', () => {
      const value = coreToCsl.value(valueWithAssets);
      expect(value.coin().to_str()).toEqual(valueWithAssets.coins.toString());
      const multiasset = value.multiasset()!;
      expect(multiasset.len()).toBe(2);
      for (const [assetId, expectedAssetQuantity] of valueWithAssets.assets!.entries()) {
        const { scriptHash, assetName } = Asset.util.parseAssetId(assetId);
        const assetQuantity = BigInt(multiasset.get(scriptHash)!.get(assetName)!.to_str());
        expect(assetQuantity).toBe(expectedAssetQuantity);
      }
      expect(value).toBeInstanceOf(CSL.Value);
    });
  });
  it('tokenMap', () => {
    const multiasset = coreToCsl.tokenMap(txOut.value.assets!);
    expect(multiasset).toBeInstanceOf(CSL.MultiAsset);
    expect(multiasset.len()).toBe(2);
    for (const [assetId, expectedAssetQuantity] of txOut.value.assets!.entries()) {
      const { scriptHash, assetName } = Asset.util.parseAssetId(assetId);
      const assetQuantity = BigInt(multiasset.get(scriptHash)!.get(assetName)!.to_str());
      expect(assetQuantity).toBe(expectedAssetQuantity);
    }
  });
  it('txBody', () => {
    const cslBody = coreToCsl.txBody(txBody);
    expect(cslBody.certs()?.get(0).as_pool_retirement()?.epoch()).toBe(500);
    expect(cslBody.fee().to_str()).toBe(txBody.fee.toString());
    expect(Buffer.from(cslBody.inputs().get(0).transaction_id().to_bytes()).toString('hex')).toBe(
      txBody.inputs[0].txId
    );
    expect(cslBody.outputs().get(0).amount().coin().to_str()).toBe(txBody.outputs[0].value.coins.toString());
    expect(cslBody.validity_start_interval()).toBe(txBody.validityInterval.invalidBefore);
    expect(cslBody.ttl()).toBe(txBody.validityInterval.invalidHereafter);
    expect(cslBody.withdrawals()?.get(cslBody.withdrawals()!.keys().get(0)!)?.to_str()).toBe(
      txBody.withdrawals![0].quantity.toString()
    );

    const mint = cslBody.multiassets()!;
    const scriptHashes = mint.keys();
    const mintAssets1 = mint.get(scriptHashes.get(0))!;
    const mintAssets2 = mint.get(scriptHashes.get(1))!;
    expect(mintAssets1.get(mintAssets1.keys().get(0))!.as_positive()!.to_str()).toBe('20');
    expect(mintAssets2.get(mintAssets2.keys().get(0))!.as_negative()!.to_str()).toBe('50');

    expect(cslBody.collateral()!.len()).toBe(1);
    expect(cslBody.required_signers()!.len()).toBe(1);
    expect(cslBody.script_data_hash()).toBeTruthy();
  });
  it('tx', () => {
    const cslTx = coreToCsl.tx(tx);
    expect(cslTx.body()).toBeInstanceOf(CSL.TransactionBody);
    const witness = cslTx.witness_set().vkeys()!.get(0)!;
    expect(Buffer.from(witness.vkey().public_key().as_bytes()).toString('hex')).toBe(vkey);
    expect(witness.signature().to_hex()).toBe(signature);
  });
  describe('txAuxiliaryData', () => {
    it('returns undefined for undefined data', () => expect(coreToCsl.txAuxiliaryData()).toBeUndefined());

    describe('txMetadata', () => {
      // eslint-disable-next-line unicorn/consistent-function-scoping, @typescript-eslint/no-explicit-any
      const convertMetadatum = (metadatum: any) => {
        const label = 123n;
        const auxiliaryData = coreToCsl.txAuxiliaryData({ body: { blob: new Map([[label, metadatum]]) } });
        return auxiliaryData?.metadata()?.get(BigNum.from_str(label.toString()));
      };

      const str64Len = 'looooooooooooooooooooooooooooooooooooooooooooooooooooooooooogstr';
      const str65Len = 'loooooooooooooooooooooooooooooooooooooooooooooooooooooooooooogstr';

      it('converts number', () => {
        const number = 1234n;
        const metadatum = convertMetadatum(number);
        expect(metadatum?.as_int().as_positive()?.to_str()).toBe(number.toString());
      });

      it('converts text', () => {
        const str = str64Len;
        const metadatum = convertMetadatum(str);
        expect(metadatum?.as_text()).toBe(str);
      });

      it('converts list', () => {
        const list = [str64Len, 'str2'];
        const metadatum = convertMetadatum(list);
        const cslList = metadatum?.as_list();
        expect(cslList?.len()).toBe(list.length);
        expect(cslList?.get(0).as_text()).toBe(list[0]);
        expect(cslList?.get(1).as_text()).toBe(list[1]);
      });

      test('converts bytes', () => {
        const bytes = Buffer.from(str64Len);
        const metadatum = convertMetadatum(bytes);
        expect(metadatum?.as_bytes().buffer).toEqual(bytes.buffer);
      });

      it('converts map', () => {
        const key = new Map<Cardano.Metadatum, Cardano.Metadatum>([[567n, 'eight']]);
        const map = new Map<Cardano.Metadatum, Cardano.Metadatum>([
          [123n, 1234n],
          ['key', 'value'],
          [key, new Map<Cardano.Metadatum, Cardano.Metadatum>([[666n, 'cake']])]
        ]);
        const metadatum = convertMetadatum(map);
        const cslMap = metadatum?.as_map();
        expect(cslMap?.len()).toBe(map.size);
        expect(cslMap?.get(convertMetadatum(123n)!).as_int().as_positive()?.to_str()).toBe('1234');
        expect(cslMap?.get(convertMetadatum('key')!).as_text()).toBe('value');
        expect(cslMap?.get(convertMetadatum(key)!).as_map().get_i32(666).as_text()).toBe('cake');
      });

      test('bytes too long throws error', () => {
        const bytes = Buffer.from(str65Len, 'utf8');
        expect(() => convertMetadatum(bytes)).toThrow(SerializationFailure.MaxLengthLimit);
      });

      it('text too long throws error', () => {
        expect(() => convertMetadatum(str65Len)).toThrow(SerializationFailure.MaxLengthLimit);
      });

      it('bool throws error', () => {
        expect(() => convertMetadatum(true)).toThrowError(SerializationFailure.InvalidType);
      });

      it('undefined throws error', () => {
        // eslint-disable-next-line unicorn/no-useless-undefined
        expect(() => convertMetadatum(undefined)).toThrowError(SerializationFailure.InvalidType);
      });

      it('null throws error', () => {
        expect(() => convertMetadatum(null)).toThrowError(SerializationFailure.InvalidType);
      });
    });

    it.todo('txScripts');
  });
});
