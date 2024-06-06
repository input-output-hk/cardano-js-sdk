import * as Crypto from '@cardano-sdk/crypto';
import { CborReader, CborWriter } from '../../CBOR/index.js';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import type * as Cardano from '../../../Cardano/index.js';

const MAX_URL_SIZE_STR_LENGTH = 64;
const EMBEDDED_GROUP_SIZE = 2;

/**
 * The pool registration certificate can include a way to locate pool metadata. This includes the hash of
 * the metadata. This is not the metadata itself but a unique identifier that corresponds to the metadata.
 * The hash function ensures that even a small change in the metadata leads to a completely different hash,
 * securing the authenticity of the data.
 *
 * Along with the hash of the metadata, the URL where the actual metadata file (in JSON format)
 * is hosted is also included in the certificate. The combination of the URL and the hash allows wallets
 * and other services to download the metadata file and verify it against the hash.
 */
export class PoolMetadata {
  #url: string;
  #hash: Crypto.Hash32ByteBase16;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the PoolMetadata class.
   *
   * @param url The URL where the actual metadata file is hosted.
   * @param poolMetadataHash Hash of the metadata.
   */
  constructor(url: string, poolMetadataHash: Crypto.Hash32ByteBase16) {
    if (url.length > MAX_URL_SIZE_STR_LENGTH)
      throw new InvalidArgumentError(
        'url',
        `url must be less or equal to 64 characters long, actual size ${url.length}`
      );

    this.#url = url;
    this.#hash = poolMetadataHash;
  }

  /**
   * Serializes a PoolMetadata into CBOR format.
   *
   * @returns The PoolMetadata in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // pool_metadata = [url, pool_metadata_hash]
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);
    writer.writeTextString(this.#url);
    writer.writeByteString(Buffer.from(this.#hash, 'hex'));

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the PoolMetadata from a CBOR byte array.
   *
   * @param cbor The CBOR encoded PoolMetadata object.
   * @returns The new PoolMetadata instance.
   */
  static fromCbor(cbor: HexBlob): PoolMetadata {
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

    const metadata = new PoolMetadata(url, hash);
    metadata.#originalBytes = cbor;

    return metadata;
  }

  /**
   * Creates a Core PoolMetadataJson object from the current PoolMetadata object.
   *
   * @returns The Core PoolMetadataJson object.
   */
  toCore(): Cardano.PoolMetadataJson {
    return {
      hash: this.#hash,
      url: this.#url
    };
  }

  /**
   * Creates a PoolMetadataJson object from the given Core PoolMetadataJson object.
   *
   * @param metadata core PoolMetadataJson object.
   */
  static fromCore(metadata: Cardano.PoolMetadataJson) {
    return new PoolMetadata(metadata.url, metadata.hash);
  }

  /**
   * Gets the URL of the metadata file.
   *
   * @returns The URL where the actual metadata file is hosted.
   */
  url(): string {
    return this.#url;
  }

  /**
   * Sets the URL of the metadata file.
   *
   * @param url The URL where the actual metadata file is hosted.
   */
  setUrl(url: string): void {
    this.#url = url;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the pool metadata file hash.
   *
   * @returns Hash of the metadata.
   */
  poolMetadataHash(): Crypto.Hash32ByteBase16 {
    return this.#hash;
  }

  /**
   * Sets the pool metadata file hash.
   *
   * @param poolMetadataHash Hash of the metadata.
   */
  setPoolMetadataHash(poolMetadataHash: Crypto.Hash32ByteBase16): void {
    this.#hash = poolMetadataHash;
    this.#originalBytes = undefined;
  }
}
