import * as Crypto from '@cardano-sdk/crypto';

import { Cardano, Serialization } from '../../src';
import { HexBlob } from '@cardano-sdk/util';
import { ScriptLanguage } from '../../src/Serialization/Scripts/ScriptLanguage';

describe('PlutusV4Script', () => {
  const plutusV4RawBytes = HexBlob('4d01000033222220051200120011');
  const plutusV4Cbor = HexBlob('4e4d01000033222220051200120011');
  const scriptUnionCbor = HexBlob('82044e4d01000033222220051200120011');
  const plutusV4Hash = Crypto.Hash28ByteBase16('4d0bedb209c225070654ef9753d314d16527a5910691adb50d717df9');

  const coreV4PlutusScript: Cardano.PlutusScript = {
    __type: Cardano.ScriptType.Plutus,
    bytes: plutusV4RawBytes,
    version: Cardano.PlutusLanguageVersion.V4
  };

  it('can decode the script from a Core object', () => {
    const script = Serialization.PlutusV4Script.fromCore(coreV4PlutusScript);

    expect(script.toCbor()).toEqual(plutusV4Cbor);
    expect(script.rawBytes()).toEqual(plutusV4RawBytes);
    expect(script.hash()).toEqual(plutusV4Hash);
  });

  it('can decode the script from CBOR', () => {
    const script = Serialization.PlutusV4Script.fromCbor(plutusV4Cbor);

    expect(script.toCore()).toEqual(coreV4PlutusScript);
    expect(script.rawBytes()).toEqual(plutusV4RawBytes);
    expect(script.hash()).toEqual(plutusV4Hash);
  });

  it('round trips fromCbor -> toCbor byte-exact', () => {
    const script = Serialization.PlutusV4Script.fromCbor(plutusV4Cbor);

    expect(script.toCbor()).toEqual(plutusV4Cbor);
  });

  it('round trips toCore -> fromCore', () => {
    const script = Serialization.PlutusV4Script.fromCbor(plutusV4Cbor);

    expect(Serialization.PlutusV4Script.fromCore(script.toCore()).rawBytes()).toEqual(plutusV4RawBytes);
  });

  it('hashes with the 04 prefix tag, unlike a V3 script with identical bytes', () => {
    const v4Script = new Serialization.PlutusV4Script(plutusV4RawBytes);
    const v3Script = new Serialization.PlutusV3Script(plutusV4RawBytes);

    expect(v4Script.hash()).toEqual(plutusV4Hash);
    expect(v4Script.hash()).not.toEqual(v3Script.hash());
  });

  describe('Script union', () => {
    it('can decode a plutus v4 script from CBOR', () => {
      const script = Serialization.Script.fromCbor(scriptUnionCbor);

      expect(script.language()).toEqual(ScriptLanguage.PlutusV4);
      expect(script.asPlutusV4()).toBeDefined();
      expect(script.asPlutusV3()).toBeUndefined();
      expect(script.hash()).toEqual(plutusV4Hash);
      expect(script.toCore()).toEqual(coreV4PlutusScript);
    });

    it('round trips [4, bytes] fromCbor -> toCbor byte-exact', () => {
      const script = Serialization.Script.fromCbor(scriptUnionCbor);

      expect(script.toCbor()).toEqual(scriptUnionCbor);
    });

    it('can encode a plutus v4 script from a Core object', () => {
      const script = Serialization.Script.fromCore(coreV4PlutusScript);

      expect(script.language()).toEqual(ScriptLanguage.PlutusV4);
      expect(script.hash()).toEqual(plutusV4Hash);
      expect(script.toCbor()).toEqual(scriptUnionCbor);
    });
  });

  describe('language enums', () => {
    it('ScriptLanguage.PlutusV4 is the script union tag 4', () => {
      expect(ScriptLanguage.PlutusV4).toEqual(4);
    });

    it('PlutusLanguageVersion.V4 is the zero-indexed language 3', () => {
      expect(Cardano.PlutusLanguageVersion.V4).toEqual(3);
    });
  });
});
