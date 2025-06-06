/* eslint-disable sonarjs/no-duplicate-string */
import { Cardano } from '../../../src';
import { EpochNo, PlutusLanguageVersion } from '../../../src/Cardano';
import { HexBlob } from '@cardano-sdk/util';
import { ProtocolParamUpdate } from '../../../src/Serialization/Update/ProtocolParamUpdate';

// Test data used in the following tests was generated with the cardano-serialization-lib

const vasilPlutusV1Costmdls = [
  205_665, 812, 1, 1, 1000, 571, 0, 1, 1000, 24_177, 4, 1, 1000, 32, 117_366, 10_475, 4, 23_000, 100, 23_000, 100,
  23_000, 100, 23_000, 100, 23_000, 100, 23_000, 100, 100, 100, 23_000, 100, 19_537, 32, 175_354, 32, 46_417, 4,
  221_973, 511, 0, 1, 89_141, 32, 497_525, 14_068, 4, 2, 196_500, 453_240, 220, 0, 1, 1, 1000, 28_662, 4, 2, 245_000,
  216_773, 62, 1, 1_060_367, 12_586, 1, 208_512, 421, 1, 187_000, 1000, 52_998, 1, 80_436, 32, 43_249, 32, 1000, 32,
  80_556, 1, 57_667, 4, 1000, 10, 197_145, 156, 1, 197_145, 156, 1, 204_924, 473, 1, 208_896, 511, 1, 52_467, 32,
  64_832, 32, 65_493, 32, 22_558, 32, 16_563, 32, 76_511, 32, 196_500, 453_240, 220, 0, 1, 1, 69_522, 11_687, 0, 1,
  60_091, 32, 196_500, 453_240, 220, 0, 1, 1, 196_500, 453_240, 220, 0, 1, 1, 806_990, 30_482, 4, 1_927_926, 82_523, 4,
  265_318, 0, 4, 0, 85_931, 32, 205_665, 812, 1, 1, 41_182, 32, 212_342, 32, 31_220, 32, 32_696, 32, 43_357, 32, 32_247,
  32, 38_314, 32, 57_996_947, 18_975, 10
];

const vasilPlutusV2Costmdls = [
  205_665, 812, 1, 1, 1000, 571, 0, 1, 1000, 24_177, 4, 1, 1000, 32, 117_366, 10_475, 4, 23_000, 100, 23_000, 100,
  23_000, 100, 23_000, 100, 23_000, 100, 23_000, 100, 100, 100, 23_000, 100, 19_537, 32, 175_354, 32, 46_417, 4,
  221_973, 511, 0, 1, 89_141, 32, 497_525, 14_068, 4, 2, 196_500, 453_240, 220, 0, 1, 1, 1000, 28_662, 4, 2, 245_000,
  216_773, 62, 1, 1_060_367, 12_586, 1, 208_512, 421, 1, 187_000, 1000, 52_998, 1, 80_436, 32, 43_249, 32, 1000, 32,
  80_556, 1, 57_667, 4, 1000, 10, 197_145, 156, 1, 197_145, 156, 1, 204_924, 473, 1, 208_896, 511, 1, 52_467, 32,
  64_832, 32, 65_493, 32, 22_558, 32, 16_563, 32, 76_511, 32, 196_500, 453_240, 220, 0, 1, 1, 69_522, 11_687, 0, 1,
  60_091, 32, 196_500, 453_240, 220, 0, 1, 1, 196_500, 453_240, 220, 0, 1, 1, 1_159_724, 392_670, 0, 2, 806_990, 30_482,
  4, 1_927_926, 82_523, 4, 265_318, 0, 4, 0, 85_931, 32, 205_665, 812, 1, 1, 41_182, 32, 212_342, 32, 31_220, 32,
  32_696, 32, 43_357, 32, 32_247, 32, 38_314, 32, 35_892_428, 10, 57_996_947, 18_975, 10, 38_887_044, 32_947, 10
];

const cbor = HexBlob(
  'b8180018640118c80219012c03190190041901f4051a001e8480061a0bebc200071903200819038409d81e8201020ad81e8201030bd81e8201040cd81e8201050d8201582000000000000000000000000000000000000000000000000000000000000000000e820103101903e8111988b812a20098a61a0003236119032c01011903e819023b00011903e8195e7104011903e818201a0001ca761928eb041959d818641959d818641959d818641959d818641959d818641959d81864186418641959d81864194c5118201a0002acfa182019b551041a000363151901ff00011a00015c3518201a000797751936f404021a0002ff941a0006ea7818dc0001011903e8196ff604021a0003bd081a00034ec5183e011a00102e0f19312a011a00032e801901a5011a0002da781903e819cf06011a00013a34182019a8f118201903e818201a00013aac0119e143041903e80a1a00030219189c011a00030219189c011a0003207c1901d9011a000330001901ff0119ccf3182019fd40182019ffd5182019581e18201940b318201a00012adf18201a0002ff941a0006ea7818dc0001011a00010f92192da7000119eabb18201a0002ff941a0006ea7818dc0001011a0002ff941a0006ea7818dc0001011a000c504e197712041a001d6af61a0001425b041a00040c660004001a00014fab18201a0003236119032c010119a0de18201a00033d7618201979f41820197fb8182019a95d1820197df718201995aa18201a0374f693194a1f0a0198af1a0003236119032c01011903e819023b00011903e8195e7104011903e818201a0001ca761928eb041959d818641959d818641959d818641959d818641959d818641959d81864186418641959d81864194c5118201a0002acfa182019b551041a000363151901ff00011a00015c3518201a000797751936f404021a0002ff941a0006ea7818dc0001011903e8196ff604021a0003bd081a00034ec5183e011a00102e0f19312a011a00032e801901a5011a0002da781903e819cf06011a00013a34182019a8f118201903e818201a00013aac0119e143041903e80a1a00030219189c011a00030219189c011a0003207c1901d9011a000330001901ff0119ccf3182019fd40182019ffd5182019581e18201940b318201a00012adf18201a0002ff941a0006ea7818dc0001011a00010f92192da7000119eabb18201a0002ff941a0006ea7818dc0001011a0002ff941a0006ea7818dc0001011a0011b22c1a0005fdde00021a000c504e197712041a001d6af61a0001425b041a00040c660004001a00014fab18201a0003236119032c010119a0de18201a00033d7618201979f41820197fb8182019a95d1820197df718201995aa18201a0223accc0a1a0374f693194a1f0a1a02515e841980b30a1382d81e820102d81e82010214821b00000001000000001b000000010000000015821b00000001000000001b0000000100000000161903ba1719035418181864'
);

const conwayCbor = HexBlob(
  'b8210018640118c80219012c03190190041901f4051a001e8480061a0bebc200071903200819038409d81e8201020ad81e8201030bd81e8201040cd81e8201050d8201582000000000000000000000000000000000000000000000000000000000000000000e820103101903e8111988b812a20098a61a0003236119032c01011903e819023b00011903e8195e7104011903e818201a0001ca761928eb041959d818641959d818641959d818641959d818641959d818641959d81864186418641959d81864194c5118201a0002acfa182019b551041a000363151901ff00011a00015c3518201a000797751936f404021a0002ff941a0006ea7818dc0001011903e8196ff604021a0003bd081a00034ec5183e011a00102e0f19312a011a00032e801901a5011a0002da781903e819cf06011a00013a34182019a8f118201903e818201a00013aac0119e143041903e80a1a00030219189c011a00030219189c011a0003207c1901d9011a000330001901ff0119ccf3182019fd40182019ffd5182019581e18201940b318201a00012adf18201a0002ff941a0006ea7818dc0001011a00010f92192da7000119eabb18201a0002ff941a0006ea7818dc0001011a0002ff941a0006ea7818dc0001011a000c504e197712041a001d6af61a0001425b041a00040c660004001a00014fab18201a0003236119032c010119a0de18201a00033d7618201979f41820197fb8182019a95d1820197df718201995aa18201a0374f693194a1f0a0198af1a0003236119032c01011903e819023b00011903e8195e7104011903e818201a0001ca761928eb041959d818641959d818641959d818641959d818641959d818641959d81864186418641959d81864194c5118201a0002acfa182019b551041a000363151901ff00011a00015c3518201a000797751936f404021a0002ff941a0006ea7818dc0001011903e8196ff604021a0003bd081a00034ec5183e011a00102e0f19312a011a00032e801901a5011a0002da781903e819cf06011a00013a34182019a8f118201903e818201a00013aac0119e143041903e80a1a00030219189c011a00030219189c011a0003207c1901d9011a000330001901ff0119ccf3182019fd40182019ffd5182019581e18201940b318201a00012adf18201a0002ff941a0006ea7818dc0001011a00010f92192da7000119eabb18201a0002ff941a0006ea7818dc0001011a0002ff941a0006ea7818dc0001011a0011b22c1a0005fdde00021a000c504e197712041a001d6af61a0001425b041a00040c660004001a00014fab18201a0003236119032c010119a0de18201a00033d7618201979f41820197fb8182019a95d1820197df718201995aa18201a0223accc0a1a0374f693194a1f0a1a02515e841980b30a1382d81e820102d81e82010214821b00000001000000001b000000010000000015821b00000001000000001b0000000100000000161903ba1719035418181864181985d81e820000d81e820101d81e820202d81e820303d81e820101181a8ad81e820000d81e820101d81e820202d81e820303d81e820404d81e820505d81e820606d81e820707d81e820808d81e820909181b1864181c18c8181d19012c181e1903e8181f1907d018201913881821d81e82185902'
);

// CBOR was generated from the SDK and validated against CSL
const numericFieldsSetToZeroCbor = HexBlob(
  'b82100000100020003000400050006000700080009d81e8201020ad81e8201030bd81e8201040cd81e8201050d8201582000000000000000000000000000000000000000000000000000000000000000000e8201031000110012a20098a61a0003236119032c01011903e819023b00011903e8195e7104011903e818201a0001ca761928eb041959d818641959d818641959d818641959d818641959d818641959d81864186418641959d81864194c5118201a0002acfa182019b551041a000363151901ff00011a00015c3518201a000797751936f404021a0002ff941a0006ea7818dc0001011903e8196ff604021a0003bd081a00034ec5183e011a00102e0f19312a011a00032e801901a5011a0002da781903e819cf06011a00013a34182019a8f118201903e818201a00013aac0119e143041903e80a1a00030219189c011a00030219189c011a0003207c1901d9011a000330001901ff0119ccf3182019fd40182019ffd5182019581e18201940b318201a00012adf18201a0002ff941a0006ea7818dc0001011a00010f92192da7000119eabb18201a0002ff941a0006ea7818dc0001011a0002ff941a0006ea7818dc0001011a000c504e197712041a001d6af61a0001425b041a00040c660004001a00014fab18201a0003236119032c010119a0de18201a00033d7618201979f41820197fb8182019a95d1820197df718201995aa18201a0374f693194a1f0a0198af1a0003236119032c01011903e819023b00011903e8195e7104011903e818201a0001ca761928eb041959d818641959d818641959d818641959d818641959d818641959d81864186418641959d81864194c5118201a0002acfa182019b551041a000363151901ff00011a00015c3518201a000797751936f404021a0002ff941a0006ea7818dc0001011903e8196ff604021a0003bd081a00034ec5183e011a00102e0f19312a011a00032e801901a5011a0002da781903e819cf06011a00013a34182019a8f118201903e818201a00013aac0119e143041903e80a1a00030219189c011a00030219189c011a0003207c1901d9011a000330001901ff0119ccf3182019fd40182019ffd5182019581e18201940b318201a00012adf18201a0002ff941a0006ea7818dc0001011a00010f92192da7000119eabb18201a0002ff941a0006ea7818dc0001011a0002ff941a0006ea7818dc0001011a0011b22c1a0005fdde00021a000c504e197712041a001d6af61a0001425b041a00040c660004001a00014fab18201a0003236119032c010119a0de18201a00033d7618201979f41820197fb8182019a95d1820197df718201995aa18201a0223accc0a1a0374f693194a1f0a1a02515e841980b30a1382d81e820102d81e82010214821b00000001000000001b000000010000000015821b00000001000000001b000000010000000016001700181800181985d81e820000d81e820101d81e820202d81e820303d81e820101181a8ad81e820000d81e820101d81e820202d81e820303d81e820404d81e820505d81e820606d81e820707d81e820808d81e820909181b00181c00181d00181e00181f001820001821d81e82185902'
);

const core = {
  coinsPerUtxoByte: 35_000,
  collateralPercentage: 852,
  costModels: new Map([
    [PlutusLanguageVersion.V1, vasilPlutusV1Costmdls],
    [PlutusLanguageVersion.V2, vasilPlutusV2Costmdls]
  ]),
  decentralizationParameter: '0.2',
  desiredNumberOfPools: 900,
  extraEntropy: '0000000000000000000000000000000000000000000000000000000000000000',
  maxBlockBodySize: 300,
  maxBlockHeaderSize: 500,
  maxCollateralInputs: 100,
  maxExecutionUnitsPerBlock: { memory: 4_294_967_296, steps: 4_294_967_296 },
  maxExecutionUnitsPerTransaction: { memory: 4_294_967_296, steps: 4_294_967_296 },
  maxTxSize: 400,
  maxValueSize: 954,
  minFeeCoefficient: 100,
  minFeeConstant: 200,
  minPoolCost: 1000,
  monetaryExpansion: '0.3333333333333333',
  poolDeposit: 200_000_000,
  poolInfluence: '0.5',
  poolRetirementEpochBound: 800,
  prices: { memory: 0.5, steps: 0.5 },
  protocolVersion: { major: 1, minor: 3 },
  stakeKeyDeposit: 2_000_000,
  treasuryExpansion: '0.25'
};

const conwayCore: Cardano.ProtocolParametersUpdate = {
  coinsPerUtxoByte: 35_000,
  collateralPercentage: 852,
  committeeTermLimit: EpochNo(200),
  costModels: new Map([
    [PlutusLanguageVersion.V1, vasilPlutusV1Costmdls],
    [PlutusLanguageVersion.V2, vasilPlutusV2Costmdls]
  ]),
  dRepDeposit: 2000,
  dRepInactivityPeriod: EpochNo(5000),
  dRepVotingThresholds: {
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
  },
  decentralizationParameter: '0.2',
  desiredNumberOfPools: 900,
  extraEntropy: '0000000000000000000000000000000000000000000000000000000000000000',
  governanceActionDeposit: 1000,
  governanceActionValidityPeriod: EpochNo(300),
  maxBlockBodySize: 300,
  maxBlockHeaderSize: 500,
  maxCollateralInputs: 100,
  maxExecutionUnitsPerBlock: { memory: 4_294_967_296, steps: 4_294_967_296 },
  maxExecutionUnitsPerTransaction: { memory: 4_294_967_296, steps: 4_294_967_296 },
  maxTxSize: 400,
  maxValueSize: 954,
  minCommitteeSize: 100,
  minFeeCoefficient: 100,
  minFeeConstant: 200,
  minFeeRefScriptCostPerByte: '44.5',
  minPoolCost: 1000,
  monetaryExpansion: '0.3333333333333333',
  poolDeposit: 200_000_000,
  poolInfluence: '0.5',
  poolRetirementEpochBound: 800,
  poolVotingThresholds: {
    committeeNoConfidence: { denominator: 2, numerator: 2 },
    committeeNormal: { denominator: 1, numerator: 1 },
    hardForkInitiation: { denominator: 3, numerator: 3 },
    motionNoConfidence: { denominator: 0, numerator: 0 },
    securityRelevantParamVotingThreshold: { denominator: 1, numerator: 1 }
  },
  prices: { memory: 0.5, steps: 0.5 },
  protocolVersion: { major: 1, minor: 3 },
  stakeKeyDeposit: 2_000_000,
  treasuryExpansion: '0.25'
};

const numericFieldsSetToZeroCore: Cardano.ProtocolParametersUpdate = {
  ...conwayCore,
  coinsPerUtxoByte: 0,
  collateralPercentage: 0,
  committeeTermLimit: EpochNo(0),
  dRepDeposit: 0,
  dRepInactivityPeriod: EpochNo(0),
  desiredNumberOfPools: 0,
  governanceActionDeposit: 0,
  governanceActionValidityPeriod: EpochNo(0),
  maxBlockBodySize: 0,
  maxBlockHeaderSize: 0,
  maxCollateralInputs: 0,
  maxTxSize: 0,
  maxValueSize: 0,
  minCommitteeSize: 0,
  minFeeCoefficient: 0,
  minFeeConstant: 0,
  minPoolCost: 0,
  poolDeposit: 0,
  poolRetirementEpochBound: 0,
  stakeKeyDeposit: 0
};

describe('ProtocolParamUpdate', () => {
  // eslint-disable-next-line max-statements
  it('can decode ProtocolParamUpdate from CBOR', () => {
    const proposedParams = ProtocolParamUpdate.fromCbor(cbor);

    const pv1 = proposedParams.costModels()!.get(PlutusLanguageVersion.V1);
    const pv2 = proposedParams.costModels()!.get(PlutusLanguageVersion.V2);

    expect(pv1).toBeDefined();
    expect(pv2).toBeDefined();

    for (const [op, element] of vasilPlutusV1Costmdls.entries()) expect(pv1?.get(op)).toEqual(element);
    for (const [op, element] of vasilPlutusV2Costmdls.entries()) expect(pv2?.get(op)).toEqual(element);

    expect(proposedParams.minFeeA()).toEqual(100n);
    expect(proposedParams.minFeeB()).toEqual(200n);
    expect(proposedParams.maxBlockBodySize()).toEqual(300);
    expect(proposedParams.maxTxSize()).toEqual(400);
    expect(proposedParams.maxBlockHeaderSize()).toEqual(500);
    expect(proposedParams.keyDeposit()).toEqual(2_000_000n);
    expect(proposedParams.poolDeposit()).toEqual(200_000_000n);
    expect(proposedParams.maxEpoch()).toEqual(800);
    expect(proposedParams.nOpt()).toEqual(900);
    expect(proposedParams.poolPledgeInfluence()?.toFloat()).toEqual(0.5);
    expect(proposedParams.expansionRate()?.toFloat()).toEqual(0.333_333_333_333_333_3);
    expect(proposedParams.treasuryGrowthRate()?.toFloat()).toEqual(0.25);
    expect(proposedParams.d()?.toFloat()).toEqual(0.2);
    expect(proposedParams.extraEntropy()).toEqual(
      HexBlob('0000000000000000000000000000000000000000000000000000000000000000')
    );
    expect(proposedParams.protocolVersion()?.toCore()).toEqual({ major: 1, minor: 3 });
    expect(proposedParams.minPoolCost()).toEqual(1000n);
    expect(proposedParams.adaPerUtxoByte()).toEqual(35_000n);
    expect(proposedParams.maxTxExUnits()?.toCore()).toEqual({ memory: 4_294_967_296, steps: 4_294_967_296 });
    expect(proposedParams.executionCosts()?.toCore()).toEqual({ memory: 0.5, steps: 0.5 });
    expect(proposedParams.maxTxExUnits()?.toCore()).toEqual({ memory: 4_294_967_296, steps: 4_294_967_296 });
    expect(proposedParams.maxBlockExUnits()?.toCore()).toEqual({ memory: 4_294_967_296, steps: 4_294_967_296 });
    expect(proposedParams.maxValueSize()).toEqual(954);
    expect(proposedParams.collateralPercentage()).toEqual(852);
    expect(proposedParams.maxCollateralInputs()).toEqual(100);
  });

  // eslint-disable-next-line max-statements
  it('can decode Conway era ProtocolParamUpdate from CBOR', () => {
    const proposedParams = ProtocolParamUpdate.fromCbor(conwayCbor);

    const pv1 = proposedParams.costModels()!.get(PlutusLanguageVersion.V1);
    const pv2 = proposedParams.costModels()!.get(PlutusLanguageVersion.V2);

    expect(pv1).toBeDefined();
    expect(pv2).toBeDefined();

    for (const [op, element] of vasilPlutusV1Costmdls.entries()) expect(pv1?.get(op)).toEqual(element);
    for (const [op, element] of vasilPlutusV2Costmdls.entries()) expect(pv2?.get(op)).toEqual(element);

    expect(proposedParams.minFeeA()).toEqual(100n);
    expect(proposedParams.minFeeB()).toEqual(200n);
    expect(proposedParams.maxBlockBodySize()).toEqual(300);
    expect(proposedParams.maxTxSize()).toEqual(400);
    expect(proposedParams.maxBlockHeaderSize()).toEqual(500);
    expect(proposedParams.keyDeposit()).toEqual(2_000_000n);
    expect(proposedParams.poolDeposit()).toEqual(200_000_000n);
    expect(proposedParams.maxEpoch()).toEqual(800);
    expect(proposedParams.nOpt()).toEqual(900);
    expect(proposedParams.poolPledgeInfluence()?.toFloat()).toEqual(0.5);
    expect(proposedParams.expansionRate()?.toFloat()).toEqual(0.333_333_333_333_333_3);
    expect(proposedParams.treasuryGrowthRate()?.toFloat()).toEqual(0.25);
    expect(proposedParams.d()?.toFloat()).toEqual(0.2);
    expect(proposedParams.extraEntropy()).toEqual(
      HexBlob('0000000000000000000000000000000000000000000000000000000000000000')
    );
    expect(proposedParams.protocolVersion()?.toCore()).toEqual({ major: 1, minor: 3 });
    expect(proposedParams.minPoolCost()).toEqual(1000n);
    expect(proposedParams.adaPerUtxoByte()).toEqual(35_000n);
    expect(proposedParams.maxTxExUnits()?.toCore()).toEqual({ memory: 4_294_967_296, steps: 4_294_967_296 });
    expect(proposedParams.executionCosts()?.toCore()).toEqual({ memory: 0.5, steps: 0.5 });
    expect(proposedParams.maxTxExUnits()?.toCore()).toEqual({ memory: 4_294_967_296, steps: 4_294_967_296 });
    expect(proposedParams.maxBlockExUnits()?.toCore()).toEqual({ memory: 4_294_967_296, steps: 4_294_967_296 });
    expect(proposedParams.maxValueSize()).toEqual(954);
    expect(proposedParams.collateralPercentage()).toEqual(852);
    expect(proposedParams.maxCollateralInputs()).toEqual(100);

    // Conway fields
    expect(proposedParams.minCommitteeSize()).toEqual(100);
    expect(proposedParams.committeeTermLimit()).toEqual(200);
    expect(proposedParams.governanceActionValidityPeriod()).toEqual(300);
    expect(proposedParams.governanceActionDeposit()).toEqual(1000);
    expect(proposedParams.drepDeposit()).toEqual(2000);
    expect(proposedParams.drepInactivityPeriod()).toEqual(5000);
    expect(proposedParams.drepVotingThresholds()?.toCore()).toEqual({
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
    });
    expect(proposedParams.poolVotingThresholds()?.toCore()).toEqual({
      committeeNoConfidence: { denominator: 2, numerator: 2 },
      committeeNormal: { denominator: 1, numerator: 1 },
      hardForkInitiation: { denominator: 3, numerator: 3 },
      motionNoConfidence: { denominator: 0, numerator: 0 },
      securityRelevantParamVotingThreshold: { denominator: 1, numerator: 1 }
    });
    expect(proposedParams.minFeeRefScriptCostPerByte()?.toFloat()).toEqual(44.5);
  });

  // eslint-disable-next-line max-statements
  it('can decode ProtocolParamUpdate from Core', () => {
    const proposedParams = ProtocolParamUpdate.fromCore(core);

    const pv1 = proposedParams.costModels()!.get(PlutusLanguageVersion.V1);
    const pv2 = proposedParams.costModels()!.get(PlutusLanguageVersion.V2);

    expect(pv1).toBeDefined();
    expect(pv2).toBeDefined();

    for (const [op, element] of vasilPlutusV1Costmdls.entries()) expect(pv1?.get(op)).toEqual(element);
    for (const [op, element] of vasilPlutusV2Costmdls.entries()) expect(pv2?.get(op)).toEqual(element);

    expect(proposedParams.minFeeA()).toEqual(100n);
    expect(proposedParams.minFeeB()).toEqual(200n);
    expect(proposedParams.maxBlockBodySize()).toEqual(300);
    expect(proposedParams.maxTxSize()).toEqual(400);
    expect(proposedParams.maxBlockHeaderSize()).toEqual(500);
    expect(proposedParams.keyDeposit()).toEqual(2_000_000n);
    expect(proposedParams.poolDeposit()).toEqual(200_000_000n);
    expect(proposedParams.maxEpoch()).toEqual(800);
    expect(proposedParams.nOpt()).toEqual(900);
    expect(proposedParams.poolPledgeInfluence()?.toFloat()).toEqual(0.5);
    expect(proposedParams.expansionRate()?.toFloat()).toEqual(0.333_333_333_333_333_3);
    expect(proposedParams.treasuryGrowthRate()?.toFloat()).toEqual(0.25);
    expect(proposedParams.d()?.toFloat()).toEqual(0.2);
    expect(proposedParams.extraEntropy()).toEqual(
      HexBlob('0000000000000000000000000000000000000000000000000000000000000000')
    );
    expect(proposedParams.protocolVersion()?.toCore()).toEqual({ major: 1, minor: 3 });
    expect(proposedParams.minPoolCost()).toEqual(1000n);
    expect(proposedParams.adaPerUtxoByte()).toEqual(35_000n);
    expect(proposedParams.maxTxExUnits()?.toCore()).toEqual({ memory: 4_294_967_296, steps: 4_294_967_296 });
    expect(proposedParams.executionCosts()?.toCore()).toEqual({ memory: 0.5, steps: 0.5 });
    expect(proposedParams.maxTxExUnits()?.toCore()).toEqual({ memory: 4_294_967_296, steps: 4_294_967_296 });
    expect(proposedParams.maxBlockExUnits()?.toCore()).toEqual({ memory: 4_294_967_296, steps: 4_294_967_296 });
    expect(proposedParams.maxValueSize()).toEqual(954);
    expect(proposedParams.collateralPercentage()).toEqual(852);
    expect(proposedParams.maxCollateralInputs()).toEqual(100);
  });

  it('can encode ProtocolParamUpdate to CBOR', () => {
    const protocolParamUpdate = ProtocolParamUpdate.fromCore(core);

    expect(protocolParamUpdate.toCbor()).toEqual(cbor);
  });

  it('can encode Conway ProtocolParamUpdate to CBOR', () => {
    const protocolParamUpdate = ProtocolParamUpdate.fromCore(conwayCore);

    expect(protocolParamUpdate.toCbor()).toEqual(conwayCbor);
  });

  it('can encode ProtocolParamUpdate to Core', () => {
    const protocolParamUpdate = ProtocolParamUpdate.fromCbor(cbor);

    expect(protocolParamUpdate.toCore()).toEqual(core);
  });

  it('can encode ProtocolParamUpdate with numeric fields set to 0 to CBOR', () => {
    const protocolParamUpdate = ProtocolParamUpdate.fromCore(numericFieldsSetToZeroCore);
    expect(protocolParamUpdate.toCbor()).toEqual(numericFieldsSetToZeroCbor);
  });

  it('can encode ProtocolParamUpdate with numeric fields set to 0 to Core', () => {
    const protocolParamUpdate = ProtocolParamUpdate.fromCbor(numericFieldsSetToZeroCbor);
    expect(protocolParamUpdate.toCore()).toEqual(numericFieldsSetToZeroCore);
  });
});
