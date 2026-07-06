import * as Cardano from '../../../src/Cardano';
import * as Crypto from '@cardano-sdk/crypto';
import { Guards, GuardsKind } from '../../../src/Serialization';
import { HexBlob } from '@cardano-sdk/util';
import { setInConwayEra } from '../../../src';

const keyHash = Crypto.Ed25519KeyHashHex('6199186adb51974690d7247d2646097d2c62763b16fb7ed3f9f55d39');
const scriptHash = Crypto.Hash28ByteBase16('966e394a544f242081e41d1965137b1bb412ac230d40ed5407821c37');

const keyHashCredential: Cardano.Credential = {
  hash: Crypto.Hash28ByteBase16(keyHash),
  type: Cardano.CredentialType.KeyHash
};

const scriptHashCredential: Cardano.Credential = {
  hash: scriptHash,
  type: Cardano.CredentialType.ScriptHash
};

const keyHashFormCbor = HexBlob(`81581c${keyHash}`);
const keyHashFormTaggedCbor = HexBlob(`d9010281581c${keyHash}`);
const credentialFormCbor = HexBlob(`828200581c${keyHash}8201581c${scriptHash}`);
const credentialFormTaggedCbor = HexBlob(`d90102828200581c${keyHash}8201581c${scriptHash}`);
const credentialFormReversedCbor = HexBlob(`828201581c${scriptHash}8200581c${keyHash}`);
const singleCredentialCbor = HexBlob(`818200581c${keyHash}`);

describe('Guards', () => {
  beforeEach(() => setInConwayEra(false));
  afterEach(() => setInConwayEra(true));

  describe('fromCbor', () => {
    it('decodes the key hash form from a bare array', () => {
      const guards = Guards.fromCbor(keyHashFormCbor);

      expect(guards.kind()).toEqual(GuardsKind.KeyHashes);
      expect(guards.size()).toEqual(1);
      expect(guards.keyHashes()).toEqual([keyHash]);
      expect(guards.credentials()).toBeUndefined();
    });

    it('decodes the key hash form from a tag 258 wrapped array', () => {
      const guards = Guards.fromCbor(keyHashFormTaggedCbor);

      expect(guards.kind()).toEqual(GuardsKind.KeyHashes);
      expect(guards.keyHashes()).toEqual([keyHash]);
    });

    it('decodes the credential form from a bare array', () => {
      const guards = Guards.fromCbor(credentialFormCbor);

      expect(guards.kind()).toEqual(GuardsKind.Credentials);
      expect(guards.size()).toEqual(2);
      expect(guards.credentials()).toEqual([keyHashCredential, scriptHashCredential]);
      expect(guards.keyHashes()).toBeUndefined();
    });

    it('decodes the credential form from a tag 258 wrapped array', () => {
      const guards = Guards.fromCbor(credentialFormTaggedCbor);

      expect(guards.kind()).toEqual(GuardsKind.Credentials);
      expect(guards.credentials()).toEqual([keyHashCredential, scriptHashCredential]);
    });

    it('disambiguates identical hash bytes by the shape of the first element', () => {
      const asKeyHash = Guards.fromCbor(keyHashFormCbor);
      const asCredential = Guards.fromCbor(singleCredentialCbor);

      expect(asKeyHash.kind()).toEqual(GuardsKind.KeyHashes);
      expect(asKeyHash.keyHashes()).toEqual([keyHash]);
      expect(asCredential.kind()).toEqual(GuardsKind.Credentials);
      expect(asCredential.credentials()).toEqual([keyHashCredential]);
    });

    it('decodes an empty set as key hash form and re-encodes byte-exact', () => {
      const bare = Guards.fromCbor(HexBlob('80'));
      expect(bare.kind()).toEqual(GuardsKind.KeyHashes);
      expect(bare.keyHashes()).toEqual([]);
      expect(bare.toCbor()).toEqual(HexBlob('80'));

      const tagged = Guards.fromCbor(HexBlob('d9010280'));
      expect(tagged.keyHashes()).toEqual([]);
      expect(tagged.toCbor()).toEqual(HexBlob('d9010280'));
    });

    it('rejects a first element that is neither a byte string nor an array', () => {
      expect(() => Guards.fromCbor(HexBlob('8101'))).toThrow();
    });
  });

  describe('toCbor', () => {
    it('round trips the key hash form byte-exact with and without tag 258 wrapping', () => {
      expect(Guards.fromCbor(keyHashFormCbor).toCbor()).toEqual(keyHashFormCbor);
      expect(Guards.fromCbor(keyHashFormTaggedCbor).toCbor()).toEqual(keyHashFormTaggedCbor);
    });

    it('round trips the credential form byte-exact with and without tag 258 wrapping', () => {
      expect(Guards.fromCbor(credentialFormCbor).toCbor()).toEqual(credentialFormCbor);
      expect(Guards.fromCbor(credentialFormTaggedCbor).toCbor()).toEqual(credentialFormTaggedCbor);
    });

    it('preserves credential element order', () => {
      const guards = Guards.fromCbor(credentialFormReversedCbor);

      expect(guards.credentials()).toEqual([scriptHashCredential, keyHashCredential]);
      expect(guards.toCbor()).toEqual(credentialFormReversedCbor);
    });

    it('encodes key hashes built from core as a bare array outside the Conway era', () => {
      expect(Guards.fromKeyHashes([keyHash]).toCbor()).toEqual(keyHashFormCbor);
    });

    it('encodes key hashes built from core with the 258 tag in the Conway era', () => {
      setInConwayEra(true);
      expect(Guards.fromKeyHashes([keyHash]).toCbor()).toEqual(keyHashFormTaggedCbor);
    });

    it('encodes credentials built from core as a bare array outside the Conway era', () => {
      expect(Guards.fromCredentials([keyHashCredential, scriptHashCredential]).toCbor()).toEqual(credentialFormCbor);
    });

    it('encodes credentials built from core with the 258 tag in the Conway era', () => {
      setInConwayEra(true);
      expect(Guards.fromCredentials([keyHashCredential, scriptHashCredential]).toCbor()).toEqual(
        credentialFormTaggedCbor
      );
    });
  });

  describe('form exclusivity', () => {
    it('key hash form guards never expose or encode credentials', () => {
      const guards = Guards.fromKeyHashes([keyHash]);

      expect(guards.kind()).toEqual(GuardsKind.KeyHashes);
      expect(guards.credentials()).toBeUndefined();
      expect(guards.toCbor()).toEqual(keyHashFormCbor);
    });

    it('credential form guards encode every element as a credential, even key hash credentials', () => {
      const guards = Guards.fromCredentials([keyHashCredential]);

      expect(guards.kind()).toEqual(GuardsKind.Credentials);
      expect(guards.keyHashes()).toBeUndefined();
      expect(guards.toCbor()).toEqual(singleCredentialCbor);
    });
  });
});
