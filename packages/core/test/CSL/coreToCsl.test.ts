/* eslint-disable max-len */
import { Asset, CSL, Cardano, SerializationFailure, coreToCsl } from '../../src';
import { BigNum } from '@emurgo/cardano-serialization-lib-nodejs';
import { Ed25519KeyHash, NativeScript, NativeScriptKind, ScriptType } from '../../src/Cardano';
import {
  signature,
  tx,
  txBody,
  txIn,
  txInWithAddress,
  txOut,
  txOutWithDatum,
  valueCoinOnly,
  valueWithAssets,
  vkey
} from './testData';

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
  describe('txOut', () => {
    it('converts to CSL.TransactionOutput', () => {
      expect(coreToCsl.txOut(txOut)).toBeInstanceOf(CSL.TransactionOutput);
      expect(coreToCsl.txOut(txOutByron)).toBeInstanceOf(CSL.TransactionOutput);
    });
    it('converts datum to CSL.DataHash', () => {
      const cslTxOut = coreToCsl.txOut(txOutWithDatum);
      expect(cslTxOut.data_hash()).toBeInstanceOf(CSL.DataHash);
      expect(Buffer.from(cslTxOut.data_hash()!.to_bytes()).toString('hex')).toBe(txOutWithDatum.datum?.toString());
    });
  });
  it('utxo', () => {
    expect(coreToCsl.utxo([[txInWithAddress, txOut]])[0]).toBeInstanceOf(CSL.TransactionUnspentOutput);
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
      expect(multiasset.len()).toBe(3);
      for (const [assetId, expectedAssetQuantity] of valueWithAssets.assets!.entries()) {
        const { scriptHash, assetName } = Asset.util.parseAssetId(assetId);
        const assetQuantity = BigInt(multiasset.get(scriptHash)!.get(assetName)!.to_str());
        expect(assetQuantity).toBe(expectedAssetQuantity);
      }
      expect(value).toBeInstanceOf(CSL.Value);
    });
  });
  describe('tokenMap', () => {
    it('inserts a single multiasset per asset policy', () => {
      const multiasset = coreToCsl.tokenMap(txOut.value.assets!);
      expect(multiasset).toBeInstanceOf(CSL.MultiAsset);
      const scriptHashes = multiasset.keys();
      expect(scriptHashes.len()).toBe(3);
      for (const [assetId, expectedAssetQuantity] of txOut.value.assets!.entries()) {
        const { scriptHash, assetName } = Asset.util.parseAssetId(assetId);
        const assetQuantity = BigInt(multiasset.get(scriptHash)!.get(assetName)!.to_str());
        expect(assetQuantity).toBe(expectedAssetQuantity);
      }
    });
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
  it('nativeScript', () => {
    const script: NativeScript = {
      __type: ScriptType.Native,
      kind: NativeScriptKind.RequireAnyOf,
      scripts: [
        {
          __type: ScriptType.Native,
          keyHash: Ed25519KeyHash('b275b08c999097247f7c17e77007c7010cd19f20cc086ad99d398538'),
          kind: NativeScriptKind.RequireSignature
        },
        {
          __type: ScriptType.Native,
          kind: NativeScriptKind.RequireAllOf,
          scripts: [
            {
              __type: ScriptType.Native,
              kind: NativeScriptKind.RequireTimeBefore,
              slot: 3000
            },
            {
              __type: ScriptType.Native,
              keyHash: Ed25519KeyHash('966e394a544f242081e41d1965137b1bb412ac230d40ed5407821c37'),
              kind: NativeScriptKind.RequireSignature
            },
            {
              __type: ScriptType.Native,
              kind: NativeScriptKind.RequireTimeAfter,
              slot: 4000
            }
          ]
        }
      ]
    };

    const baseScript = coreToCsl.nativeScript(script);
    const firstSubScript = baseScript.as_script_any()?.native_scripts().get(0).as_script_pubkey();
    const secondSubScript = baseScript.as_script_any()?.native_scripts().get(1).as_script_all();

    expect(baseScript.as_script_any()?.native_scripts().len()).toBe(2);
    expect(firstSubScript?.addr_keyhash()?.to_bytes()).toStrictEqual(
      Uint8Array.from(Buffer.from('b275b08c999097247f7c17e77007c7010cd19f20cc086ad99d398538', 'hex'))
    );
    expect(secondSubScript?.native_scripts()?.len()).toEqual(3);
    expect(secondSubScript?.native_scripts()?.get(0).as_timelock_expiry()?.slot()).toEqual(3000);
    expect(secondSubScript?.native_scripts()?.get(1).as_script_pubkey()?.addr_keyhash().to_bytes()).toStrictEqual(
      Uint8Array.from(Buffer.from('966e394a544f242081e41d1965137b1bb412ac230d40ed5407821c37', 'hex'))
    );
    expect(secondSubScript?.native_scripts()?.get(2).as_timelock_start()?.slot()).toEqual(4000);
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
