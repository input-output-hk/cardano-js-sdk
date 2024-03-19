import * as Cardano from '../../Cardano';
import { CborReader, CborWriter } from '../CBOR';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';

const PROTOCOL_VERSION_ARRAY_SIZE = 2;

/**
 * The protocol can be thought of as the set of rules that nodes in the network agree to follow,
 * and this versioning system helps nodes to keep track of which set of rules they are adhering to and also
 * allows for the decentralized updating of the protocol parameters without requiring a hard fork.
 */
export class ProtocolVersion {
  #major: number;
  #minor: number;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the ProtocolVersion class.
   *
   * @param major Changes when there are significant alterations to the protocol that are not backward compatible.
   * It would require nodes to upgrade to continue participating in the network.
   * @param minor  Reflects backward-compatible changes. Nodes running an older version can still communicate with
   * nodes running the updated version, but they might not take advantage of new features.
   */
  constructor(major: number, minor: number) {
    this.#major = major;
    this.#minor = minor;
  }

  /**
   * Serializes a ProtocolVersion into CBOR format.
   *
   * @returns The ProtocolVersion in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // next_major_protocol_version = 10
    // major_protocol_version = 1..next_major_protocol_version
    // protocol_version = [(major_protocol_version, uint32)]
    writer.writeStartArray(PROTOCOL_VERSION_ARRAY_SIZE);
    writer.writeInt(this.#major);
    writer.writeInt(this.#minor);

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the ProtocolVersion from a CBOR byte array.
   *
   * @param cbor The CBOR encoded ProtocolVersion object.
   * @returns The new ProtocolVersion instance.
   */
  static fromCbor(cbor: HexBlob): ProtocolVersion {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== PROTOCOL_VERSION_ARRAY_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${PROTOCOL_VERSION_ARRAY_SIZE} elements, but got an array of ${length} elements`
      );

    const major = Number(reader.readInt());
    const minor = Number(reader.readInt());

    reader.readEndArray();

    const version = new ProtocolVersion(major, minor);
    version.#originalBytes = cbor;

    return version;
  }

  /**
   * Creates a Core ProtocolVersion object from the current ProtocolVersion object.
   *
   * @returns The Core ProtocolVersion object.
   */
  toCore(): Cardano.ProtocolVersion {
    return {
      major: Number(this.#major),
      minor: Number(this.#minor)
    };
  }

  /**
   * Creates a ProtocolVersion object from the given Core ProtocolVersion object.
   *
   * @param version core ProtocolVersion object.
   */
  static fromCore(version: Cardano.ProtocolVersion) {
    return new ProtocolVersion(version.major, version.minor);
  }

  /**
   * Gets the major component of the version.
   *
   * This number is increased when there are changes that are significant alterations to
   * the protocol that are not backward compatible.
   *
   * It would require nodes to upgrade to continue participating in the network.
   *
   * @returns The major version.
   */
  major(): number {
    return this.#major;
  }

  /**
   * Sets the major component of the version.
   *
   * @param major The major version.
   */
  setMajor(major: number): void {
    this.#major = major;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the minor component of the version.
   *
   * This number is increased when changes are backward-compatible.
   *
   * Nodes running an older version can still communicate with nodes running the
   * updated version, but they might not take advantage of new features.
   *
   * @returns The minor version.
   */
  minor(): number {
    return this.#minor;
  }

  /**
   * Sets the minor component of the version.
   *
   * @param minor The minor version.
   */
  setMinor(minor: number): void {
    this.#minor = minor;
    this.#originalBytes = undefined;
  }
}
