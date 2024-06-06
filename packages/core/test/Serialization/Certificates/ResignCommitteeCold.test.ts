/* eslint-disable sonarjs/no-duplicate-string */
import { HexBlob } from '@cardano-sdk/util';
import { ResignCommitteeCold } from '../../../src/Serialization/index.js';
import type * as Cardano from '../../../src/Cardano/index.js';

// Test data used in the following tests was generated with the cardano-serialization-lib
const cborWithoutAnchor = HexBlob('830f8200581c00000000000000000000000000000000000000000000000000000000f6');

const coreWithoutAnchor = {
  __typename: 'ResignCommitteeColdCertificate',
  anchor: null,
  coldCredential: {
    hash: '00000000000000000000000000000000000000000000000000000000',
    type: 0
  }
} as Cardano.ResignCommitteeColdCertificate;

const cborWithAnchor = HexBlob(
  '830f8200581c00000000000000000000000000000000000000000000000000000000827668747470733a2f2f7777772e736f6d6575726c2e696f58200000000000000000000000000000000000000000000000000000000000000000'
);

const coreWithAnchor = {
  __typename: 'ResignCommitteeColdCertificate',
  anchor: {
    dataHash: '0000000000000000000000000000000000000000000000000000000000000000',
    url: 'https://www.someurl.io'
  },
  coldCredential: {
    hash: '00000000000000000000000000000000000000000000000000000000',
    type: 0
  }
} as Cardano.ResignCommitteeColdCertificate;

describe('ResignCommitteeCold', () => {
  it('can encode ResignCommitteeCold to CBOR', () => {
    const cert = ResignCommitteeCold.fromCore(coreWithoutAnchor);

    expect(cert.toCbor()).toEqual(cborWithoutAnchor);
  });

  it('can encode ResignCommitteeCold to Core', () => {
    const cert = ResignCommitteeCold.fromCbor(cborWithoutAnchor);

    expect(cert.toCore()).toEqual(coreWithoutAnchor);
  });

  it('can encode ResignCommitteeCold to CBOR with optional anchor', () => {
    const cert = ResignCommitteeCold.fromCore(coreWithAnchor);

    expect(cert.toCbor()).toEqual(cborWithAnchor);
  });

  it('can encode ResignCommitteeCold to Core with optional anchor', () => {
    const cert = ResignCommitteeCold.fromCbor(cborWithAnchor);

    expect(cert.toCore()).toEqual(coreWithAnchor);
  });
});
