import { Anchor } from '../../Common/Anchor';
import { CborReader, CborReaderState, CborWriter } from '../../CBOR';
import { HexBlob } from '@cardano-sdk/util';
import { hexToBytes } from '../../../util/misc';
import type * as Cardano from '../../../Cardano';

const EMBEDDED_GROUP_SIZE = 2;

/**
 * A voting procedure is a pair of:
 *
 * - a vote.
 * - an anchor, it links the vote to arbitrary off-chain JSON payload of metadata.
 */
export class VotingProcedure {
  #vote: Cardano.Vote;
  #anchor: Anchor | undefined;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initialize a new instance of the VotingProcedure class.
   *
   * @param vote The vote (Yes, No or Abstain).
   * @param anchor The vote anchor (or undefined if none).
   */
  constructor(vote: Cardano.Vote, anchor?: Anchor) {
    this.#vote = vote;
    this.#anchor = anchor;
  }

  /**
   * Serializes a VotingProcedure into CBOR format.
   *
   * @returns The VotingProcedure in CBOR format.
   */
  toCbor(): HexBlob {
    if (this.#originalBytes) return this.#originalBytes;

    const writer = new CborWriter();

    // CDDL
    // voting_procedure =
    //   [ vote
    //   , anchor / null
    //   ]
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);
    writer.writeInt(this.#vote);
    this.#anchor ? writer.writeEncodedValue(hexToBytes(this.#anchor.toCbor())) : writer.writeNull();

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the VotingProcedure from a CBOR byte array.
   *
   * @param cbor The CBOR encoded VotingProcedure object.
   * @returns The new VotingProcedure instance.
   */
  static fromCbor(cbor: HexBlob): VotingProcedure {
    const reader = new CborReader(cbor);

    reader.readStartArray();
    const vote = Number(reader.readInt());
    let anchor;

    if (reader.peekState() === CborReaderState.Null) {
      reader.readNull();
      anchor = undefined;
    } else {
      anchor = Anchor.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
    }

    const votingProcedure = new VotingProcedure(vote, anchor);
    votingProcedure.#originalBytes = cbor;

    return votingProcedure;
  }

  /**
   * Creates a Core VotingProcedure object from the current VotingProcedure object.
   *
   * @returns The Core VotingProcedure object.
   */
  toCore(): Cardano.VotingProcedure {
    return {
      anchor: this.#anchor ? this.#anchor.toCore() : null,
      vote: this.#vote
    };
  }

  /**
   * Creates a VotingProcedure object from the given Core VotingProcedure object.
   *
   * @param votingProcedure The core VotingProcedure object.
   */
  static fromCore(votingProcedure: Cardano.VotingProcedure): VotingProcedure {
    return new VotingProcedure(
      votingProcedure.vote,
      votingProcedure.anchor ? Anchor.fromCore(votingProcedure.anchor) : undefined
    );
  }

  /**
   * Gets the vote.
   *
   * @returns The vote.
   */
  vote(): Cardano.Vote {
    return this.#vote;
  }

  /**
   * Sets the vote.
   *
   * @param vote The vote.
   */
  setVote(vote: Cardano.Vote) {
    this.#vote = vote;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the anchor, a link to arbitrary off-chain JSON payload of metadata.
   *
   * @returns The anchor.
   */
  anchor(): Anchor | undefined {
    return this.#anchor;
  }

  /**
   * Sets the anchor, a link to arbitrary off-chain JSON payload of metadata.
   *
   * @param anchor The anchor.
   */
  setAnchor(anchor: Anchor | undefined) {
    this.#anchor = anchor;
    this.#originalBytes = undefined;
  }
}
