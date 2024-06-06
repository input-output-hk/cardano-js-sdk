/* eslint-disable no-bitwise */
import * as BaseEncoding from '@scure/base';
import { BaseAddress } from './BaseAddress.js';
import { ByronAddress } from './ByronAddress.js';
import { EnterpriseAddress } from './EnterpriseAddress.js';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { NetworkId } from '../ChainId.js';
import { PointerAddress } from './PointerAddress.js';
import { RewardAddress } from './RewardAddress.js';
import type { ByronAddressContent } from './ByronAddress.js';
import type { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import type { PaymentAddress } from './PaymentAddress.js';
import type { Pointer } from './PointerAddress.js';
import type { RewardAccount } from './RewardAccount.js';

const MAX_BECH32_LENGTH_LIMIT = 1023;

/**
 * Shelley introduces four different types of addresses:
 *
 *  - base addresses
 *     bits 7-6 : 00
 *     bit  5   : stake cred is keyhash/scripthash
 *     bit  4   : payment cred is keyhash/scripthash
 *     bits 3-0 : network id
 *
 *  - pointer addresses
 *     bits 7-5 : 010
 *     bit  4   : payment cred is keyhash/scripthash
 *     bits 3-0 : network id
 *
 *  - enterprise addresses
 *     bits 7-5 : 010
 *     bit 4    : payment cred is keyhash/scripthash
 *     bits 3-0 : network id
 *
 *  - reward account addresses
 *     bits 7-5 : 111
 *     bit  4   : credential is keyhash/scripthash
 *     bits 3-0 : network id
 *
 * Besides, those new addresses, Shelley continues to support Byron-era bootstrap addresses and script addresses,
 * but only the new base and pointer addresses carry stake rights.
 *
 *  - byron addresses:
 *     bits 7-4 : 1000
 *     bits 3-0 : unrelated data (no network ID in Byron addresses)
 */
export enum AddressType {
  BasePaymentKeyStakeKey = 0b0000,
  BasePaymentScriptStakeKey = 0b0001,
  BasePaymentKeyStakeScript = 0b0010,
  BasePaymentScriptStakeScript = 0b0011,
  PointerKey = 0b0100,
  PointerScript = 0b0101,
  EnterpriseKey = 0b0110,
  EnterpriseScript = 0b0111,
  // 0b1000 was chosen because all existing Byron addresses actually start with 0b1000,
  // therefore we can re-use Byron addresses as-is
  Byron = 0b1000,
  RewardKey = 0b1110,
  RewardScript = 0b1111
  // 1001-1101 are left for future formats
}

/**
 * The credential type, a credential could be:
 *
 * - The stake key hash or payment key hash, blake2b-224 hash digests of Ed25519 verification keys.
 * - The script hash, blake2b-224 hash digests of serialized monetary scripts.
 */
export enum CredentialType {
  KeyHash = 0,
  ScriptHash = 1
}

/** The credential specifies who should control the funds or the staking rights for that address. */
export type Credential = {
  type: CredentialType;
  hash: Hash28ByteBase16;
};

/**
 * Address headers are 1 byte long, bits [7;4] indicate the type of addresses being used. The remaining four
 * bits [3;0] are either unused or refer to the network id.
 */
export type AddressHeader = {
  type: AddressType;
  networkId: NetworkId;
};

/** Address object initialization properties. */
export type AddressProps = {
  /** Specify the type of the address. There are currently 8 types of Shelley addresses and 1 for Byron addresses. */
  type: AddressType;

  /** Network identifier (taken from the second half of the header (bits [3;0])). Note: not present in Bryon addresses. */
  networkId?: NetworkId;

  /**
   * Refers to a point of the chain containing a stake key registration certificate.
   *
   * A point is identified by 3 coordinates:
   *
   *  - An absolute slot number
   *  - A transaction index (within that slot)
   *  - A (delegation) certificate index (within that transaction)
   */
  pointer?: Pointer;

  /**
   * Indicates the ownership of the funds associated with the address. Whoever owns the payment parts owns any funds
   * at the address. In order to spend from an address, one must provide a witness attesting that the address can
   * be spent. In the case of a PubKeyHash, it means providing a signature of the transaction body made with the
   * signing key corresponding to the hashed public key (as well as the public key itself for verification).
   *
   * For monetary scripts, it means being able to provide the source script and meet the necessary conditions
   * to validate the script.
   */
  paymentPart?: Credential;

  /**
   * Indicates the owner of the stake rights associated with the address. Whoever owns the delegation parts owns
   * the stake rights of any funds associated with the address. In most scenarios, the payment part and the delegation
   * part are owned by the same party. Yet it is possible to construct addresses where both parts are owned and
   * managed by separate entities.
   */
  delegationPart?: Credential;

  /** Byron addresses content (kept for backward compatibility with Byron addresses). */
  byronAddressContent?: ByronAddressContent;
};

/** The addresses are a blake2b-256 hash of the relevant verifying/public keys concatenated with some metadata. */
export class Address {
  readonly #props: AddressProps;

  /**
   * Initializes a new instance of the Address class.
   *
   * @param props The Address object initialization properties.
   * @private
   */
  public constructor(props: AddressProps) {
    this.#props = props;
  }

  /**
   * Creates an Address object from serialized Address data.
   *
   * @param hex The serialized address data.
   */
  // eslint-disable-next-line complexity
  static fromBytes(hex: HexBlob): Address {
    const data = Buffer.from(hex, 'hex');
    const type = data[0] >> 4;
    let address: Address;

    switch (type) {
      case AddressType.BasePaymentKeyStakeKey:
      case AddressType.BasePaymentScriptStakeKey:
      case AddressType.BasePaymentKeyStakeScript:
      case AddressType.BasePaymentScriptStakeScript: {
        address = BaseAddress.unpackParts(type, data);
        break;
      }
      case AddressType.PointerKey:
      case AddressType.PointerScript: {
        address = PointerAddress.unpackParts(type, data);
        break;
      }
      case AddressType.EnterpriseKey:
      case AddressType.EnterpriseScript: {
        address = EnterpriseAddress.unpackParts(type, data);
        break;
      }
      case AddressType.RewardKey:
      case AddressType.RewardScript: {
        address = RewardAddress.unpackParts(type, data);
        break;
      }
      case AddressType.Byron: {
        address = ByronAddress.unpackParts(type, data);
        break;
      }
      default:
        throw new InvalidArgumentError('data', 'Invalid address raw data');
    }

    return address;
  }

  /** Gets the byte array representation of this address. */
  // eslint-disable-next-line complexity
  toBytes(): HexBlob {
    let cborData;
    switch (this.#props.type) {
      case AddressType.BasePaymentKeyStakeKey:
      case AddressType.BasePaymentScriptStakeKey:
      case AddressType.BasePaymentKeyStakeScript:
      case AddressType.BasePaymentScriptStakeScript: {
        cborData = BaseAddress.packParts(this.#props);
        break;
      }
      case AddressType.PointerKey:
      case AddressType.PointerScript: {
        cborData = PointerAddress.packParts(this.#props);
        break;
      }
      case AddressType.EnterpriseKey:
      case AddressType.EnterpriseScript: {
        cborData = EnterpriseAddress.packParts(this.#props);
        break;
      }
      case AddressType.RewardKey:
      case AddressType.RewardScript: {
        cborData = RewardAddress.packParts(this.#props);
        break;
      }
      case AddressType.Byron: {
        cborData = ByronAddress.packParts(this.#props);
        break;
      }
      default:
        throw new Error('Invalid address'); // Shouldn't happen
    }

    return HexBlob.fromBytes(cborData);
  }

  /** Gets an address instance from a valid Base58 encoded address. */
  static fromBase58(base58Address: string) {
    return Address.fromBytes(HexBlob.fromBytes(BaseEncoding.base58.decode(base58Address)));
  }

  /**
   * Encodes this address to Base58.
   *
   * @throws if is a Shelley address. In principle, it is possible for Shelley address to be encoded in Base58. However,
   * implementations are discouraged to encode addresses against the convention, as this helps with the goal that lay
   * users only encounter a single, canonical version of every address. (See CIP-19.)
   */
  toBase58(): PaymentAddress {
    if (this.#props.type !== AddressType.Byron) throw new Error('Only Byron addresses will be encoded in base58');

    return BaseEncoding.base58.encode(Buffer.from(this.toBytes(), 'hex')) as PaymentAddress;
  }

  /**
   * Encodes this address to bech32.
   *
   * @throws if is a Shelley address. In principle, it is possible for Byron address to be encoded in Bech32. However,
   * implementations are discouraged to encode addresses against the convention, as this helps with the goal that lay
   * users only encounter a single, canonical version of every address. (See CIP-19.)
   */
  toBech32(): PaymentAddress | RewardAccount {
    const words = BaseEncoding.bech32.toWords(Buffer.from(this.toBytes(), 'hex'));

    if (this.#props.type === AddressType.Byron) throw new Error('Only Shelley addresses will be encoded in bech32');

    const prefix = Address.getBech32Prefix(this.#props.type, this.#props.networkId!);
    const bech32Address = BaseEncoding.bech32.encode(prefix, words, MAX_BECH32_LENGTH_LIMIT);

    return this.#props.type === AddressType.RewardKey || this.#props.type === AddressType.RewardScript
      ? (bech32Address as RewardAccount)
      : (bech32Address as PaymentAddress);
  }

  /**
   * Decodes a bech32 encoded address into an Address instance.
   *
   * @param bech32 The bech32 encoded address.
   */
  static fromBech32(bech32: string): Address {
    const { words } = BaseEncoding.bech32.decode(bech32, MAX_BECH32_LENGTH_LIMIT);

    return Address.fromBytes(HexBlob.fromBytes(BaseEncoding.bech32.fromWords(words)));
  }

  /**
   * Tries to parse an address from a given string.
   *
   * @param address The address string representation.
   * @returns The address object if it could be parsed; otherwise, null.
   */
  static fromString(address: string): Address | null {
    try {
      if (Address.isValidBech32(address)) return Address.fromBech32(address);

      if (Address.isValidByron(address)) return Address.fromBase58(address);

      // If everything fails try to parse as hex/cbor string.
      return Address.fromBytes(HexBlob(address));
    } catch {
      // Do nothing.
    }

    return null;
  }

  /** Checks whether the given bech32 string is valid. Note: bech32-encoded Byron addresses will also pass validation here */
  static isValidBech32(bech32: string): boolean {
    try {
      Address.fromBech32(bech32);
    } catch {
      return false;
    }

    return true;
  }

  /**
   * Gets whether the given base58 address is a valid byron address.
   *
   * @param base58 The base58 encoded address.
   */
  static isValidByron(base58: string): boolean {
    try {
      // We deserialized the whole address since this also performs the Byron CRC checksum verification.
      const addr = Address.fromBase58(base58);

      if (addr.#props.type !== AddressType.Byron) return false;
    } catch {
      return false;
    }

    return true;
  }

  /**
   * Gets whether the given encoded address is valid.
   *
   * @param address The encoded address.
   */
  static isValid(address: string): boolean {
    return Address.isValidBech32(address) || Address.isValidByron(address);
  }

  /** Gets this Address instance as a ByronAddress (undefined if Address is not a valid ByronAddress). */
  asByron(): ByronAddress | undefined {
    return ByronAddress.fromAddress(this);
  }

  /** Gets this Address instance as a RewardAddress (undefined if Address is not a valid RewardAddress). */
  asReward(): RewardAddress | undefined {
    return RewardAddress.fromAddress(this);
  }

  /** Gets this Address instance as a PointerAddress (undefined if Address is not a valid PointerAddress). */
  asPointer(): PointerAddress | undefined {
    return PointerAddress.fromAddress(this);
  }

  /** Gets this Address instance as a EnterpriseAddress (undefined if Address is not a valid EnterpriseAddress). */
  asEnterprise(): EnterpriseAddress | undefined {
    return EnterpriseAddress.fromAddress(this);
  }

  /** Gets this Address instance as a BaseAddress (undefined if Address is not a valid BaseAddress). */
  asBase(): BaseAddress | undefined {
    return BaseAddress.fromAddress(this);
  }

  /** Gets the address type. */
  getType(): AddressType {
    return this.#props.type;
  }

  /** Gets the address network id. */
  getNetworkId(): NetworkId {
    if (this.#props.type === AddressType.Byron) {
      // Byron addresses do not encode the network identifier, however, they include an optional attribute
      // 'network magic', the network magic is only set to specify which testnet this address is for (if any). We can
      // then assume that if the network magic is undefined the network id is mainnet; otherwise; testnet.
      if (this.#props.byronAddressContent?.attrs.magic === undefined) return NetworkId.Mainnet;

      return NetworkId.Testnet;
    }

    return this.#props.networkId!;
  }

  /** Gets the address properties. */
  getProps(): AddressProps {
    return this.#props;
  }

  /** Gets the address bech32 prefix. */
  // eslint-disable-next-line complexity
  private static getBech32Prefix(type: AddressType, networkId: NetworkId): string {
    let prefix = '';
    switch (type) {
      case AddressType.BasePaymentKeyStakeKey:
      case AddressType.BasePaymentScriptStakeKey:
      case AddressType.BasePaymentKeyStakeScript:
      case AddressType.BasePaymentScriptStakeScript:
      case AddressType.PointerKey:
      case AddressType.PointerScript:
      case AddressType.EnterpriseKey:
      case AddressType.EnterpriseScript:
        prefix = 'addr';
        break;
      case AddressType.RewardKey:
      case AddressType.RewardScript: {
        prefix = 'stake';
        break;
      }
      default:
        throw new Error('Invalid address'); // Shouldn't happen
    }

    prefix += networkId === 0 ? '_test' : '';

    return prefix;
  }
}

/** Validate input as a Cardano Address from all Cardano eras and networks */
export const isAddress = (input: string): boolean => Address.isValid(input);
