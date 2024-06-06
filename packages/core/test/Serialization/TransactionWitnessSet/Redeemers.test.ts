import { HexBlob } from '@cardano-sdk/util';
import { RedeemerPurpose } from '../../../src/Cardano/index.js';
import { Redeemers } from '../../../src/Serialization/index.js';
import type { Cardano } from '../../../src/index.js';

const core: Cardano.Redeemer[] = [
  {
    data: {
      cbor: HexBlob('d8799f0102030405ff'),
      constructor: 0n,
      fields: { cbor: HexBlob('9f0102030405ff'), items: [1n, 2n, 3n, 4n, 5n] }
    },
    executionUnits: { memory: 33, steps: 44 },
    index: 0,
    purpose: RedeemerPurpose.spend
  },
  {
    data: {
      cbor: HexBlob('d8799f0102030405ff'),
      constructor: 0n,
      fields: { cbor: HexBlob('9f0102030405ff'), items: [1n, 2n, 3n, 4n, 5n] }
    },
    executionUnits: { memory: 55, steps: 66 },
    index: 0,
    purpose: RedeemerPurpose.vote
  }
];

const cbor = HexBlob('82840000d8799f0102030405ff821821182c840400d8799f0102030405ff8218371842');
const cborConway = HexBlob('a282000082d8799f0102030405ff821821182c82040082d8799f0102030405ff8218371842');
// Index is an array of 3 elements instead of 2
const cborInvalidMapIndex = HexBlob('a28308000082d8799f0102030405ff821821182c82040082d8799f0102030405ff8218371842');
const cborInvalidMapValue = HexBlob('a28200008300d8799f0102030405ff821821182c82040082d8799f0102030405ff8218371842');

describe('Redeemers', () => {
  afterEach(() => (Redeemers.useConwaySerialization = false));

  it('can decode Redeemers from CBOR', () => {
    const redeemers = Redeemers.fromCbor(cbor);
    expect(redeemers.toCore()).toEqual(core);
  });

  it('can decode Redeemers from Core', () => {
    const redeemers = Redeemers.fromCore(core);
    expect(redeemers.toCbor()).toEqual(cbor);
  });

  it('can decode Redeemers from map encoded CBOR', () => {
    const redeemers = Redeemers.fromCbor(cborConway);
    // Redeemers.useConwaySerialization = true;
    expect(redeemers.toCore()).toEqual(core);
  });

  it('can encode Redeemers as map in CBOR', () => {
    const redeemers = Redeemers.fromCore(core);
    Redeemers.useConwaySerialization = true;
    expect(redeemers.toCbor()).toEqual(cborConway);
  });

  it('detects invalid map', () => {
    expect(() => Redeemers.fromCbor(cborInvalidMapIndex)).toThrowError('Redeemers map index');
    expect(() => Redeemers.fromCbor(cborInvalidMapValue)).toThrowError('Redeemers map value');
  });
});
