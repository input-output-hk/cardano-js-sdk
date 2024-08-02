import { CborReader, CborWriter } from '../CBOR';
import { EpochNo } from '../../Cardano/types/Block';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { ProposedProtocolParameterUpdates } from './ProposedProtocolParameterUpdates';
import type * as Cardano from '../../Cardano';

const UPDATE_ARRAY_SIZE = 2;

/**
 * When stakeholders wish to propose changes to the system's parameters, they submit an update proposal.
 * Such proposals are then voted on by the community. If approved, the protocol parameters are adjusted
 * accordingly in the specified epoch.
 */
export class Update {
  #epoch: Cardano.EpochNo;
  #updates: ProposedProtocolParameterUpdates;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the Update class.
   *
   * @param updates This contains the actual proposed changes to the protocol parameters. It might include changes to things
   * like transaction fees, block size limits, staking key deposit amounts, and more.
   * @param epoch Specifies the epoch in which the proposal will come into effect if accepted.
   */
  constructor(updates: ProposedProtocolParameterUpdates, epoch: Cardano.EpochNo) {
    this.#epoch = epoch;
    this.#updates = updates;
  }

  /**
   * Serializes an Update into CBOR format.
   *
   * @returns The Update in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // update = [ proposed_protocol_parameter_updates
    //          , epoch
    //          ]
    writer.writeStartArray(UPDATE_ARRAY_SIZE);
    writer.writeEncodedValue(Buffer.from(this.#updates.toCbor(), 'hex'));
    writer.writeInt(this.#epoch);

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the Update from a CBOR byte array.
   *
   * @param cbor The CBOR encoded Update object.
   * @returns The new Update instance.
   */
  static fromCbor(cbor: HexBlob): Update {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== UPDATE_ARRAY_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${UPDATE_ARRAY_SIZE} elements, but got an array of ${length} elements`
      );

    const updates = ProposedProtocolParameterUpdates.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
    const epoch = reader.readInt();

    reader.readEndArray();

    const exUnit = new Update(updates, EpochNo(Number(epoch)));
    exUnit.#originalBytes = cbor;

    return exUnit;
  }

  /**
   * Creates a Core Prices object from the current Update object.
   *
   * @returns The Core Prices object.
   */
  toCore(): Cardano.Update {
    return {
      epoch: this.#epoch,
      proposedProtocolParameterUpdates: this.#updates.toCore()
    };
  }

  /**
   * Creates a nUpdate object from the given Core Update object.
   *
   * @param update core Update object.
   */
  static fromCore(update: Cardano.Update) {
    const epoch = update.epoch;
    const updates = ProposedProtocolParameterUpdates.fromCore(update.proposedProtocolParameterUpdates);

    return new Update(updates, epoch);
  }

  /**
   * Gets the epoch in which the proposal will come into effect if accepted.
   *
   * @returns the Epoch when the proposal will come into effect.
   */
  epoch(): Cardano.EpochNo {
    return this.#epoch;
  }

  /**
   * Sets the epoch in which the proposal will come into effect if accepted.
   *
   * @param epoch the Epoch when the proposal will come into effect.
   */
  setEpoch(epoch: Cardano.EpochNo): void {
    this.#epoch = epoch;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the proposed changes to the protocol parameters.
   *
   * @returns The protocol parameters updates.
   */
  proposedProtocolParameterUpdates(): ProposedProtocolParameterUpdates {
    return this.#updates;
  }

  /**
   * Sets the proposed changes to the protocol parameters.
   *
   * @param updates The protocol parameters updates.
   */
  setProposedProtocolParameterUpdates(updates: ProposedProtocolParameterUpdates): void {
    this.#updates = updates;
    this.#originalBytes = undefined;
  }
}
