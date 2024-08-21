/* eslint-disable no-bitwise */
import { Address, AddressProps, AddressType, Credential, CredentialType } from './Address';
import { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { InvalidArgumentError, OpaqueNumber } from '@cardano-sdk/util';
import { NetworkId } from '../ChainId';

/**
 * Encodes the specified value with a variable number of bytes.
 *
 * @param val The value to be encoded/compressed.
 * @returns a Buffer with the encoded value.
 */
const variableLengthEncode = (val: number | bigint): Buffer => {
  if (typeof val !== 'bigint') {
    val = BigInt(val);
  }

  if (val < 0) {
    throw new InvalidArgumentError('val', `Negative numbers not supported. Number supplied: ${val}`);
  }

  const encoded = [];
  let bitLength = val.toString(2).length;
  encoded.push(Number(val & 127n));

  while (bitLength > 7) {
    val >>= 7n;
    bitLength -= 7;
    encoded.unshift(Number((val & 127n) + 128n));
  }

  return Buffer.from(encoded);
};

/**
 * Decodes a value previously encoded in a variable length array.
 *
 * @param array The encoded value.
 * @returns the decoded value.
 */
const variableLengthDecode = (array: Buffer): { value: bigint; bytesRead: number } => {
  let more = true;
  let value = 0n;

  let bytesRead = 0;
  while (more && bytesRead < array.length) {
    const b = array[bytesRead];
    value <<= 7n;
    value |= BigInt(b & 127);

    more = (b & 128) !== 0;
    ++bytesRead;
  }

  return { bytesRead, value };
};

/** A transaction index (within a slot). */
export type TxIndex = OpaqueNumber<'TxIndex'>;
export const TxIndex = (value: number): TxIndex => value as unknown as TxIndex;

/** A (delegation) certificate index (within a transaction). */
export type CertIndex = OpaqueNumber<'CertIndex'>;
export const CertIndex = (value: number): CertIndex => value as unknown as CertIndex;

/**
 * A pointer that indirectly specifies the stake key that should control the stake for the address. It references
 * a stake key by a location on the blockchain of the stake key registration certificate.
 */
export type Pointer = {
  slot: bigint;
  txIndex: TxIndex;
  certIndex: CertIndex;
};

/**
 * A pointer address indirectly specifies the stake key that should control the stake for the address. It references
 * a stake key by a stake key pointer, which is a location on the blockchain of the stake key registration certificate
 * for that key.
 */
export class PointerAddress {
  readonly #type: AddressType;
  readonly #networkId: NetworkId;
  readonly #paymentPart: Credential;
  readonly #pointer: Pointer;

  /**
   * Initializes a new instance of the PointerAddress class.
   *
   * @param props The address properties.
   * @private
   */
  private constructor(props: AddressProps) {
    this.#networkId = props.networkId!;
    this.#paymentPart = props.paymentPart!;
    this.#pointer = props.pointer!;
    this.#type = props.type;
  }

  /**
   * Creates a new instance of the PointerAddress from its credentials.
   *
   * @param networkId The Network identifier.
   * @param payment The payment credential.
   * @param pointer A pointer that indirectly specifies the stake key location on chain.
   */
  static fromCredentials(networkId: NetworkId, payment: Credential, pointer: Pointer): PointerAddress {
    let type = AddressType.PointerKey;

    if (payment.type === CredentialType.ScriptHash) type &= 0b0001;

    return new PointerAddress({
      networkId,
      paymentPart: payment,
      pointer,
      type
    });
  }

  /** Gets the payment credential part of the pointer address. */
  getPaymentCredential(): Credential {
    return this.#paymentPart;
  }

  /**
   * The stake credential pointer. This pointer indirectly specifies the stake key that should control
   * the stake for the address.
   */
  getStakePointer(): Pointer {
    return this.#pointer;
  }

  /** Converts from PointerAddress instance to Address. */
  toAddress(): Address {
    return new Address({
      networkId: this.#networkId,
      paymentPart: this.#paymentPart,
      pointer: this.#pointer,
      type: this.#type
    });
  }

  /**
   * Creates a PointerAddress address from an Address instance.
   *
   * @param addr The address instance to be converted.
   * @returns The PointerAddress instance or undefined if Address is not a valid PointerAddress.
   */
  static fromAddress(addr: Address): PointerAddress | undefined {
    let address;

    switch (addr.getProps().type) {
      case AddressType.PointerKey:
      case AddressType.PointerScript:
        address = new PointerAddress(addr.getProps());
        break;
      default:
    }

    return address;
  }

  /**
   * Packs the pointer address into its raw binary format.
   *
   * @param props The address properties.
   */
  static packParts(props: AddressProps): Buffer {
    const { slot, txIndex, certIndex } = props.pointer!;

    return Buffer.concat([
      Buffer.from([(props.type << 4) | props.networkId!]),
      Buffer.from(props.paymentPart!.hash, 'hex'),
      Buffer.concat([variableLengthEncode(slot), variableLengthEncode(txIndex), variableLengthEncode(certIndex)])
    ]);
  }

  /**
   * There are currently 2 types of Shelley Pointer addresses, summarized below:
   *
   * - 0100 PaymentKeyHash Pointer
   * - 0101 ScriptHash     Pointer
   *
   * @param type The address type.
   * @param data The serialized address data.
   */
  static unpackParts(type: number, data: Uint8Array): Address {
    if (data.length <= 29)
      throw new InvalidArgumentError('data', 'Pointer address data length should greater than 29 bytes long.');

    const network = data[0] & 0b0000_1111;
    const paymentCredential = Hash28ByteBase16(Buffer.from(data.slice(1, 29)).toString('hex'));

    let index = 29;
    const dataBuffer = Buffer.from(data);
    const { value: slot, bytesRead: slotBytes } = variableLengthDecode(dataBuffer.subarray(index));

    index += slotBytes;
    const { value: txIndex, bytesRead: txIndexBytes } = variableLengthDecode(dataBuffer.subarray(index));

    index += txIndexBytes;
    const { value: certIndex } = variableLengthDecode(dataBuffer.subarray(index));

    return new Address({
      networkId: network,
      paymentPart: {
        hash: paymentCredential,
        type: type === AddressType.PointerScript ? CredentialType.ScriptHash : CredentialType.KeyHash
      },
      pointer: { certIndex: CertIndex(Number(certIndex)), slot, txIndex: TxIndex(Number(txIndex)) },
      type
    });
  }
}
