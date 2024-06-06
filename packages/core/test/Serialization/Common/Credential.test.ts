import * as Crypto from '@cardano-sdk/crypto';
import { HexBlob } from '@cardano-sdk/util';

import { Cardano } from '../../../src/index.js';
import { Credential } from '../../../src/Serialization/Common/index.js';

describe('Credential', () => {
  const cbor = HexBlob('8200581c30000000000000000000000000000000000000000000000000000000');
  const cborArraySize3 = HexBlob('8300581c3000000000000000000000000000000000000000000000000000000000');
  const coreCredential: Cardano.Credential = {
    hash: Crypto.Hash28ByteBase16('30000000000000000000000000000000000000000000000000000000'),
    type: Cardano.CredentialType.KeyHash
  };

  it('can encode init from Core', () => {
    const credential = Credential.fromCore(coreCredential);
    expect(credential.toCbor()).toEqual(cbor);
  });

  it('can encode to Core', () => {
    const credential = Credential.fromCbor(cbor);
    expect(credential.toCore()).toEqual(coreCredential);
  });

  it('politely refuses an invalid credential cbor', () => {
    expect(() => Credential.fromCbor(cborArraySize3)).toThrow();
  });
});
