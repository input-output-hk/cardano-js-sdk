/* eslint-disable no-bitwise */
import { Address, AddressType, CredentialType } from './Address.js';
import { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { InvalidArgumentError } from '@cardano-sdk/util';
import type { AddressProps, Credential } from './Address.js';
import type { NetworkId } from '../ChainId.js';

/**
 * Enterprise addresses carry no stake rights, so using these addresses means that you are opting out of participation
 * in the proof-of-stake protocol.
 *
 * Note that using addresses with no stake rights effectively decreases the total amount of stake, which plays
 * into the hands of a potential adversary.
 */
export class EnterpriseAddress {
  readonly #type: AddressType;
  readonly #networkId: NetworkId;
  readonly #paymentPart: Credential;

  /**
   * Initializes a new instance of the EnterpriseAddress class.
   *
   * @param props The address properties.
   * @private
   */
  private constructor(props: AddressProps) {
    this.#networkId = props.networkId!;
    this.#paymentPart = props.paymentPart!;
    this.#type = props.type;
  }

  /**
   * Creates a new instance of the BaseAddress from its credentials.
   *
   * @param networkId The Network identifier.
   * @param payment The payment credential.
   */
  static fromCredentials(networkId: NetworkId, payment: Credential): EnterpriseAddress {
    const type = payment.type === CredentialType.ScriptHash ? AddressType.EnterpriseScript : AddressType.EnterpriseKey;

    return new EnterpriseAddress({
      networkId,
      paymentPart: payment,
      type
    });
  }

  /** Gets the payment credential part of the enterprise address. */
  getPaymentCredential(): Credential {
    return this.#paymentPart;
  }

  /** Converts from EnterpriseAddress instance to Address. */
  toAddress(): Address {
    return new Address({
      networkId: this.#networkId,
      paymentPart: this.#paymentPart,
      type: this.#type
    });
  }

  /**
   * Creates a EnterpriseAddress address from an Address instance.
   *
   * @param addr The address instance to be converted.
   * @returns The EnterpriseAddress instance or undefined if Address is not a valid EnterpriseAddress.
   */
  static fromAddress(addr: Address): EnterpriseAddress | undefined {
    let address;

    switch (addr.getProps().type) {
      case AddressType.EnterpriseKey:
      case AddressType.EnterpriseScript:
        address = new EnterpriseAddress(addr.getProps());
        break;
      default:
    }

    return address;
  }

  /**
   * Packs the enterprise address into its raw binary format.
   *
   * @param props The address properties.
   */
  static packParts(props: AddressProps): Buffer {
    return Buffer.concat([
      Buffer.from([(props.type << 4) | props.networkId!]),
      Buffer.from(props.paymentPart!.hash, 'hex')
    ]);
  }

  /**
   * There are currently 2 types of Shelley Enterprise addresses, summarized below:
   *
   * - 0110 PaymentKeyHash None
   * - 0111 ScriptHash     None
   *
   * @param type The address type.
   * @param data The serialized address data.
   */
  static unpackParts(type: number, data: Uint8Array): Address {
    if (data.length !== 29)
      throw new InvalidArgumentError('data', 'Enterprise address data length should be 29 bytes long.');

    const network = data[0] & 0b0000_1111;
    const paymentCredential = Hash28ByteBase16(Buffer.from(data.slice(1, 29)).toString('hex'));

    return new Address({
      networkId: network,
      paymentPart: {
        hash: paymentCredential,
        type: type === AddressType.EnterpriseScript ? CredentialType.ScriptHash : CredentialType.KeyHash
      },
      type
    });
  }
}
