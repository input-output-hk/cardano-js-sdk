import * as Cardano from '../../../src/Cardano';
import * as Crypto from '@cardano-sdk/crypto';
import { Guards, GuardsKind, TransactionBody } from '../../../src/Serialization';
import { HexBlob } from '@cardano-sdk/util';
import { setInConwayEra } from '../../../src';
import { txIn } from './testData';

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

const bodyPrefix = 'a400818258200f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5000180020a';

const keyHashFormBodyCbor = HexBlob(`${bodyPrefix}0e81581c${keyHash}`);
const credentialFormBodyCbor = HexBlob(`${bodyPrefix}0e828200581c${keyHash}8201581c${scriptHash}`);
const credentialFormBodyTaggedCbor = HexBlob(`${bodyPrefix}0ed90102828200581c${keyHash}8201581c${scriptHash}`);
const credentialFormBodyReversedCbor = HexBlob(`${bodyPrefix}0e828201581c${scriptHash}8200581c${keyHash}`);
const scriptOnlyBodyCbor = HexBlob(`${bodyPrefix}0e818201581c${scriptHash}`);
const allKeyHashCredentialBodyCbor = HexBlob(`${bodyPrefix}0e818200581c${keyHash}`);

const mixedKeyHashFirstBodyCbor = HexBlob(`${bodyPrefix}0e82581c${keyHash}8201581c${scriptHash}`);
const mixedCredentialFirstBodyCbor = HexBlob(`${bodyPrefix}0e828200581c${keyHash}581c${scriptHash}`);

const baseCore: Cardano.TxBody = {
  fee: 10n,
  inputs: [txIn],
  outputs: []
};

const keyHashCore: Cardano.TxBody = {
  ...baseCore,
  requiredExtraSignatures: [keyHash]
};

const credentialCore: Cardano.TxBody = {
  ...baseCore,
  guards: [keyHashCredential, scriptHashCredential]
};

describe('TransactionBody guards (key 14)', () => {
  afterEach(() => setInConwayEra(false));

  describe('key hash form regression', () => {
    it('encodes a keyhash-only core body byte-identically to the legacy required_signers form', () => {
      expect(TransactionBody.fromCore(keyHashCore).toCbor()).toEqual(keyHashFormBodyCbor);
    });

    it('round trips a keyhash form body byte-exact through decode, core and re-encode', () => {
      const body = TransactionBody.fromCbor(keyHashFormBodyCbor);

      expect(body.toCbor()).toEqual(keyHashFormBodyCbor);
      expect(TransactionBody.fromCore(body.toCore()).toCbor()).toEqual(keyHashFormBodyCbor);
    });

    it('exposes decoded keyhash form guards through the legacy requiredSigners getter', () => {
      const body = TransactionBody.fromCbor(keyHashFormBodyCbor);

      expect(body.requiredSigners()?.toCore()).toEqual([keyHash]);
      expect(body.guards()).toBeUndefined();
    });
  });

  describe('credential form round trip', () => {
    it('round trips a mixed key/script credential body byte-exact', () => {
      const body = TransactionBody.fromCbor(credentialFormBodyCbor);

      expect(body.toCbor()).toEqual(credentialFormBodyCbor);
      expect(body.guards()?.kind()).toEqual(GuardsKind.Credentials);
      expect(TransactionBody.fromCore(body.toCore()).toCbor()).toEqual(credentialFormBodyCbor);
    });

    it('round trips a tag 258 wrapped credential body byte-exact', () => {
      expect(TransactionBody.fromCbor(credentialFormBodyTaggedCbor).toCbor()).toEqual(credentialFormBodyTaggedCbor);
    });

    it('preserves guard order through decode, core and re-encode', () => {
      const body = TransactionBody.fromCbor(credentialFormBodyReversedCbor);

      expect(body.guards()?.credentials()).toEqual([scriptHashCredential, keyHashCredential]);
      expect(body.toCbor()).toEqual(credentialFormBodyReversedCbor);
      expect(TransactionBody.fromCore(body.toCore()).toCbor()).toEqual(credentialFormBodyReversedCbor);
    });
  });

  describe('toCore', () => {
    it('maps a credential form body to guards plus the key-hash subset as requiredExtraSignatures', () => {
      const core = TransactionBody.fromCbor(credentialFormBodyCbor).toCore();

      expect(core.guards).toEqual([keyHashCredential, scriptHashCredential]);
      expect(core.requiredExtraSignatures).toEqual([keyHash]);
    });

    it('omits requiredExtraSignatures when no guard is a key hash', () => {
      const core = TransactionBody.fromCbor(scriptOnlyBodyCbor).toCore();

      expect(core.guards).toEqual([scriptHashCredential]);
      expect(core.requiredExtraSignatures).toBeUndefined();
    });

    it('maps a keyhash form body to requiredExtraSignatures only', () => {
      const core = TransactionBody.fromCbor(keyHashFormBodyCbor).toCore();

      expect(core.requiredExtraSignatures).toEqual([keyHash]);
      expect(core.guards).toBeUndefined();
    });
  });

  describe('fromCore', () => {
    it('encodes the credential form when a script-hash guard is present', () => {
      expect(TransactionBody.fromCore(credentialCore).toCbor()).toEqual(credentialFormBodyCbor);
    });

    it('encodes the credential form for explicitly provided guards even when all are key hashes', () => {
      const body = TransactionBody.fromCore({ ...baseCore, guards: [keyHashCredential] });

      expect(body.toCbor()).toEqual(allKeyHashCredentialBodyCbor);
    });

    it('encodes the legacy keyhash form when only requiredExtraSignatures is set', () => {
      expect(TransactionBody.fromCore(keyHashCore).toCbor()).toEqual(keyHashFormBodyCbor);
    });

    it('prefers guards over requiredExtraSignatures when both are set, without merging', () => {
      const body = TransactionBody.fromCore({
        ...baseCore,
        guards: [scriptHashCredential],
        requiredExtraSignatures: [keyHash]
      });

      expect(body.toCbor()).toEqual(HexBlob(`${bodyPrefix}0e818201581c${scriptHash}`));
      expect(body.requiredSigners()).toBeUndefined();
    });

    it('emits tag 258 wrapped guards in the Conway era', () => {
      setInConwayEra(true);
      const body = TransactionBody.fromCore({ ...baseCore, guards: [keyHashCredential, scriptHashCredential] });

      expect(body.toCbor()).toEqual(
        HexBlob(`a400d9010281825820${txIn.txId}000180020a0ed90102828200581c${keyHash}8201581c${scriptHash}`)
      );
    });
  });

  describe('mixed form decode rejection', () => {
    it('rejects a guards set whose first element is a byte string but a later element is an array', () => {
      expect(() => TransactionBody.fromCbor(mixedKeyHashFirstBodyCbor)).toThrow();
    });

    it('rejects a guards set whose first element is an array but a later element is a byte string', () => {
      expect(() => TransactionBody.fromCbor(mixedCredentialFirstBodyCbor)).toThrow();
    });
  });

  describe('pre-Conway empty required_signers', () => {
    it('decodes an empty key 14 set, re-encodes byte-exact and yields empty requiredExtraSignatures', () => {
      const emptyBodyCbor = HexBlob(`${bodyPrefix}0e80`);
      const body = TransactionBody.fromCbor(emptyBodyCbor);

      expect(body.toCbor()).toEqual(emptyBodyCbor);
      expect(body.requiredSigners()?.toCore()).toEqual([]);

      const core = body.toCore();
      expect(core.requiredExtraSignatures).toEqual([]);
      expect(core.guards).toBeUndefined();
    });
  });

  describe('setters', () => {
    it('setGuards with keyhash form guards populates requiredSigners and encodes the legacy form', () => {
      const body = TransactionBody.fromCore(baseCore);
      body.setGuards(Guards.fromKeyHashes([keyHash]));

      expect(body.requiredSigners()?.toCore()).toEqual([keyHash]);
      expect(body.guards()).toBeUndefined();
      expect(body.toCbor()).toEqual(keyHashFormBodyCbor);
    });

    it('setGuards with credential form guards clears requiredSigners', () => {
      const body = TransactionBody.fromCore(keyHashCore);
      body.setGuards(Guards.fromCredentials([scriptHashCredential]));

      expect(body.requiredSigners()).toBeUndefined();
      expect(body.guards()?.credentials()).toEqual([scriptHashCredential]);
      expect(body.toCbor()).toEqual(HexBlob(`${bodyPrefix}0e818201581c${scriptHash}`));
    });

    it('setRequiredSigners clears credential form guards', () => {
      const body = TransactionBody.fromCore(credentialCore);
      body.setRequiredSigners(TransactionBody.fromCore(keyHashCore).requiredSigners()!);

      expect(body.guards()).toBeUndefined();
      expect(body.toCbor()).toEqual(keyHashFormBodyCbor);
    });
  });
});
