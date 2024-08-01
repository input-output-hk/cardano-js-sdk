/* eslint-disable no-bitwise */
import { Address, AddressProps, AddressType } from './Address';
import { CborReader, CborReaderState, CborTag, CborWriter } from '../../Serialization/CBOR';
import { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { crc32 } from '@foxglove/crc';

/**
 * Byron address attributes (both optional). The network tag is present only on test networks and contains an
 * identifier that is used for network discrimination. The derivation path was used by legacy so-called random
 * wallets in the early days of Cardano and its usage was abandoned with the introduction of Yoroi and Icarus
 * addresses.
 */
export type ByronAttributes = {
  /**
   * The derivation path is stored encrypted using a ChaCha20/Poly1305 authenticated.
   *
   * Note that there’s no derivation path for Redeem nor Scripts addresses.
   */
  derivationPath?: HexBlob;

  /** Protocol magic (if not 0, then it's a testnet). */
  magic?: number;
};

/**
 * The address type specifies the kind of spending data (Some data that are bound to an address).
 * It’s an extensible object with payload which identifies one of the three elements:
 *
 *  - A Public Key (Payload is thereby a PublicKey)
 *  - A Script (Payload is thereby a script and its version)
 *  - A Redeem Key (Payload is thereby a RedeemPublicKey)
 */
export enum ByronAddressType {
  PubKey = 0,
  Script = 1,
  Redeem = 2
}

/**
 * Byron address internal structure:
 *
 * ┌────────┬──────────────┬────────┐
 * │  root  │  attributes  │  type  │
 * └────────┴──────────────┴────────┘
 *   ╎        ╎              ╎
 *   ╎        ╎              ╰╌╌ PubKey
 *   ╎        ╎              ╰╌╌ Script
 *   ╎        ╎              ╰╌╌ Redeem
 *   ╎        ╰╌╌ Derivation Path
 *   ╎        ╰╌╌ Network Tag
 *   ╎
 *   ╎                   ┌────────┬─────────────────┬──────────────┐
 *   ╰╌╌╌╌ double-hash ( │  type  │  spending data  │  attributes  │ )
 *                       └────────┴─────────────────┴──────────────┘
 *                                  ╎
 *                                  ╰╌╌ Verification Key
 *                                  ╰╌╌ Redemption Key
 */
export type ByronAddressContent = {
  root: Hash28ByteBase16;
  attrs: ByronAttributes;
  type: ByronAddressType;
};

/** Legacy Byron addresses. */
export class ByronAddress {
  readonly #type: AddressType;
  readonly #content: ByronAddressContent;

  /**
   * Initializes a new instance of the ByronAddress class.
   *
   * @param props The address properties.
   * @private
   */
  private constructor(props: AddressProps) {
    this.#content = props.byronAddressContent!;
    this.#type = props.type;
  }

  /**
   * Creates a new instance of the ByronAddress from its credentials.
   *
   * @param root The hash of the keys and attributes.
   * @param attrs The byron attributes.
   * @param type The byron address type.
   */
  static fromCredentials(root: Hash28ByteBase16, attrs: ByronAttributes, type: ByronAddressType): ByronAddress {
    return new ByronAddress({
      byronAddressContent: {
        attrs,
        root,
        type
      },
      type: AddressType.Byron
    });
  }

  /** Gets the attributes of the address (derivation path and network magic). */
  getAttributes(): ByronAttributes {
    return this.#content.attrs;
  }

  /** Gets the root hash of the attributes and credentials. */
  getRoot(): Hash28ByteBase16 {
    return this.#content.root;
  }

  /** Gets the Byron address type. */
  getByronAddressType(): ByronAddressType {
    return this.#content.type;
  }

  /** Converts from ByronAddress instance to Address. */
  toAddress(): Address {
    return new Address({
      byronAddressContent: this.#content,
      type: this.#type
    });
  }

  /**
   * Creates a ByronAddress address from an Address instance.
   *
   * @param addr The address instance to be converted.
   * @returns The ByronAddress instance or undefined if Address is not a valid ByronAddress.
   */
  static fromAddress(addr: Address): ByronAddress | undefined {
    return addr.getProps().type === AddressType.Byron ? new ByronAddress(addr.getProps()) : undefined;
  }

  /**
   * Packs the byron address into its raw binary format.
   *
   * @param props The address properties.
   */
  static packParts(props: AddressProps): Uint8Array {
    const { root, attrs, type } = props.byronAddressContent!;
    let mapSize = 0;

    if (attrs.derivationPath) ++mapSize;
    if (attrs.magic) ++mapSize;

    const writer = new CborWriter();

    writer.writeStartArray(3);
    writer.writeByteString(Buffer.from(root, 'hex'));
    writer.writeStartMap(mapSize);

    if (attrs.derivationPath) {
      // The path must be stored pre-encoded as CBOR.
      const encodedPathCbor = new CborWriter().writeByteString(Buffer.from(attrs.derivationPath, 'hex')).encode();

      writer.writeInt(1);
      writer.writeByteString(encodedPathCbor);
    }

    if (attrs.magic) {
      // The magic must be stored pre-encoded as CBOR.
      const encodedMagicCbor = new CborWriter().writeInt(attrs.magic).encode();

      writer.writeInt(2);
      writer.writeByteString(encodedMagicCbor);
    }

    writer.writeInt(type);

    const addressDataEncoded = Buffer.from(writer.encodeAsHex(), 'hex');

    writer.reset();

    writer.writeStartArray(2);
    writer.writeTag(CborTag.EncodedCborDataItem);
    writer.writeByteString(addressDataEncoded);
    writer.writeInt(crc32(addressDataEncoded));

    return writer.encode();
  }

  /**
   * Unpacks the Byron era address payload.
   *
   * @param type The address type.
   * @param data The serialized address data.
   */
  static unpackParts(type: number, data: Uint8Array): Address {
    let reader = new CborReader(HexBlob.fromBytes(data));

    reader.readStartArray();
    reader.readTag();

    const addressDataEncoded = reader.readByteString();

    if (Number(reader.readInt()) !== crc32(addressDataEncoded))
      throw new InvalidArgumentError('data', 'Invalid Byron raw data. Checksum doesnt match.');

    reader = new CborReader(HexBlob.fromBytes(addressDataEncoded));

    reader.readStartArray();

    const root = Hash28ByteBase16(Buffer.from(reader.readByteString()).toString('hex'));

    reader.readStartMap();
    let magic;
    let derivationPath;

    while (reader.peekState() !== CborReaderState.EndMap) {
      const key = reader.readInt();

      // We need to use a new reader here, because this part of the payload is double encoded.
      switch (key) {
        case 1n: {
          const cborBytes = reader.readByteString();
          derivationPath = HexBlob.fromBytes(new CborReader(HexBlob.fromBytes(cborBytes)).readByteString());
          break;
        }
        case 2n: {
          const cborBytes = reader.readByteString();
          magic = Number(new CborReader(HexBlob.fromBytes(cborBytes)).readInt());
          break;
        }
      }
    }

    reader.readEndMap();

    const byronAddressType = Number(reader.readInt()) as ByronAddressType;

    return new Address({
      byronAddressContent: {
        attrs: { derivationPath, magic },
        root,
        type: byronAddressType
      },
      type
    });
  }
}
