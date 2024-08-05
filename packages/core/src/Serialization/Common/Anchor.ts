import * as Crypto from '@cardano-sdk/crypto';
import { CborReader, CborWriter } from '../CBOR';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import type * as Cardano from '../../Cardano';

const EMBEDDED_GROUP_SIZE = 2;
const MAX_URL_SIZE_STR_LENGTH = 128;

/**
 * An anchor is a pair of:
 *
 * - a URL to a JSON payload of metadata.
 * - a hash of the contents of the metadata URL.
 *
 * The on-chain rules will not check either the URL or the hash. Client applications should,
 * however, perform the usual sanity checks when fetching content from the provided URL.
 */
export class Anchor {
  #url: string;
  #dataHash: Crypto.Hash32ByteBase16;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the Anchor class.
   *
   * @param url The URL to a JSON payload of metadata.
   * @param dataHash The hash of the contents of the metadata URL.
   */
  constructor(url: string, dataHash: Crypto.Hash32ByteBase16) {
    if (url.length > MAX_URL_SIZE_STR_LENGTH)
      throw new InvalidArgumentError(
        'url',
        `url must be less or equal to 64 characters long, actual size ${url.length}`
      );

    this.#url = url;
    this.#dataHash = dataHash;
  }

  /**
   * Serializes an Anchor into CBOR format.
   *
   * @returns The Anchor in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // anchor =
    //   [ anchor_url       : url
    //   , anchor_data_hash : $hash32
    //   ]
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);
    writer.writeTextString(this.#url);
    writer.writeByteString(Buffer.from(this.#dataHash, 'hex'));

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the Anchor from a CBOR byte array.
   *
   * @param cbor The CBOR encoded Anchor object.
   * @returns The new Anchor instance.
   */
  static fromCbor(cbor: HexBlob): Anchor {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== EMBEDDED_GROUP_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${EMBEDDED_GROUP_SIZE} elements, but got an array of ${length} elements`
      );

    const url = reader.readTextString();
    const hash = Crypto.Hash32ByteBase16(HexBlob.fromBytes(reader.readByteString()));

    reader.readEndArray();

    const anchor = new Anchor(url, hash);
    anchor.#originalBytes = cbor;

    return anchor;
  }

  /**
   * Creates a Core Anchor object from the current Anchor object.
   *
   * @returns The Core Anchor object.
   */
  toCore(): Cardano.Anchor {
    return {
      dataHash: this.#dataHash,
      url: this.#url
    };
  }

  /**
   * Creates a Anchor object from the given Core Anchor object.
   *
   * @param anchor core Anchor object.
   */
  static fromCore(anchor: Cardano.Anchor) {
    return new Anchor(anchor.url, anchor.dataHash);
  }

  /**
   * Gets the URL to a JSON payload of metadata.
   *
   * @returns The URL to a JSON payload of metadata.
   */
  url() {
    return this.#url;
  }

  /**
   * Sets the URL to a JSON payload of metadata.
   *
   * @param url The URL to a JSON payload of metadata.
   */
  setUrl(url: string) {
    this.#url = url;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the hash of the contents of the metadata URL.
   *
   * @returns The hash of the contents.
   */
  dataHash(): Crypto.Hash32ByteBase16 {
    return this.#dataHash;
  }

  /**
   * Sets the hash of the contents of the metadata URL.
   *
   * @param dataHash The hash of the contents.
   */
  setDataHash(dataHash: Crypto.Hash32ByteBase16) {
    this.#dataHash = dataHash;
    this.#originalBytes = undefined;
  }
}
