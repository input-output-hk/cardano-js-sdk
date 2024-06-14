/* eslint-disable sonarjs/no-duplicate-string */
import { DrepVotingThresholds } from '../../../src/Serialization';
import { HexBlob } from '@cardano-sdk/util';

// Test data used in the following tests was generated with the cardano-serialization-lib

const cbor = HexBlob(
  '8ad81e820000d81e820101d81e820202d81e820303d81e820404d81e820505d81e820606d81e820707d81e820808d81e820909'
);

const core = {
  committeeNoConfidence: { denominator: 2, numerator: 2 },
  committeeNormal: { denominator: 1, numerator: 1 },
  hardForkInitiation: { denominator: 4, numerator: 4 },
  motionNoConfidence: { denominator: 0, numerator: 0 },
  ppEconomicGroup: { denominator: 6, numerator: 6 },
  ppGovernanceGroup: { denominator: 8, numerator: 8 },
  ppNetworkGroup: { denominator: 5, numerator: 5 },
  ppTechnicalGroup: { denominator: 7, numerator: 7 },
  treasuryWithdrawal: { denominator: 9, numerator: 9 },
  updateConstitution: { denominator: 3, numerator: 3 }
};

describe('DrepVotingThresholds', () => {
  it('can decode DrepVotingThresholds from CBOR', () => {
    const thresholds = DrepVotingThresholds.fromCbor(cbor);

    expect(thresholds.committeeNoConfidence().toCore()).toEqual(core.committeeNoConfidence);
    expect(thresholds.committeeNormal().toCore()).toEqual(core.committeeNormal);
    expect(thresholds.hardForkInitiation().toCore()).toEqual(core.hardForkInitiation);
    expect(thresholds.motionNoConfidence().toCore()).toEqual(core.motionNoConfidence);
    expect(thresholds.ppEconomicGroup().toCore()).toEqual(core.ppEconomicGroup);
    expect(thresholds.ppGovernanceGroup().toCore()).toEqual(core.ppGovernanceGroup);
    expect(thresholds.ppNetworkGroup().toCore()).toEqual(core.ppNetworkGroup);
    expect(thresholds.ppTechnicalGroup().toCore()).toEqual(core.ppTechnicalGroup);
    expect(thresholds.treasuryWithdrawal().toCore()).toEqual(core.treasuryWithdrawal);
    expect(thresholds.updateConstitution().toCore()).toEqual(core.updateConstitution);
  });

  it('can decode DrepVotingThresholds from Core', () => {
    const thresholds = DrepVotingThresholds.fromCore(core);

    expect(thresholds.committeeNoConfidence().toCore()).toEqual(core.committeeNoConfidence);
    expect(thresholds.committeeNormal().toCore()).toEqual(core.committeeNormal);
    expect(thresholds.hardForkInitiation().toCore()).toEqual(core.hardForkInitiation);
    expect(thresholds.motionNoConfidence().toCore()).toEqual(core.motionNoConfidence);
    expect(thresholds.ppEconomicGroup().toCore()).toEqual(core.ppEconomicGroup);
    expect(thresholds.ppGovernanceGroup().toCore()).toEqual(core.ppGovernanceGroup);
    expect(thresholds.ppNetworkGroup().toCore()).toEqual(core.ppNetworkGroup);
    expect(thresholds.ppTechnicalGroup().toCore()).toEqual(core.ppTechnicalGroup);
    expect(thresholds.treasuryWithdrawal().toCore()).toEqual(core.treasuryWithdrawal);
    expect(thresholds.updateConstitution().toCore()).toEqual(core.updateConstitution);
  });

  it('can encode DrepVotingThresholds to CBOR', () => {
    const prices = DrepVotingThresholds.fromCore(core);

    expect(prices.toCbor()).toEqual(cbor);
  });

  it('can encode DrepVotingThresholds to Core', () => {
    const prices = DrepVotingThresholds.fromCbor(cbor);

    expect(prices.toCore()).toEqual(core);
  });
});
