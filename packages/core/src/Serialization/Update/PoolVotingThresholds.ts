import * as Cardano from '../../Cardano';
import { CborReader, CborWriter } from '../CBOR';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { UnitInterval } from '../Common';

const POOL_VOTING_THRESHOLDS_SIZE = 5;

/**
 * Governance actions are ratified through on-chain voting. Different
 * kinds of governance actions have different ratification requirements. One of those
 * requirements is the approval of the action by SPOs. These thresholds specify
 * the percentage of the stake held by all stake pools that must be meet by the SPOs who
 * vote Yes for the approval to be successful.
 */
export class PoolVotingThresholds {
  #motionNoConfidence: UnitInterval;
  #committeeNormal: UnitInterval;
  #committeeNoConfidence: UnitInterval;
  #hardForkInitiation: UnitInterval;
  #securityRelevantParamVotingThreshold: UnitInterval;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initialize a new instance of the PoolVotingThresholds class.
   *
   * @param motionNoConfidence Quorum threshold (percentage of the total active stake) that
   * needs to be meet for a Motion of no-confidence to be enacted.
   * @param committeeNormal Quorum threshold (percentage of the total active stake) that needs
   * to be meet for a new committee to be elected if the constitutional committee is in a state of confidence.
   * @param committeeNoConfidence Quorum threshold (percentage of the total active stake) that needs
   * to be meet for a new committee to be elected if the constitutional committee is in a state of no-confidence.
   * @param hardForkInitiation Quorum threshold (percentage of the total active stake) that
   * needs to be meet to trigger a non-backwards compatible upgrade of the network (requires a prior software upgrade).
   */
  constructor(
    motionNoConfidence: UnitInterval,
    committeeNormal: UnitInterval,
    committeeNoConfidence: UnitInterval,
    hardForkInitiation: UnitInterval,
    securityRelevantParamVotingThreshold: UnitInterval
  ) {
    this.#motionNoConfidence = motionNoConfidence;
    this.#committeeNormal = committeeNormal;
    this.#committeeNoConfidence = committeeNoConfidence;
    this.#hardForkInitiation = hardForkInitiation;
    this.#securityRelevantParamVotingThreshold = securityRelevantParamVotingThreshold;
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
    // pool_voting_thresholds =
    //   [ unit_interval ; motion no confidence
    //   , unit_interval ; committee normal
    //   , unit_interval ; committee no confidence
    //   , unit_interval ; hard fork initiation
    //   , unit_interval ; security relevant parameter voting threshold
    //   ]
    writer.writeStartArray(POOL_VOTING_THRESHOLDS_SIZE);

    writer.writeEncodedValue(Buffer.from(this.#motionNoConfidence.toCbor(), 'hex'));
    writer.writeEncodedValue(Buffer.from(this.#committeeNormal.toCbor(), 'hex'));
    writer.writeEncodedValue(Buffer.from(this.#committeeNoConfidence.toCbor(), 'hex'));
    writer.writeEncodedValue(Buffer.from(this.#hardForkInitiation.toCbor(), 'hex'));
    writer.writeEncodedValue(Buffer.from(this.#securityRelevantParamVotingThreshold.toCbor(), 'hex'));

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the PoolVotingThresholds from a CBOR byte array.
   *
   * @param cbor The CBOR encoded PoolVotingThresholds object.
   * @returns The new PoolVotingThresholds instance.
   */
  static fromCbor(cbor: HexBlob): PoolVotingThresholds {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== POOL_VOTING_THRESHOLDS_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${POOL_VOTING_THRESHOLDS_SIZE} elements, but got an array of ${length} elements`
      );

    const motionNoConfidence = UnitInterval.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
    const committeeNormal = UnitInterval.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
    const committeeNoConfidence = UnitInterval.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
    const hardForkInitiation = UnitInterval.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
    const securityRelevantParamVotingThreshold = UnitInterval.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));

    reader.readEndArray();

    const thresholds = new PoolVotingThresholds(
      motionNoConfidence,
      committeeNormal,
      committeeNoConfidence,
      hardForkInitiation,
      securityRelevantParamVotingThreshold
    );

    thresholds.#originalBytes = cbor;

    return thresholds;
  }

  /**
   * Creates a Core PoolVotingThresholds object from the current PoolVotingThresholds object.
   *
   * @returns The Core Prices object.
   */
  toCore(): Cardano.PoolVotingThresholds {
    return {
      committeeNoConfidence: this.#committeeNoConfidence.toCore(),
      committeeNormal: this.#committeeNormal.toCore(),
      hardForkInitiation: this.#hardForkInitiation.toCore(),
      motionNoConfidence: this.#motionNoConfidence.toCore(),
      securityRelevantParamVotingThreshold: this.#securityRelevantParamVotingThreshold.toCore()
    };
  }

  /**
   * Creates a PoolVotingThresholds object from the given Core PoolVotingThresholdsSHOLDS_SIZE object.
   *
   * @param core core PoolVotingThresholdsSHOLDS_SIZE object.
   */
  static fromCore(core: Cardano.PoolVotingThresholds) {
    return new PoolVotingThresholds(
      UnitInterval.fromCore(core.motionNoConfidence),
      UnitInterval.fromCore(core.committeeNormal),
      UnitInterval.fromCore(core.committeeNoConfidence),
      UnitInterval.fromCore(core.hardForkInitiation),
      UnitInterval.fromCore(core.securityRelevantParamVotingThreshold)
    );
  }

  /**
   * Sets the quorum threshold (percentage of the total active stake) that
   * needs to be meet for a Motion of no-confidence to be enacted.
   *
   * @param threshold The quorum threshold.
   */
  setMotionNoConfidence(threshold: UnitInterval) {
    this.#motionNoConfidence = threshold;
    this.#originalBytes = undefined;
  }

  /**
   * Sets the quorum threshold (percentage of the total active stake) that needs
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
   * Sets the quorum threshold (percentage of the total active stake) that needs
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
   * Sets the quorum threshold (percentage of the total active stake) that
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
   * Gets the quorum threshold (percentage of the total active stake) that
   * needs to be meet for a Motion of no-confidence to be enacted.
   *
   * @returns The quorum threshold.
   */
  motionNoConfidence(): UnitInterval {
    return this.#motionNoConfidence;
  }

  /**
   * Gets the quorum threshold (percentage of the total active stake) that needs
   * to be meet for a new committee to be elected if the constitutional committee
   * is in a state of confidence.
   *
   * @returns The quorum threshold.
   */
  committeeNormal(): UnitInterval {
    return this.#committeeNormal;
  }

  /**
   * Gets the quorum threshold (percentage of the total active stake) that needs
   * to be meet for a new committee to be elected if the constitutional committee is
   * in a state of no-confidence.
   *
   * @returns The quorum threshold.
   */
  committeeNoConfidence(): UnitInterval {
    return this.#committeeNoConfidence;
  }

  /**
   * Gets the quorum threshold (percentage of the total active stake) that
   * needs to be meet to trigger a non-backwards compatible upgrade of the network
   * (requires a prior software upgrade).
   *
   * @returns The quorum threshold.
   */
  hardForkInitiation(): UnitInterval {
    return this.#hardForkInitiation;
  }

  /**
   * Gets the security relevant parameter voting threshold
   *
   * @returns security relevant parameter voting threshold.
   */
  securityRelevantParamVotingThreshold(): UnitInterval {
    return this.#securityRelevantParamVotingThreshold;
  }
}
