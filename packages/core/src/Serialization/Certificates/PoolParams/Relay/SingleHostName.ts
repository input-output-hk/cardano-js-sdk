import { CborReader, CborReaderState, CborWriter } from '../../../CBOR/index.js';
import { InvalidArgumentError } from '@cardano-sdk/util';
import type * as Cardano from '../../../../Cardano/index.js';
import type { HexBlob } from '@cardano-sdk/util';

const EMBEDDED_GROUP_SIZE = 3;
const SINGLE_HOST_NAME_RELAY_ID = 1;
const MAX_DNS_SIZE_STR_LENGTH = 64;

/** This relay points to a single host via a DNS (pointing to an A or AAAA DNS record) name and a given port. */
export class SingleHostName {
  #port: number | undefined;
  #dnsName: string;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the SingleHostName relay.
   *
   * @param dnsName The DNS name of the relay (pointing to an A or AAAA DNS record).
   * @param port The port of the relay.
   */
  constructor(dnsName: string, port?: number | undefined) {
    this.#port = port;

    if (dnsName.length > MAX_DNS_SIZE_STR_LENGTH)
      throw new InvalidArgumentError(
        'dnsName',
        `dnsName must be less or equal to 64 characters long, actual size ${dnsName.length}`
      );

    this.#dnsName = dnsName;
  }

  /**
   * Serializes a SingleHostName into CBOR format.
   *
   * @returns The SingleHostName in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // single_host_name = ( 1
    //                    , port / null
    //                    , dns_name ; An A or AAAA DNS record
    //                    )
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);
    writer.writeInt(SINGLE_HOST_NAME_RELAY_ID);
    this.#port ? writer.writeInt(this.#port) : writer.writeNull();
    writer.writeTextString(this.#dnsName);

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the SingleHostName from a CBOR byte array.
   *
   * @param cbor The CBOR encoded SingleHostName object.
   * @returns The new SingleHostName instance.
   */
  static fromCbor(cbor: HexBlob): SingleHostName {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== EMBEDDED_GROUP_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${EMBEDDED_GROUP_SIZE} elements, but got an array of ${length} elements`
      );

    const id = Number(reader.readInt());

    if (id !== SINGLE_HOST_NAME_RELAY_ID)
      throw new InvalidArgumentError('cbor', `Expected SingleHostName id ${SINGLE_HOST_NAME_RELAY_ID}, but got ${id}`);

    let port;

    if (reader.peekState() === CborReaderState.Null) {
      reader.readNull();
      port = undefined;
    } else {
      port = reader.readInt();
    }

    const dnsName = reader.readTextString();

    const relay = new SingleHostName(dnsName, port ? Number(port) : undefined);

    relay.#originalBytes = cbor;

    return relay;
  }

  /**
   * Creates a Core RelayByName object from the current SingleHostName object.
   *
   * @returns The Core RelayByName object.
   */
  toCore(): Cardano.RelayByName {
    return {
      __typename: 'RelayByName',
      hostname: this.#dnsName,
      port: this.#port
    };
  }

  /**
   * Creates a SingleHostName object from the given Core RelayByName object.
   *
   * @param relay The core RelayByName object.
   */
  static fromCore(relay: Cardano.RelayByName) {
    return new SingleHostName(relay.hostname, relay.port);
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
   * Gets the DNS name of the relay.
   *
   * @returns The DNS name of the relay (pointing to an A or AAAA DNS record).
   */
  dnsName(): string {
    return this.#dnsName;
  }

  /**
   * Sets DNS name of the relay.
   *
   * @param dnsName The DNS name of the relay (pointing to an A or AAAA DNS record).
   */
  setDnsName(dnsName: string): void {
    if (dnsName.length > MAX_DNS_SIZE_STR_LENGTH)
      throw new InvalidArgumentError(
        'dnsName',
        `dnsName must be less or equal to 64 characters long, actual size ${dnsName.length}`
      );

    this.#dnsName = dnsName;
    this.#originalBytes = undefined;
  }
}
