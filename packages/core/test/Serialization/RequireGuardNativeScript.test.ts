import * as Crypto from '@cardano-sdk/crypto';
import { Cardano, Serialization } from '../../src';
import { HexBlob } from '@cardano-sdk/util';
import { vectorsForRule } from './dijkstraVectors';

const KEY_HASH = '00112233445566778899aabbccddeeff00112233445566778899aabb';
const SCRIPT_HASH = 'aabbccddeeff00112233445566778899aabbccddeeff001122334455';

const keyHashCredentialCbor = HexBlob(`82068200581c${KEY_HASH}`);
const scriptHashCredentialCbor = HexBlob(`82068201581c${SCRIPT_HASH}`);
const nestedAllCbor = HexBlob(`8201828200581c${KEY_HASH}82068200581c${KEY_HASH}`);
const nestedAnyCbor = HexBlob(`82028182068201581c${SCRIPT_HASH}`);
const nestedNOfKCbor = HexBlob(`8303018182068200581c${KEY_HASH}`);

const keyHashCore: Cardano.RequireGuardScript = {
  __type: Cardano.ScriptType.Native,
  credential: {
    hash: Crypto.Hash28ByteBase16(KEY_HASH),
    type: Cardano.CredentialType.KeyHash
  },
  kind: Cardano.NativeScriptKind.RequireGuard
};

const scriptHashCore: Cardano.RequireGuardScript = {
  __type: Cardano.ScriptType.Native,
  credential: {
    hash: Crypto.Hash28ByteBase16(SCRIPT_HASH),
    type: Cardano.CredentialType.ScriptHash
  },
  kind: Cardano.NativeScriptKind.RequireGuard
};

const nestedAllCore: Cardano.NativeScript = {
  __type: Cardano.ScriptType.Native,
  kind: Cardano.NativeScriptKind.RequireAllOf,
  scripts: [
    {
      __type: Cardano.ScriptType.Native,
      keyHash: Crypto.Ed25519KeyHashHex(KEY_HASH),
      kind: Cardano.NativeScriptKind.RequireSignature
    },
    keyHashCore
  ]
};

const nestedAnyCore: Cardano.NativeScript = {
  __type: Cardano.ScriptType.Native,
  kind: Cardano.NativeScriptKind.RequireAnyOf,
  scripts: [scriptHashCore]
};

const nestedNOfKCore: Cardano.NativeScript = {
  __type: Cardano.ScriptType.Native,
  kind: Cardano.NativeScriptKind.RequireNOf,
  required: 1,
  scripts: [keyHashCore]
};

describe('RequireGuard', () => {
  it('matches the shared dijkstra require-guard vector', () => {
    const vector = vectorsForRule('native_script').find((candidate) => candidate.name === 'require-guard');
    expect(vector).toBeDefined();
    expect(vector!.hex).toEqual(keyHashCredentialCbor.toString());
  });

  it('round trips a key-hash credential byte-exact', () => {
    const script = Serialization.NativeScript.fromCbor(keyHashCredentialCbor);

    expect(script.kind()).toEqual(Cardano.NativeScriptKind.RequireGuard);
    expect(script.asRequireGuard()).toBeDefined();
    expect(script.asScriptPubkey()).toBeUndefined();
    expect(script.toCbor()).toEqual(keyHashCredentialCbor);
    expect(Serialization.NativeScript.fromCore(script.toCore()).toCbor()).toEqual(keyHashCredentialCbor);
  });

  it('round trips a script-hash credential byte-exact', () => {
    const script = Serialization.NativeScript.fromCbor(scriptHashCredentialCbor);

    expect(script.kind()).toEqual(Cardano.NativeScriptKind.RequireGuard);
    expect(script.toCbor()).toEqual(scriptHashCredentialCbor);
    expect(Serialization.NativeScript.fromCore(script.toCore()).toCbor()).toEqual(scriptHashCredentialCbor);
  });

  it('decodes the credential', () => {
    const script = Serialization.RequireGuard.fromCbor(keyHashCredentialCbor);

    expect(script.credential().toCore()).toEqual({
      hash: Crypto.Hash28ByteBase16(KEY_HASH),
      type: Cardano.CredentialType.KeyHash
    });
  });

  it('rejects a wrong kind tag', () => {
    expect(() => Serialization.RequireGuard.fromCbor(HexBlob(`8200581c${KEY_HASH}`))).toThrow();
  });

  it('has toCore/fromCore symmetry', () => {
    expect(Serialization.NativeScript.fromCore(keyHashCore).toCore()).toEqual(keyHashCore);
    expect(Serialization.NativeScript.fromCore(scriptHashCore).toCore()).toEqual(scriptHashCore);
    expect(Serialization.RequireGuard.fromCore(keyHashCore).toCore()).toEqual(keyHashCore);
  });

  it('round trips nested inside script_all byte-exact', () => {
    const script = Serialization.NativeScript.fromCbor(nestedAllCbor);

    expect(script.toCbor()).toEqual(nestedAllCbor);
    expect(script.toCore()).toEqual(nestedAllCore);
    expect(Serialization.NativeScript.fromCore(nestedAllCore).toCbor()).toEqual(nestedAllCbor);
  });

  it('round trips nested inside script_any byte-exact', () => {
    const script = Serialization.NativeScript.fromCbor(nestedAnyCbor);

    expect(script.toCbor()).toEqual(nestedAnyCbor);
    expect(script.toCore()).toEqual(nestedAnyCore);
    expect(Serialization.NativeScript.fromCore(nestedAnyCore).toCbor()).toEqual(nestedAnyCbor);
  });

  it('round trips nested inside script_n_of_k byte-exact', () => {
    const script = Serialization.NativeScript.fromCbor(nestedNOfKCbor);

    expect(script.toCbor()).toEqual(nestedNOfKCbor);
    expect(script.toCore()).toEqual(nestedNOfKCore);
    expect(Serialization.NativeScript.fromCore(nestedNOfKCore).toCbor()).toEqual(nestedNOfKCbor);
  });

  it('hashes with native script prefix 00', () => {
    expect(Serialization.NativeScript.fromCore(keyHashCore).hash()).toEqual(
      Crypto.Hash28ByteBase16('285496cf5e64a2505c944dc707d5804c7422bfd936de7c98ee282534')
    );
    expect(Serialization.NativeScript.fromCore(scriptHashCore).hash()).toEqual(
      Crypto.Hash28ByteBase16('baf8f17908592241efd1f36ec3a12fd5e8dc907c83da9d9400210aee')
    );
    expect(Serialization.NativeScript.fromCore(nestedAllCore).hash()).toEqual(
      Crypto.Hash28ByteBase16('5cd04395d6c284857a0dae9f29cea4402a8be4a1b3ab8295865391f5')
    );
  });
});
