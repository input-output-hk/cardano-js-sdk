import { Cardano, coreToCsl, cslToCore } from '../../src';
import { NativeScript } from '@emurgo/cardano-serialization-lib-nodejs';
import { mintTokenMap, tx, txBody, txIn, txInWithAddress, txOut, valueCoinOnly, valueWithAssets } from './testData';

describe('cslToCore', () => {
  describe('value', () => {
    it('coin only', () => {
      expect(cslToCore.value(coreToCsl.value(valueCoinOnly))).toEqual(valueCoinOnly);
    });
    it('cslToCore coin with assets', () => {
      expect(cslToCore.value(coreToCsl.value(valueWithAssets))).toEqual(valueWithAssets);
    });
  });

  describe('txIn', () => {
    it('converts an input', () => {
      expect(cslToCore.txIn(coreToCsl.txIn(txIn))).toEqual(txIn);
    });
    it('doesnt serialize address', () => {
      expect(cslToCore.txIn(coreToCsl.txIn(txInWithAddress))).toEqual({
        ...txInWithAddress,
        address: undefined
      });
    });
  });

  it('txOut', () => {
    expect(cslToCore.txOut(coreToCsl.txOut(txOut))).toEqual(txOut);
  });

  it('utxo', () => {
    const utxo: Cardano.Utxo[] = [[txIn as Cardano.TxIn, txOut]];
    expect(cslToCore.utxo(coreToCsl.utxo(utxo))).toEqual(utxo);
  });

  it('txMint', () => {
    expect(cslToCore.txMint(coreToCsl.txMint(mintTokenMap))).toEqual(mintTokenMap);
  });

  it('NativeScript', () => {
    const cslScript: NativeScript = NativeScript.from_bytes(
      Uint8Array.from(
        Buffer.from(
          // eslint-disable-next-line max-len
          '8202828200581cb275b08c999097247f7c17e77007c7010cd19f20cc086ad99d3985388201838205190bb88200581c966e394a544f242081e41d1965137b1bb412ac230d40ed5407821c378204190fa0',
          'hex'
        )
      )
    );

    const coreScript: Cardano.NativeScript = {
      __type: Cardano.ScriptType.Native,
      kind: Cardano.NativeScriptKind.RequireAnyOf,
      scripts: [
        {
          __type: Cardano.ScriptType.Native,
          keyHash: Cardano.Ed25519KeyHash('b275b08c999097247f7c17e77007c7010cd19f20cc086ad99d398538'),
          kind: Cardano.NativeScriptKind.RequireSignature
        },
        {
          __type: Cardano.ScriptType.Native,
          kind: Cardano.NativeScriptKind.RequireAllOf,
          scripts: [
            {
              __type: Cardano.ScriptType.Native,
              kind: Cardano.NativeScriptKind.RequireTimeBefore,
              slot: 3000
            },
            {
              __type: Cardano.ScriptType.Native,
              keyHash: Cardano.Ed25519KeyHash('966e394a544f242081e41d1965137b1bb412ac230d40ed5407821c37'),
              kind: Cardano.NativeScriptKind.RequireSignature
            },
            {
              __type: Cardano.ScriptType.Native,
              kind: Cardano.NativeScriptKind.RequireTimeAfter,
              slot: 4000
            }
          ]
        }
      ]
    };

    expect(cslToCore.nativeScript(cslScript)).toStrictEqual(coreScript);
  });

  describe('txAuxiliaryData', () => {
    // mostly covered by newTx - could just remove this
    it.todo('txMetadata');
    it.todo('txScripts');
  });

  it('txBody', () => {
    expect(cslToCore.txBody(coreToCsl.txBody(txBody))).toEqual(txBody);
  });

  it('newTx', () => {
    expect(cslToCore.newTx(coreToCsl.tx(tx))).toEqual(tx);
  });
});
