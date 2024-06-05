/* eslint-disable sonarjs/no-duplicate-string */
import * as Cardano from '../../../src/Cardano';
import { HexBlob } from '@cardano-sdk/util';
import { Redeemer, RedeemerTag } from '../../../src/Serialization';
import { RedeemerPurpose } from '../../../src/Cardano';

// Test data used in the following tests was generated with the cardano-serialization-lib
const core = {
  data: {
    cbor: HexBlob('d8799f0102030405ff'),
    constructor: 0n,
    fields: { cbor: HexBlob('9f0102030405ff'), items: [1n, 2n, 3n, 4n, 5n] }
  },
  executionUnits: { memory: 147_852_369_874_563, steps: 369_852_147_852_369 },
  index: 0,
  purpose: RedeemerPurpose.spend
} as Cardano.Redeemer;

describe('Redeemer', () => {
  it('can decode Redeemer from CBOR', () => {
    const cbor = HexBlob('840000d8799f0102030405ff821b000086788ffc4e831b00015060e9e46451');

    const redeemer = Redeemer.fromCbor(cbor);

    expect(redeemer.data().toCore()).toEqual({
      cbor: HexBlob('d8799f0102030405ff'),
      constructor: 0n,
      fields: { cbor: HexBlob('9f0102030405ff'), items: [1n, 2n, 3n, 4n, 5n] }
    });
    expect(redeemer.exUnits().toCore()).toEqual({ memory: 147_852_369_874_563, steps: 369_852_147_852_369 });
    expect(redeemer.tag()).toEqual(RedeemerTag.Spend);
    expect(redeemer.index()).toEqual(0n);
  });

  it('can decode Redeemer from Core', () => {
    const redeemer = Redeemer.fromCore(core);

    expect(redeemer.data().toCore()).toEqual({
      cbor: HexBlob('d8799f0102030405ff'),
      constructor: 0n,
      fields: { cbor: HexBlob('9f0102030405ff'), items: [1n, 2n, 3n, 4n, 5n] }
    });
    expect(redeemer.exUnits().toCore()).toEqual({ memory: 147_852_369_874_563, steps: 369_852_147_852_369 });
    expect(redeemer.tag()).toEqual(RedeemerTag.Spend);
    expect(redeemer.index()).toEqual(0n);
  });

  it('can compute correct hash', () => {
    const redeemer = Redeemer.fromCore(core);

    // Hash was generated with the CSL
    expect(redeemer.hash()).toEqual('cfa253874f5f17b01d44e33377124e12fa0e7c8bcd88067fb9edb8c5f5ec662e');
  });

  describe('Redeemer tag: Spend', () => {
    const spendCore = { ...core, purpose: RedeemerPurpose.spend };
    const spendCbor = HexBlob('840000d8799f0102030405ff821b000086788ffc4e831b00015060e9e46451');

    it('can encode Redeemer to CBOR', () => {
      const redeemer = Redeemer.fromCore(spendCore);
      expect(redeemer.toCbor()).toEqual(spendCbor);
    });

    it('can encode Redeemer to Core', () => {
      const redeemer = Redeemer.fromCbor(spendCbor);
      expect(redeemer.toCore()).toEqual(spendCore);
    });
  });

  describe('Redeemer tag: Mint', () => {
    const mintCore = { ...core, purpose: RedeemerPurpose.mint };
    const mintCbor = HexBlob('840100d8799f0102030405ff821b000086788ffc4e831b00015060e9e46451');

    it('can encode Redeemer to CBOR', () => {
      const redeemer = Redeemer.fromCore(mintCore);
      expect(redeemer.toCbor()).toEqual(mintCbor);
    });

    it('can encode Redeemer to Core', () => {
      const redeemer = Redeemer.fromCbor(mintCbor);
      expect(redeemer.toCore()).toEqual(mintCore);
    });
  });

  describe('Redeemer tag: Cert', () => {
    const certCore = { ...core, purpose: RedeemerPurpose.certificate };
    const certCbor = HexBlob('840200d8799f0102030405ff821b000086788ffc4e831b00015060e9e46451');

    it('can encode Redeemer to CBOR', () => {
      const redeemer = Redeemer.fromCore(certCore);
      expect(redeemer.toCbor()).toEqual(certCbor);
    });

    it('can encode Redeemer to Core', () => {
      const redeemer = Redeemer.fromCbor(certCbor);
      expect(redeemer.toCore()).toEqual(certCore);
    });
  });

  describe('Redeemer tag: Reward', () => {
    const certCore = { ...core, purpose: RedeemerPurpose.withdrawal };
    const certCbor = HexBlob('840300d8799f0102030405ff821b000086788ffc4e831b00015060e9e46451');

    it('can encode Redeemer to CBOR', () => {
      const redeemer = Redeemer.fromCore(certCore);
      expect(redeemer.toCbor()).toEqual(certCbor);
    });

    it('can encode Redeemer to Core', () => {
      const redeemer = Redeemer.fromCbor(certCbor);
      expect(redeemer.toCore()).toEqual(certCore);
    });
  });
});
