/* eslint-disable max-params */
import { CborReader, CborWriter } from '../CBOR/index.js';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { UnitInterval } from '../Common/index.js';
import type * as Cardano from '../../Cardano/index.js';

const EX_DREP_VOTING_THRESHOLDS_SIZE = 10;

/**
 * Governance actions are ratified through on-chain voting. Different
 * kinds of governance actions have different ratification requirements. One of those
 * requirements is the approval of the action by DReps. These thresholds specify
 * the percentage of the total active voting stake that must be meet by the DReps who vote Yes
 * for the approval to be successful.
 */
export class DrepVotingThresholds {
  #motionNoConfidence: UnitInterval;
  #committeeNormal: UnitInterval;
  #committeeNoConfidence: UnitInterval;
  #updateConstitution: UnitInterval;
  #hardForkInitiation: UnitInterval;
  #ppNetworkGroup: UnitInterval;
  #ppEconomicGroup: UnitInterval;
  #ppTechnicalGroup: UnitInterval;
  #ppGovernanceGroup: UnitInterval;
  #treasuryWithdrawal: UnitInterval;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initialize a new instance of the DrepVotingThresholds class.
   *
   * @param motionNoConfidence Quorum threshold (percentage of the total active voting stake) that
   * needs to be meet for a Motion of no-confidence to be enacted.
   * @param committeeNormal Quorum threshold (percentage of the total active voting stake) that needs
   * to be meet for a new committee to be elected if the constitutional committee is in a state of confidence.
   * @param committeeNoConfidence Quorum threshold (percentage of the total active voting stake) that needs
   * to be meet for a new committee to be elected if the constitutional committee is in a state of no-confidence.
   * @param updateConstitution Quorum threshold (percentage of the total active voting stake) that
   * needs to be meet for a modification to the Constitution to be enacted.
   * @param hardForkInitiation Quorum threshold (percentage of the total active voting stake) that
   * needs to be meet to trigger a non-backwards compatible upgrade of the network (requires a prior software upgrade).
   * @param ppNetworkGroup Quorum threshold (percentage of the total active voting stake) that
   * needs to be meet to update the protocol parameters in the network group.
   * @param ppEconomicGroup Quorum threshold (percentage of the total active voting stake) that
   * needs to be meet to update the protocol parameters in the economic group.
   * @param ppTechnicalGroup Quorum threshold (percentage of the total active voting stake) that
   * needs to be meet to update the protocol parameters in the technical group.
   * @param ppGovernanceGroup Quorum threshold (percentage of the total active voting stake) that
   * needs to be meet to update the protocol parameters in the governance group.
   * @param treasuryWithdrawal Quorum threshold (percentage of the total active voting stake) that
   * needs to withdrawal from the treasury.
   */
  constructor(
    motionNoConfidence: UnitInterval,
    committeeNormal: UnitInterval,
    committeeNoConfidence: UnitInterval,
    updateConstitution: UnitInterval,
    hardForkInitiation: UnitInterval,
    ppNetworkGroup: UnitInterval,
    ppEconomicGroup: UnitInterval,
    ppTechnicalGroup: UnitInterval,
    ppGovernanceGroup: UnitInterval,
    treasuryWithdrawal: UnitInterval
  ) {
    this.#motionNoConfidence = motionNoConfidence;
    this.#committeeNormal = committeeNormal;
    this.#committeeNoConfidence = committeeNoConfidence;
    this.#updateConstitution = updateConstitution;
    this.#hardForkInitiation = hardForkInitiation;
    this.#ppNetworkGroup = ppNetworkGroup;
    this.#ppEconomicGroup = ppEconomicGroup;
    this.#ppTechnicalGroup = ppTechnicalGroup;
    this.#ppGovernanceGroup = ppGovernanceGroup;
    this.#treasuryWithdrawal = treasuryWithdrawal;
  }

  /**
   * Serializes a DrepVotingThresholds into CBOR format.
   *
   * @returns The DrepVotingThresholds in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // drep_voting_thresholds =
    //   [ unit_interval ; motion no confidence
    //   , unit_interval ; committee normal
    //   , unit_interval ; committee no confidence
    //   , unit_interval ; update constitution
    //   , unit_interval ; hard fork initiation
    //   , unit_interval ; PP network group
    //   , unit_interval ; PP economic group
    //   , unit_interval ; PP technical group
    //   , unit_interval ; PP governance group
    //   , unit_interval ; treasury withdrawal
    //   ]
    writer.writeStartArray(EX_DREP_VOTING_THRESHOLDS_SIZE);

    writer.writeEncodedValue(Buffer.from(this.#motionNoConfidence.toCbor(), 'hex'));
    writer.writeEncodedValue(Buffer.from(this.#committeeNormal.toCbor(), 'hex'));
    writer.writeEncodedValue(Buffer.from(this.#committeeNoConfidence.toCbor(), 'hex'));
    writer.writeEncodedValue(Buffer.from(this.#updateConstitution.toCbor(), 'hex'));
    writer.writeEncodedValue(Buffer.from(this.#hardForkInitiation.toCbor(), 'hex'));
    writer.writeEncodedValue(Buffer.from(this.#ppNetworkGroup.toCbor(), 'hex'));
    writer.writeEncodedValue(Buffer.from(this.#ppEconomicGroup.toCbor(), 'hex'));
    writer.writeEncodedValue(Buffer.from(this.#ppTechnicalGroup.toCbor(), 'hex'));
    writer.writeEncodedValue(Buffer.from(this.#ppGovernanceGroup.toCbor(), 'hex'));
    writer.writeEncodedValue(Buffer.from(this.#treasuryWithdrawal.toCbor(), 'hex'));

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the DrepVotingThresholds from a CBOR byte array.
   *
   * @param cbor The CBOR encoded DrepVotingThresholds object.
   * @returns The new DrepVotingThresholds instance.
   */
  static fromCbor(cbor: HexBlob): DrepVotingThresholds {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== EX_DREP_VOTING_THRESHOLDS_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${EX_DREP_VOTING_THRESHOLDS_SIZE} elements, but got an array of ${length} elements`
      );

    const motionNoConfidence = UnitInterval.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
    const committeeNormal = UnitInterval.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
    const committeeNoConfidence = UnitInterval.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
    const updateConstitution = UnitInterval.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
    const hardForkInitiation = UnitInterval.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
    const ppNetworkGroup = UnitInterval.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
    const ppEconomicGroup = UnitInterval.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
    const ppTechnicalGroup = UnitInterval.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
    const ppGovernanceGroup = UnitInterval.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
    const treasuryWithdrawal = UnitInterval.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));

    reader.readEndArray();

    const thresholds = new DrepVotingThresholds(
      motionNoConfidence,
      committeeNormal,
      committeeNoConfidence,
      updateConstitution,
      hardForkInitiation,
      ppNetworkGroup,
      ppEconomicGroup,
      ppTechnicalGroup,
      ppGovernanceGroup,
      treasuryWithdrawal
    );

    thresholds.#originalBytes = cbor;

    return thresholds;
  }

  /**
   * Creates a Core DelegateRepresentativeThresholds object from the current DrepVotingThresholds object.
   *
   * @returns The Core Prices object.
   */
  toCore(): Cardano.DelegateRepresentativeThresholds {
    return {
      commiteeNoConfidence: this.#committeeNoConfidence.toCore(),
      committeeNormal: this.#committeeNormal.toCore(),
      hardForkInitiation: this.#hardForkInitiation.toCore(),
      motionNoConfidence: this.#motionNoConfidence.toCore(),
      ppEconomicGroup: this.#ppEconomicGroup.toCore(),
      ppGovernanceGroup: this.#ppGovernanceGroup.toCore(),
      ppNetworkGroup: this.#ppNetworkGroup.toCore(),
      ppTechnicalGroup: this.#ppTechnicalGroup.toCore(),
      treasuryWithdrawal: this.#treasuryWithdrawal.toCore(),
      updateConstitution: this.#updateConstitution.toCore()
    };
  }

  /**
   * Creates a DrepVotingThresholds object from the given Core DelegateRepresentativeThresholds object.
   *
   * @param core core DelegateRepresentativeThresholds object.
   */
  static fromCore(core: Cardano.DelegateRepresentativeThresholds) {
    return new DrepVotingThresholds(
      UnitInterval.fromCore(core.motionNoConfidence),
      UnitInterval.fromCore(core.committeeNormal),
      UnitInterval.fromCore(core.commiteeNoConfidence),
      UnitInterval.fromCore(core.updateConstitution),
      UnitInterval.fromCore(core.hardForkInitiation),
      UnitInterval.fromCore(core.ppNetworkGroup),
      UnitInterval.fromCore(core.ppEconomicGroup),
      UnitInterval.fromCore(core.ppTechnicalGroup),
      UnitInterval.fromCore(core.ppGovernanceGroup),
      UnitInterval.fromCore(core.treasuryWithdrawal)
    );
  }

  /**
   * Sets the quorum threshold (percentage of the total active voting stake) that
   * needs to be meet for a Motion of no-confidence to be enacted.
   *
   * @param threshold The quorum threshold.
   */
  setMotionNoConfidence(threshold: UnitInterval) {
    this.#motionNoConfidence = threshold;
    this.#originalBytes = undefined;
  }

  /**
   * Sets the quorum threshold (percentage of the total active voting stake) that needs
   * to be meet for a new committee to be elected if the constitutional committee
   * is in a state of confidence.
   *
   * @param threshold The quorum threshold.
   */
  setCommitteeNormal(threshold: UnitInterval) {
    this.#committeeNormal = threshold;
    this.#originalBytes = undefined;
  }

  /**
   * Sets the quorum threshold (percentage of the total active voting stake) that needs
   * to be meet for a new committee to be elected if the constitutional committee is
   * in a state of no-confidence.
   *
   * @param threshold The quorum threshold.
   */
  setCommitteeNoConfidence(threshold: UnitInterval) {
    this.#committeeNoConfidence = threshold;
    this.#originalBytes = undefined;
  }

  /**
   * Sets the quorum threshold (percentage of the total active voting stake) that
   * needs to be meet for a modification to the Constitution to be enacted.
   *
   * @param threshold The quorum threshold.
   */
  setUpdateConstitution(threshold: UnitInterval) {
    this.#updateConstitution = threshold;
    this.#originalBytes = undefined;
  }

  /**
   * Sets the quorum threshold (percentage of the total active voting stake) that
   * needs to be meet to trigger a non-backwards compatible upgrade of the network
   * (requires a prior software upgrade).
   *
   * @param threshold The quorum threshold.
   */
  setHardForkInitiation(threshold: UnitInterval) {
    this.#hardForkInitiation = threshold;
    this.#originalBytes = undefined;
  }

  /**
   * Sets the quorum threshold (percentage of the total active voting stake) that
   * needs to be meet to update the protocol parameters in the network group.
   *
   * @param threshold The quorum threshold.
   */
  setPpNetworkGroup(threshold: UnitInterval) {
    this.#ppNetworkGroup = threshold;
    this.#originalBytes = undefined;
  }

  /**
   * Sets the quorum threshold (percentage of the total active voting stake) that
   * needs to be meet to update the protocol parameters in the economic group.
   *
   * @param threshold The quorum threshold.
   */
  setPpEconomicGroup(threshold: UnitInterval) {
    this.#ppEconomicGroup = threshold;
    this.#originalBytes = undefined;
  }

  /**
   * Sets the quorum threshold (percentage of the total active voting stake) that
   * needs to be meet to update the protocol parameters in the technical group.
   *
   * @param threshold The quorum threshold.
   */
  setPpTechnicalGroup(threshold: UnitInterval) {
    this.#ppTechnicalGroup = threshold;
    this.#originalBytes = undefined;
  }

  /**
   * Sets the quorum threshold (percentage of the total active voting stake) that
   * needs to be meet to update the protocol parameters in the governance group.
   *
   * @param threshold The quorum threshold.
   */
  setPpGovernanceGroup(threshold: UnitInterval) {
    this.#ppGovernanceGroup = threshold;
    this.#originalBytes = undefined;
  }

  /**
   * Sets the quorum threshold (percentage of the total active voting stake) that
   * needs to withdrawal from the treasury.
   *
   * @param threshold The quorum threshold.
   */
  setTreasuryWithdrawal(threshold: UnitInterval) {
    this.#treasuryWithdrawal = threshold;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the quorum threshold (percentage of the total active voting stake) that
   * needs to be meet for a Motion of no-confidence to be enacted.
   *
   * @returns The quorum threshold.
   */
  motionNoConfidence(): UnitInterval {
    return this.#motionNoConfidence;
  }

  /**
   * Gets the quorum threshold (percentage of the total active voting stake) that needs
   * to be meet for a new committee to be elected if the constitutional committee
   * is in a state of confidence.
   *
   * @returns The quorum threshold.
   */
  committeeNormal(): UnitInterval {
    return this.#committeeNormal;
  }

  /**
   * Gets the quorum threshold (percentage of the total active voting stake) that needs
   * to be meet for a new committee to be elected if the constitutional committee is
   * in a state of no-confidence.
   *
   * @returns The quorum threshold.
   */
  committeeNoConfidence(): UnitInterval {
    return this.#committeeNoConfidence;
  }

  /**
   * Gets the quorum threshold (percentage of the total active voting stake) that
   * needs to be meet for a modification to the Constitution to be enacted.
   *
   * @returns The quorum threshold.
   */
  updateConstitution(): UnitInterval {
    return this.#updateConstitution;
  }

  /**
   * Gets the quorum threshold (percentage of the total active voting stake) that
   * needs to be meet to trigger a non-backwards compatible upgrade of the network
   * (requires a prior software upgrade).
   *
   * @returns The quorum threshold.
   */
  hardForkInitiation(): UnitInterval {
    return this.#hardForkInitiation;
  }

  /**
   * Gets the quorum threshold (percentage of the total active voting stake) that
   * needs to be meet to update the protocol parameters in the network group.
   *
   * @returns The quorum threshold.
   */
  ppNetworkGroup(): UnitInterval {
    return this.#ppNetworkGroup;
  }

  /**
   * Gets the quorum threshold (percentage of the total active voting stake) that
   * needs to be meet to update the protocol parameters in the economic group.
   *
   * @returns The quorum threshold.
   */
  ppEconomicGroup(): UnitInterval {
    return this.#ppEconomicGroup;
  }

  /**
   * Gets the quorum threshold (percentage of the total active voting stake) that
   * needs to be meet to update the protocol parameters in the technical group.
   *
   * @returns The quorum threshold.
   */
  ppTechnicalGroup(): UnitInterval {
    return this.#ppTechnicalGroup;
  }

  /**
   * Gets the quorum threshold (percentage of the total active voting stake) that
   * needs to be meet to update the protocol parameters in the governance group.
   *
   * @returns The quorum threshold.
   */
  ppGovernanceGroup(): UnitInterval {
    return this.#ppGovernanceGroup;
  }

  /**
   * Gets the quorum threshold (percentage of the total active voting stake) that
   * needs to withdrawal from the treasury.
   *
   * @returns The quorum threshold.
   */
  treasuryWithdrawal(): UnitInterval {
    return this.#treasuryWithdrawal;
  }
}
