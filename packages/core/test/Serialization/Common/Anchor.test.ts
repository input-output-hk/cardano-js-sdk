/* eslint-disable sonarjs/no-duplicate-string */
import * as Crypto from '@cardano-sdk/crypto';
import { Anchor } from '../../../src/Serialization';
import { Cardano } from '../../../src';
import { HexBlob } from '@cardano-sdk/util';

// Test data used in the following tests was generated with the cardano-serialization-lib
const cbor = HexBlob(
  '827668747470733a2f2f7777772e736f6d6575726c2e696f58200000000000000000000000000000000000000000000000000000000000000000'
);

const core = {
  dataHash: Crypto.Hash32ByteBase16('0000000000000000000000000000000000000000000000000000000000000000'),
  url: 'https://www.someurl.io'
};

describe('Anchor', () => {
  it('can decode Anchor from CBOR', () => {
    const anchor = Anchor.fromCbor(cbor);

    expect(anchor.url()).toEqual('https://www.someurl.io');
    expect(anchor.dataHash()).toEqual('0000000000000000000000000000000000000000000000000000000000000000');
  });

  it('can decode Anchor from Core', () => {
    const anchor = Anchor.fromCore(core);

    expect(anchor.url()).toEqual('https://www.someurl.io');
    expect(anchor.dataHash()).toEqual('0000000000000000000000000000000000000000000000000000000000000000');
  });

  it('can encode Anchor to CBOR', () => {
    const anchor = Anchor.fromCore(core);

    expect(anchor.toCbor()).toEqual(cbor);
  });

  it('can encode Anchor to Core', () => {
    const anchor = Anchor.fromCbor(cbor);

    expect(anchor.toCore()).toEqual(core);
  });

  it('can handle 128bytes Anchor', () => {
    const coreUrlLen = core.url.length;
    const url128 = `${core.url}/${'a'.repeat(128 - coreUrlLen - 1)}`;
    const core128byte: Cardano.Anchor = { ...core, url: url128 };

    const anchor = Anchor.fromCore(core128byte);
    expect(anchor.url()).toEqual(url128);

    const anchorCbor = anchor.toCbor();
    expect(Anchor.fromCbor(anchorCbor)).toEqual(anchor);
  });
});
