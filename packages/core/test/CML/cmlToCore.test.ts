import * as Crypto from '@cardano-sdk/crypto';
import { AssetId } from '../../src/Cardano';
import { Base64Blob, HexBlob, ManagedFreeableScope } from '@cardano-sdk/util';
import { CML, Cardano, cmlToCore, coreToCml } from '../../src';
import { NativeScript } from '@dcspark/cardano-multiplatform-lib-nodejs';
import {
  babbageTxBody,
  babbageTxOutWithDatumHash,
  babbageTxOutWithInlineDatum,
  mintTokenMap,
  txBody,
  txIn,
  txInWithAddress,
  txOut,
  txOutWithByron,
  valueCoinOnly,
  valueWithAssets
} from './testData';
import { createAssetId } from '../../src/CML/cmlToCore';
import { isConstrPlutusData, isPlutusBoundedBytes, isPlutusMap } from '../../src/Cardano/util';
import { parseAssetId } from '../../src/CML/coreToCml';

describe('cmlToCore', () => {
  let scope: ManagedFreeableScope;

  beforeEach(() => {
    scope = new ManagedFreeableScope();
  });

  afterEach(() => {
    scope.dispose();
  });

  describe('AssetId', () => {
    it('createAssetId', async () => {
      const assetId = AssetId('659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba8254534c41');
      const cmlAssetId = parseAssetId(assetId);

      expect(createAssetId(cmlAssetId.scriptHash, cmlAssetId.assetName)).toEqual(assetId);
    });
  });

  describe('value', () => {
    it('coin only', () => {
      expect(cmlToCore.value(coreToCml.value(scope, valueCoinOnly))).toEqual(valueCoinOnly);
    });
    it('cmlToCore coin with assets', () => {
      expect(cmlToCore.value(coreToCml.value(scope, valueWithAssets))).toEqual(valueWithAssets);
    });
  });

  describe('txIn', () => {
    it('converts an input', () => {
      expect(cmlToCore.txIn(coreToCml.txIn(scope, txIn))).toEqual(txIn);
    });
    it('doesnt serialize address', () => {
      expect(cmlToCore.txIn(coreToCml.txIn(scope, txInWithAddress))).toEqual({
        ...txInWithAddress,
        address: undefined
      });
    });
  });

  describe('txOut', () => {
    it('can convert a CML.TransactionOutput which contains a Shelley address to Core.TxOut', () => {
      expect(cmlToCore.txOut(coreToCml.txOut(scope, txOut))).toEqual(txOut);
    });

    it('can convert a CML.TransactionOutput which contains a Byron address to Core.TxOut', () => {
      expect(cmlToCore.txOut(coreToCml.txOut(scope, txOutWithByron))).toEqual(txOutWithByron);
    });

    it('can convert a CML.TransactionOutput with babbage fields to Core.TxOut', () => {
      expect(cmlToCore.txOut(coreToCml.txOut(scope, babbageTxOutWithInlineDatum))).toEqual(babbageTxOutWithInlineDatum);
      expect(cmlToCore.txOut(coreToCml.txOut(scope, babbageTxOutWithDatumHash))).toEqual(babbageTxOutWithDatumHash);
    });

    it('converts inline datum into a parseable format', () => {
      // An extended cip68/222 datum (handle)
      const nftMetadataDatum = Buffer.from(
        'd8799faa446e616d654724736e656b363945696d6167655838697066733a2f2f7a6232726861476b726d32675143333636535a626254516d6a446433666a64343466744848344c34547441427970534b61496d65646961547970654a696d6167652f6a706567426f6700496f675f6e756d626572004672617269747946636f6d6d6f6e466c656e677468064a636861726163746572734f6c6574746572732c6e756d62657273516e756d657269635f6d6f64696669657273404776657273696f6e0101a84e7374616e646172645f696d6167655838697066733a2f2f7a6232726861476b726d32675143333636535a626254516d6a446433666a64343466744848344c34547441427970534b6146706f7274616c404864657369676e65724047736f6369616c73404676656e646f72404764656661756c7400536c6173745f7570646174655f616464726573735839003382fe4bf2249a8fb53df0b64aba1c78c95f117a7d57c59d9869b341389caccf78b5f141efbd97de910777674368d8ffedbb3fdc797028384c76616c6964617465645f6279581c4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e1ff',
        'hex'
      );
      const getMapValueAsUTF8 = (map: Cardano.PlutusData, key: string): string => {
        if (!isPlutusMap(map)) throw new Error('unexpected datum type: expected map');
        const keys = [...map.data.keys()];
        const mapKey = keys.find((k) => isPlutusBoundedBytes(k) && Buffer.from(k).toString('utf8') === key);
        if (!mapKey) throw new Error('key not found');
        const rawValue = map.data.get(mapKey)!;
        if (!isPlutusBoundedBytes(rawValue)) throw new Error('unexpected datum type: expected bounded bytes');
        return Buffer.from(rawValue).toString('utf8');
      };
      const cmlTxOut = coreToCml.txOut(scope, txOut);
      cmlTxOut.set_datum(scope.manage(CML.Datum.new_data(scope.manage(CML.PlutusData.from_bytes(nftMetadataDatum)))));

      const coreTxOut = cmlToCore.txOut(cmlTxOut);
      if (!isConstrPlutusData(coreTxOut.datum)) throw new Error('unexpected datum type');
      expect(coreTxOut.datum.fields.items.length).toBe(3);

      const nftMetadata = coreTxOut.datum.fields.items[0];
      expect(getMapValueAsUTF8(nftMetadata, 'name')).toEqual('$snek69');

      const handleMetadata = coreTxOut.datum.fields.items[2];
      expect(getMapValueAsUTF8(handleMetadata, 'standard_image')).toEqual(
        'ipfs://zb2rhaGkrm2gQC366SZbbTQmjDd3fjd44ftHH4L4TtABypSKa'
      );
    });
  });

  describe('plutusData roundtrip', () => {
    test('bigint', () => {
      const plutusData: Cardano.PlutusData = 123n;
      const plutusDataWithCbor: Cardano.PlutusData = 123n;
      expect(cmlToCore.plutusData(coreToCml.plutusData(scope, plutusData))).toEqual(plutusDataWithCbor);
      expect(cmlToCore.plutusData(coreToCml.plutusData(scope, plutusDataWithCbor))).toEqual(plutusDataWithCbor);
    });
    test('list', () => {
      const plutusData: Cardano.PlutusData = { items: [123n] };
      const plutusDataWithCbor: Cardano.PlutusData = {
        cbor: HexBlob('9f187bff'),
        items: [123n]
      };
      expect(cmlToCore.plutusData(coreToCml.plutusData(scope, plutusData))).toEqual(plutusDataWithCbor);
      expect(cmlToCore.plutusData(coreToCml.plutusData(scope, plutusDataWithCbor))).toEqual(plutusDataWithCbor);
    });
    test('map', () => {
      const plutusData: Cardano.PlutusData = { data: new Map([[123n, 1234n]]) };
      const plutusDataWithCbor: Cardano.PlutusData = {
        cbor: HexBlob('a1187b1904d2'),
        data: new Map([[123n, 1234n]])
      };
      expect(cmlToCore.plutusData(coreToCml.plutusData(scope, plutusData))).toEqual(plutusDataWithCbor);
      expect(cmlToCore.plutusData(coreToCml.plutusData(scope, plutusDataWithCbor))).toEqual(plutusDataWithCbor);
    });
    test('constructor', () => {
      const plutusData: Cardano.PlutusData = { constructor: 1n, fields: { items: [123n] } };
      const plutusDataWithCbor: Cardano.PlutusData = {
        cbor: HexBlob('d87a9f187bff'),
        constructor: 1n,
        fields: { cbor: HexBlob('9f187bff'), items: [123n] }
      };
      expect(cmlToCore.plutusData(coreToCml.plutusData(scope, plutusData))).toEqual(plutusDataWithCbor);
      expect(cmlToCore.plutusData(coreToCml.plutusData(scope, plutusDataWithCbor))).toEqual(plutusDataWithCbor);
    });
    test('bytes', () => {
      const plutusData: Cardano.PlutusData = new Uint8Array(Buffer.from('123abc', 'hex'));
      expect(cmlToCore.plutusData(coreToCml.plutusData(scope, plutusData))).toEqual(plutusData);
    });
  });

  it('utxo', () => {
    const utxo: Cardano.Utxo[] = [[txIn as Cardano.HydratedTxIn, txOut]];
    expect(cmlToCore.utxo(coreToCml.utxo(scope, utxo))).toEqual(utxo);
  });

  it('txMint', () => {
    expect(cmlToCore.txMint(coreToCml.txMint(scope, mintTokenMap))).toEqual(mintTokenMap);
  });

  it('NativeScript', () => {
    const cmlScript: NativeScript = scope.manage(
      NativeScript.from_bytes(
        Uint8Array.from(
          Buffer.from(
            // eslint-disable-next-line max-len
            '8202828200581cb275b08c999097247f7c17e77007c7010cd19f20cc086ad99d3985388201838205190bb88200581c966e394a544f242081e41d1965137b1bb412ac230d40ed5407821c378204190fa0',
            'hex'
          )
        )
      )
    );

    const coreScript: Cardano.NativeScript = {
      __type: Cardano.ScriptType.Native,
      kind: Cardano.NativeScriptKind.RequireAnyOf,
      scripts: [
        {
          __type: Cardano.ScriptType.Native,
          keyHash: Crypto.Ed25519KeyHashHex('b275b08c999097247f7c17e77007c7010cd19f20cc086ad99d398538'),
          kind: Cardano.NativeScriptKind.RequireSignature
        },
        {
          __type: Cardano.ScriptType.Native,
          kind: Cardano.NativeScriptKind.RequireAllOf,
          scripts: [
            {
              __type: Cardano.ScriptType.Native,
              kind: Cardano.NativeScriptKind.RequireTimeBefore,
              slot: Cardano.Slot(3000)
            },
            {
              __type: Cardano.ScriptType.Native,
              keyHash: Crypto.Ed25519KeyHashHex('966e394a544f242081e41d1965137b1bb412ac230d40ed5407821c37'),
              kind: Cardano.NativeScriptKind.RequireSignature
            },
            {
              __type: Cardano.ScriptType.Native,
              kind: Cardano.NativeScriptKind.RequireTimeAfter,
              slot: Cardano.Slot(4000)
            }
          ]
        }
      ]
    };

    expect(cmlToCore.nativeScript(cmlScript)).toStrictEqual(coreScript);
  });

  describe('txAuxiliaryData', () => {
    // mostly covered by newTx - could just remove this
    it.todo('txMetadata');
    it.todo('txScripts');
  });

  it('txBody', () => {
    expect(cmlToCore.txBody(scope.manage(coreToCml.txBody(scope, txBody)))).toEqual(txBody);
  });

  it('Babbage txBody', () => {
    expect(cmlToCore.txBody(scope.manage(coreToCml.txBody(scope, babbageTxBody)))).toEqual(babbageTxBody);
  });

  it('txWitnessBootstrap', () => {
    // values from ogmios.wsp.json
    const bootstrap: Cardano.BootstrapWitness[] = [
      {
        addressAttributes: Base64Blob('oA=='),
        chainCode: HexBlob('b6dbf0b03c93afe5696f10d49e8a8304ebfac01deeb8f82f2af5836ebbc1b450'),
        key: Crypto.Ed25519PublicKeyHex('deeb8f82f2af5836ebbc1b450b6dbf0b03c93afe5696f10d49e8a8304ebfac01'),
        signature: Crypto.Ed25519SignatureHex(
          Buffer.from(
            'ZGdic3hnZ3RvZ2hkanB0ZXR2dGtjb2N2eWZpZHFxZ2d1cmpocmhxYWlpc3BxcnVlbGh2eXBxeGVld3ByeWZ2dw==',
            'base64'
          ).toString('hex')
        )
      }
    ];
    expect(cmlToCore.txWitnessBootstrap(scope.manage(coreToCml.txWitnessBootstrap(scope, bootstrap)))).toEqual(
      bootstrap
    );
  });
});
