/* eslint-disable sonarjs/no-duplicate-string */
import { HexBlob } from '@cardano-sdk/util';
import { PoolVotingThresholds } from '../../../src/Serialization';

// Test data used in the following tests was generated with the cardano-serialization-lib

const cbor = HexBlob('84d81e820000d81e820101d81e820202d81e820303');

const core = {
  commiteeNoConfidence: { denominator: 2, numerator: 2 },
  committeeNormal: { denominator: 1, numerator: 1 },
  hardForkInitiation: { denominator: 3, numerator: 3 },
  motionNoConfidence: { denominator: 0, numerator: 0 }
};

describe('PoolVotingThresholds', () => {
  it('can decode PoolVotingThresholds from CBOR', () => {
    const thresholds = PoolVotingThresholds.fromCbor(cbor);

    expect(thresholds.committeeNoConfidence().toCore()).toEqual(core.commiteeNoConfidence);
    expect(thresholds.committeeNormal().toCore()).toEqual(core.committeeNormal);
    expect(thresholds.hardForkInitiation().toCore()).toEqual(core.hardForkInitiation);
    expect(thresholds.motionNoConfidence().toCore()).toEqual(core.motionNoConfidence);
  });

  it('can decode PoolVotingThresholds from Core', () => {
    const thresholds = PoolVotingThresholds.fromCore(core);

    expect(thresholds.committeeNoConfidence().toCore()).toEqual(core.commiteeNoConfidence);
    expect(thresholds.committeeNormal().toCore()).toEqual(core.committeeNormal);
    expect(thresholds.hardForkInitiation().toCore()).toEqual(core.hardForkInitiation);
    expect(thresholds.motionNoConfidence().toCore()).toEqual(core.motionNoConfidence);
  });

  it('can encode PoolVotingThresholds to CBOR', () => {
    const prices = PoolVotingThresholds.fromCore(core);

    expect(prices.toCbor()).toEqual(cbor);
  });

  it('can encode PoolVotingThresholds to Core', () => {
    const prices = PoolVotingThresholds.fromCbor(cbor);

    expect(prices.toCore()).toEqual(core);
  });
});
