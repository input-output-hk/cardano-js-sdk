import * as Crypto from '@cardano-sdk/crypto';
import { Base64Blob, HexBlob, ManagedFreeableScope } from '@cardano-sdk/util';
import { Cardano, cmlToCore, coreToCml } from '../../src';
import { NativeScript } from '@dcspark/cardano-multiplatform-lib-nodejs';
import {
  babbageTx,
  babbageTxBody,
  babbageTxOutWithDatumHash,
  babbageTxOutWithInlineDatum,
  mintTokenMap,
  tx,
  txBody,
  txIn,
  txInWithAddress,
  txOut,
  txOutWithByron,
  valueCoinOnly,
  valueWithAssets
} from './testData';

describe('cmlToCore', () => {
  let scope: ManagedFreeableScope;

  beforeEach(() => {
    scope = new ManagedFreeableScope();
  });

  afterEach(() => {
    scope.dispose();
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

  it('newTx', () => {
    expect(cmlToCore.newTx(scope.manage(coreToCml.tx(scope, tx)))).toEqual(tx);
  });

  it('Babbage newTx', () => {
    expect(cmlToCore.newTx(scope.manage(coreToCml.tx(scope, babbageTx)))).toEqual(babbageTx);
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
