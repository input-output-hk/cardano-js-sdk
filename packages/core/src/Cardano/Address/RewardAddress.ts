/* eslint-disable no-bitwise */
import { Address, AddressType, CredentialType } from './Address.js';
import { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { InvalidArgumentError } from '@cardano-sdk/util';
import type { AddressProps, Credential } from './Address.js';
import type { NetworkId } from '../ChainId.js';

/**
 * A reward address is a cryptographic hash of the public stake key of the address. Reward account addresses are used
 * to distribute rewards for participating in the proof-of-stake protocol (either directly or via delegation).
 */
export class RewardAddress {
  readonly #type: AddressType;
  readonly #networkId: NetworkId;
  readonly #paymentPart: Credential;

  /**
   * Initializes a new instance of the RewardAddress class.
   *
   * @param props The address properties.
   * @private
   */
  // eslint-disable-next-line sonarjs/no-identical-functions
  private constructor(props: AddressProps) {
    this.#networkId = props.networkId!;
    this.#paymentPart = props.paymentPart!;
    this.#type = props.type;
  }

  /**
   * Creates a new instance of the RewardAddress from its credentials.
   *
   * @param networkId The Network identifier.
   * @param payment The payment credential.
   */
  static fromCredentials(networkId: NetworkId, payment: Credential): RewardAddress {
    let type = AddressType.RewardKey;

    if (payment.type === CredentialType.ScriptHash) type |= 0b0001;

    return new RewardAddress({
      networkId,
      paymentPart: payment,
      type
    });
  }

  /**
   * Gets the payment credential part of the reward address.
   *
   * Note: by convention, the key inside reward addresses are NOT considered stake credentials,
   * pointer addresses and the chain history is required to resolve its associated credential
   */
  getPaymentCredential(): Credential {
    return this.#paymentPart;
  }

  /** Converts from RewardAddress instance to Address. */
  // eslint-disable-next-line sonarjs/no-identical-functions
  toAddress(): Address {
    return new Address({
      networkId: this.#networkId,
      paymentPart: this.#paymentPart,
      type: this.#type
    });
  }

  /**
   * Creates a RewardAddress address from an Address instance.
   *
   * @param addr The address instance to be converted.
   * @returns The RewardAddress instance or undefined if Address is not a valid RewardAddress.
   */
  static fromAddress(addr: Address): RewardAddress | undefined {
    let address;

    switch (addr.getProps().type) {
      case AddressType.RewardKey:
      case AddressType.RewardScript:
        address = new RewardAddress(addr.getProps());
        break;
      default:
    }

    return address;
  }

  /**
   * Packs the reward address into its raw binary format.
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
   * There are currently 2 types of Stake addresses, summarized below:
   *
   * - 0110 None StakeKeyHash
   * - 0111 None ScriptHash
   *
   * @param type The address type.
   * @param data The serialized address data.
   */
  static unpackParts(type: number, data: Uint8Array): Address {
    if (data.length !== 29)
      throw new InvalidArgumentError('data', 'Enterprise address data length should be 29 bytes long.');

    const network = data[0] & 0b0000_1111;
    const stakeCredential = Hash28ByteBase16(Buffer.from(data.slice(1, 29)).toString('hex'));

    return new Address({
      networkId: network,
      // Note: by convention, the key inside reward addresses are NOT considered stake credentials,
      // pointer addresses and the chain history is required to resolve its associated credential
      paymentPart: {
        hash: stakeCredential,
        type: type === AddressType.RewardScript ? CredentialType.ScriptHash : CredentialType.KeyHash
      },
      type
    });
  }
}
