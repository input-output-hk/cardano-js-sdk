import { CborReader, CborReaderState, CborWriter } from '../../../CBOR';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { byteArrayToIPv6String, byteArrayToIpV4String, ipV4StringToByteArray, ipV6StringToByteArray } from './ipUtils';
import type * as Cardano from '../../../../Cardano';

const EMBEDDED_GROUP_SIZE = 4;
const SINGLE_HOST_ADDR_RELAY_ID = 0;

/** This relay points to a single host via its ipv4/ipv6 address and a given port. */
export class SingleHostAddr {
  #port: number | undefined;
  #ipV4: string | undefined;
  #ipV6: string | undefined;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the SingleHostAddr relay.
   *
   * @param port The port of the relay.
   * @param ipv4 The IP v4 address of the relay.
   * @param ipv6 The IP v6 address of the relay.
   */
  constructor(port?: number, ipv4?: string, ipv6?: string) {
    this.#port = port;
    this.#ipV4 = ipv4;
    this.#ipV6 = ipv6;
  }

  /**
   * Serializes a SingleHostAddr into CBOR format.
   *
   * @returns The SingleHostAddr in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // single_host_addr = ( 0
    //                    , port / null
    //                    , ipv4 / null
    //                    , ipv6 / null
    //                    )
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);
    writer.writeInt(SINGLE_HOST_ADDR_RELAY_ID);
    this.#port ? writer.writeInt(this.#port) : writer.writeNull();
    this.#ipV4 ? writer.writeByteString(ipV4StringToByteArray(this.#ipV4)) : writer.writeNull();
    this.#ipV6 ? writer.writeByteString(ipV6StringToByteArray(this.#ipV6)) : writer.writeNull();

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the SingleHostAddr from a CBOR byte array.
   *
   * @param cbor The CBOR encoded SingleHostAddr object.
   * @returns The new SingleHostAddr instance.
   */
  static fromCbor(cbor: HexBlob): SingleHostAddr {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== EMBEDDED_GROUP_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${EMBEDDED_GROUP_SIZE} elements, but got an array of ${length} elements`
      );

    const id = Number(reader.readInt());

    if (id !== SINGLE_HOST_ADDR_RELAY_ID)
      throw new InvalidArgumentError('cbor', `Expected SingleHostAddr id ${SINGLE_HOST_ADDR_RELAY_ID}, but got ${id}`);

    let port;
    let ipV4;
    let ipV6;

    if (reader.peekState() === CborReaderState.Null) {
      reader.readNull();
      port = undefined;
    } else {
      port = reader.readInt();
    }

    if (reader.peekState() === CborReaderState.Null) {
      reader.readNull();
      ipV4 = undefined;
    } else {
      ipV4 = byteArrayToIpV4String(reader.readByteString());
    }

    if (reader.peekState() === CborReaderState.Null) {
      reader.readNull();
      ipV6 = undefined;
    } else {
      ipV6 = byteArrayToIPv6String(reader.readByteString());
    }

    const relay = new SingleHostAddr(port ? Number(port) : undefined, ipV4, ipV6);

    relay.#originalBytes = cbor;

    return relay;
  }

  /**
   * Creates a Core RelayByAddress object from the current SingleHostAddr object.
   *
   * @returns The Core RelayByAddress object.
   */
  toCore(): Cardano.RelayByAddress {
    return {
      __typename: 'RelayByAddress',
      ipv4: this.#ipV4,
      ipv6: this.#ipV6,
      port: this.#port
    };
  }

  /**
   * Creates a SingleHostAddr object from the given Core RelayByAddress object.
   *
   * @param relay The core RelayByAddress object.
   */
  static fromCore(relay: Cardano.RelayByAddress) {
    return new SingleHostAddr(relay.port, relay.ipv4, relay.ipv6);
  }

  /**
   * Gets the port of the relay.
   *
   * @returns The port (0-65535).
   */
  port(): number | undefined {
    return this.#port;
  }

  /**
   * Sets the port of the relay.
   *
   * @param port The port (0-65535) or undefined if it should not be set.
   */
  setPort(port: number | undefined): void {
    this.#port = port;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the IP v4 address of the relay.
   *
   * @returns The IP v4 address.
   */
  ipv4(): string | undefined {
    return this.#ipV4;
  }

  /**
   * Sets the IP v4 address of the relay.
   *
   * @param ipV4 The IP v4 address or undefined if it should not be set.
   */
  setIpv4(ipV4: string | undefined): void {
    this.#ipV4 = ipV4;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the IP v6 address of the relay.
   *
   * @returns The IP v6 address.
   */
  ipv6(): string | undefined {
    return this.#ipV6;
  }

  /**
   * Sets the IP v6 address of the relay.
   *
   * @param ipV6 The IP v6 address or undefined if it should not be set.
   */
  setIpv6(ipV6: string | undefined): void {
    this.#ipV6 = ipV6;
    this.#originalBytes = undefined;
  }
}
