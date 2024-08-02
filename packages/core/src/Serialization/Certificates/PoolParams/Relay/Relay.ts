import { CborReader } from '../../../CBOR';
import { HexBlob, InvalidStateError } from '@cardano-sdk/util';
import { MultiHostName } from './MultiHostName';
import { SingleHostAddr } from './SingleHostAddr';
import { SingleHostName } from './SingleHostName';
import type * as Cardano from '../../../../Cardano';

/** The relay kind. */
export enum RelayKind {
  SingleHostAddress = 0,
  SingleHostDnsName = 1,
  MultiHostDnsName = 2
}

/**
 * A relay is a type of node that acts as intermediaries between core nodes
 * (which produce blocks) and the wider internet. They help in passing along
 * transactions and blocks, ensuring that data is propagated throughout the
 * network.
 */
export class Relay {
  #singleHostAddr: SingleHostAddr | undefined;
  #singleHostName: SingleHostName | undefined;
  #multiHostName: MultiHostName | undefined;
  #kind: RelayKind;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Serializes a Relay into CBOR format.
   *
   * @returns The Relay in CBOR format.
   */
  toCbor(): HexBlob {
    if (this.#originalBytes) return this.#originalBytes;

    let cbor;

    switch (this.#kind) {
      case RelayKind.SingleHostAddress:
        cbor = this.#singleHostAddr!.toCbor();
        break;
      case RelayKind.SingleHostDnsName:
        cbor = this.#singleHostName!.toCbor();
        break;
      case RelayKind.MultiHostDnsName:
        cbor = this.#multiHostName!.toCbor();
        break;
      default:
        throw new InvalidStateError(`Unexpected kind value: ${this.#kind}`);
    }

    return cbor;
  }

  /**
   * Deserializes the Relay from a CBOR byte array.
   *
   * @param cbor The CBOR encoded Relay object.
   * @returns The new Relay instance.
   */
  static fromCbor(cbor: HexBlob): Relay {
    let relay: Relay;

    const reader = new CborReader(cbor);

    reader.readStartArray();
    const kind = Number(reader.readInt());

    switch (kind) {
      case RelayKind.SingleHostAddress:
        relay = Relay.newSingleHostAddr(SingleHostAddr.fromCbor(cbor));
        break;
      case RelayKind.SingleHostDnsName:
        relay = Relay.newSingleHostName(SingleHostName.fromCbor(cbor));
        break;
      case RelayKind.MultiHostDnsName:
        relay = Relay.newMultiHostName(MultiHostName.fromCbor(cbor));
        break;
      default:
        throw new InvalidStateError(`Unexpected kind value: ${kind}`);
    }

    relay.#originalBytes = cbor;

    return relay;
  }

  /**
   * Creates a Core Relay object from the current Relay object.
   *
   * @returns The Core Relay object.
   */
  toCore(): Cardano.Relay {
    let core;

    switch (this.#kind) {
      case RelayKind.SingleHostAddress:
        core = this.#singleHostAddr!.toCore();
        break;
      case RelayKind.SingleHostDnsName:
        core = this.#singleHostName!.toCore();
        break;
      case RelayKind.MultiHostDnsName:
        core = this.#multiHostName!.toCore();
        break;
      default:
        throw new InvalidStateError(`Unexpected kind value: ${this.#kind}`);
    }

    return core;
  }

  /**
   * Creates a Relay object from the given Core Relay object.
   *
   * @param coreRelay The core Relay object.
   */
  static fromCore(coreRelay: Cardano.Relay): Relay {
    let relay: Relay;

    switch (coreRelay.__typename) {
      case 'RelayByAddress':
        relay = Relay.newSingleHostAddr(SingleHostAddr.fromCore(coreRelay));
        break;
      case 'RelayByName':
        relay = Relay.newSingleHostName(SingleHostName.fromCore(coreRelay));
        break;
      case 'RelayByNameMultihost':
        relay = Relay.newMultiHostName(MultiHostName.fromCore(coreRelay));
        break;
      default:
        throw new InvalidStateError('Unexpected kind value'); // Shouldn't happen.
    }

    return relay;
  }

  /**
   * Gets a Relay from a SingleHostAddr instance.
   *
   * @param singleHostaddr The SingleHostAddr instance to 'cast' to Relay.
   */
  static newSingleHostAddr(singleHostaddr: SingleHostAddr): Relay {
    const relay = new Relay();

    relay.#singleHostAddr = singleHostaddr;
    relay.#kind = RelayKind.SingleHostAddress;

    return relay;
  }

  /**
   * Gets a Relay from a SingleHostName instance.
   *
   * @param singleHostName The SingleHostName instance to 'cast' to Relay.
   */
  static newSingleHostName(singleHostName: SingleHostName): Relay {
    const relay = new Relay();

    relay.#singleHostName = singleHostName;
    relay.#kind = RelayKind.SingleHostDnsName;

    return relay;
  }

  /**
   * Gets a Relay from a MultiHostName instance.
   *
   * @param multiHostName The MultiHostName instance to 'cast' to Relay.
   */
  static newMultiHostName(multiHostName: MultiHostName): Relay {
    const relay = new Relay();

    relay.#multiHostName = multiHostName;
    relay.#kind = RelayKind.MultiHostDnsName;

    return relay;
  }

  /**
   * Gets the relay kind.
   *
   * @returns The relay kind.
   */
  kind(): RelayKind {
    return this.#kind;
  }

  /**
   * Gets a SingleHostAddr from a Relay instance.
   *
   * @returns a SingleHostAddr if the Relay instance can be down cast, otherwise, undefined.
   */
  asSingleHostAddr(): SingleHostAddr | undefined {
    return this.#singleHostAddr;
  }

  /**
   * Gets a SingleHostName from a Relay instance.
   *
   * @returns a SingleHostName if the Relay instance can be down cast, otherwise, undefined.
   */
  asSingleHostName(): SingleHostName | undefined {
    return this.#singleHostName;
  }

  /**
   * Gets a MultiHostName from a Relay instance.
   *
   * @returns a MultiHostName if the Relay instance can be down cast, otherwise, undefined.
   */
  asMultiHostName(): MultiHostName | undefined {
    return this.#multiHostName;
  }
}
