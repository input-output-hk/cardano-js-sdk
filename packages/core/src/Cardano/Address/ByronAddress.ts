/* eslint-disable no-bitwise */
import { Address, AddressProps, AddressType } from './Address';
import { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { crc32 } from '@foxglove/crc';
import Cbor from 'borc';

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

  /**
   * Protocol magic (if not 0, then it's a testnet).
   */
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

/**
 * Legacy Byron addresses.
 */
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

  /**
   * Gets the attributes of the address (derivation path and network magic).
   */
  getAttributes(): ByronAttributes {
    return this.#content.attrs;
  }

  /**
   * Gets the root hash of the attributes and credentials.
   */
  getRoot(): Hash28ByteBase16 {
    return this.#content.root;
  }

  /**
   * Gets the Byron address type.
   */
  getByronAddressType(): ByronAddressType {
    return this.#content.type;
  }

  /**
   * Converts from ByronAddress instance to Address.
   */
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
    const addressAttributes = new Map();

    const { root, attrs, type } = props.byronAddressContent!;

    if (attrs.derivationPath) addressAttributes.set(1, Cbor.encode(Buffer.from(attrs.derivationPath, 'hex')));
    if (attrs.magic) addressAttributes.set(2, Cbor.encode(attrs.magic));

    const addressData = [Buffer.from(root, 'hex'), addressAttributes, type];
    const addressDataEncoded = Cbor.encode(addressData);

    return Cbor.encode([new Cbor.Tagged(24, addressDataEncoded), crc32(addressDataEncoded)]);
  }

  /**
   * Unpacks the Byron era address payload.
   *
   * @param type The address type.
   * @param data The serialized address data.
   */
  static unpackParts(type: number, data: Uint8Array): Address {
    // Strip the 24 CBOR data tags (the "[0].value" part)
    const addressAsBuffer = Cbor.decode(data);
    const addressDataEncoded = addressAsBuffer[0].value;
    const addressContent = Cbor.decode(addressDataEncoded);

    const checksum = addressAsBuffer[1];

    if (checksum !== crc32(addressDataEncoded))
      throw new InvalidArgumentError('data', 'Invalid Byron raw data. Checksum doesnt match.');

    const root = Hash28ByteBase16(Buffer.from(addressContent[0]).toString('hex'));
    let attributes = addressContent[1];

    // cbor decoder decodes empty map as empty object, so we re-cast it to Map(0)
    if (!(attributes instanceof Map)) {
      attributes = new Map();
    }

    const derivationPath = attributes.has(1)
      ? HexBlob(Buffer.from(Cbor.decode(attributes.get(1))).toString('hex'))
      : undefined;
    const magic = attributes.has(2) ? Cbor.decode(attributes.get(2)) : undefined;
    const byronAddressType = addressContent[2] as ByronAddressType;

    return new Address({
      byronAddressContent: { attrs: { derivationPath, magic }, root, type: byronAddressType },
      type
    });
  }
}
