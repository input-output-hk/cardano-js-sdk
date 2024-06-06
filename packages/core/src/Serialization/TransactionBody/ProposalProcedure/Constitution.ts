import { Anchor } from '../../Common/Anchor.js';
import { CborReader, CborReaderState, CborWriter } from '../../CBOR/index.js';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { hexToBytes } from '../../../util/misc/index.js';
import type * as Cardano from '../../../Cardano/index.js';
import type { Hash28ByteBase16 } from '@cardano-sdk/crypto';

const CONSTITUTION_ARRAY_SIZE = 2;

/**
 * The Cardano Constitution is a text document that defines Cardano's shared values and guiding principles.
 * At this stage, the Constitution is an informational document that unambiguously captures the core values
 * of Cardano and acts to ensure its long-term sustainability. At a later stage, we can imagine the Constitution
 * perhaps evolving into a smart-contract based set of rules that drives the entire governance framework.
 *
 * For now, however, the Constitution will remain an off-chain document whose hash digest value will be recorded
 * on-chain.
 */
export class Constitution {
  #anchor: Anchor;
  #scriptHash: Hash28ByteBase16 | undefined;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the Constitution class.
   *
   * @param anchor A link to the off change constitution content.
   * @param scriptHash The hash of constitution script.
   */
  constructor(anchor: Anchor, scriptHash?: Hash28ByteBase16) {
    this.#anchor = anchor;
    this.#scriptHash = scriptHash;
  }

  /**
   * Serializes a Constitution into CBOR format.
   *
   * @returns The Constitution in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // constitution =
    //   [ anchor
    //   , scripthash / null
    //   ]
    writer.writeStartArray(CONSTITUTION_ARRAY_SIZE);
    writer.writeEncodedValue(hexToBytes(this.#anchor.toCbor()));
    this.#scriptHash ? writer.writeByteString(hexToBytes(this.#scriptHash as unknown as HexBlob)) : writer.writeNull();

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the Constitution from a CBOR byte array.
   *
   * @param cbor The CBOR encoded Constitution object.
   * @returns The new Constitution instance.
   */
  static fromCbor(cbor: HexBlob): Constitution {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== CONSTITUTION_ARRAY_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${CONSTITUTION_ARRAY_SIZE} elements, but got an array of ${length} elements`
      );

    const anchor = Anchor.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
    let scriptHash;

    if (reader.peekState() === CborReaderState.Null) {
      reader.readNull();
    } else {
      scriptHash = HexBlob.fromBytes(reader.readByteString()) as unknown as Hash28ByteBase16;
    }

    reader.readEndArray();

    const constitution = new Constitution(anchor, scriptHash);
    constitution.#originalBytes = cbor;

    return constitution;
  }

  /**
   * Creates a Core Constitution object from the current Constitution object.
   *
   * @returns The Core Constitution object.
   */
  toCore(): Cardano.Constitution {
    return {
      anchor: this.#anchor.toCore(),
      scriptHash: this.#scriptHash ? this.#scriptHash : null
    };
  }

  /**
   * Creates a Constitution object from the given Core Constitution object.
   *
   * @param constitution core Constitution object.
   */
  static fromCore(constitution: Cardano.Constitution) {
    return new Constitution(
      Anchor.fromCore(constitution.anchor),
      constitution.scriptHash !== null ? constitution.scriptHash : undefined
    );
  }

  /**
   * Gets the anchor to the constitution contents.
   *
   * @returns The anchor object.
   */
  anchor(): Anchor {
    return this.#anchor;
  }

  /**
   * Sets the anchor to the constitution contents.
   *
   * @param anchor The anchor object.
   */
  setAnchor(anchor: Anchor) {
    this.#anchor = anchor;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the hash of the script that enforces the constitution on chain.
   *
   * @returns the script hash.
   */
  scriptHash(): Hash28ByteBase16 | undefined {
    return this.#scriptHash;
  }

  /**
   * Sets the hash of the constitution script.
   *
   * @param scriptHash The script hash.
   */
  setScriptHash(scriptHash: Hash28ByteBase16 | undefined) {
    this.#scriptHash = scriptHash;
    this.#originalBytes = undefined;
  }
}
