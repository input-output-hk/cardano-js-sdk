import { CborReader, CborWriter } from '../../../CBOR';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import type * as Cardano from '../../../../Cardano';

const EMBEDDED_GROUP_SIZE = 2;
const MULTI_HOST_NAME_RELAY_ID = 2;
const MAX_DNS_SIZE_STR_LENGTH = 64;

/** This relay points to a multi host name via a DNS (A SRV DNS record) name. */
export class MultiHostName {
  #dnsName: string;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the MultiHostName relay.
   *
   * @param dnsName The DNS name of the relay (A SRV DNS record).
   */
  constructor(dnsName: string) {
    if (dnsName.length > MAX_DNS_SIZE_STR_LENGTH)
      throw new InvalidArgumentError(
        'dnsName',
        `dnsName must be less or equal to 64 characters long, actual size ${dnsName.length}`
      );

    this.#dnsName = dnsName;
  }

  /**
   * Serializes a MultiHostName into CBOR format.
   *
   * @returns The MultiHostName in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // multi_host_name = ( 2
    //                    , dns_name ; A SRV DNS record
    //                    )
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);
    writer.writeInt(MULTI_HOST_NAME_RELAY_ID);
    writer.writeTextString(this.#dnsName);

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the MultiHostName from a CBOR byte array.
   *
   * @param cbor The CBOR encoded MultiHostName object.
   * @returns The new MultiHostName instance.
   */
  static fromCbor(cbor: HexBlob): MultiHostName {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== EMBEDDED_GROUP_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${EMBEDDED_GROUP_SIZE} elements, but got an array of ${length} elements`
      );

    const id = Number(reader.readInt());

    if (id !== MULTI_HOST_NAME_RELAY_ID)
      throw new InvalidArgumentError('cbor', `Expected MultiHostName id ${MULTI_HOST_NAME_RELAY_ID}, but got ${id}`);

    const dnsName = reader.readTextString();

    const relay = new MultiHostName(dnsName);

    relay.#originalBytes = cbor;

    return relay;
  }

  /**
   * Creates a Core RelayByNameMultihost object from the current MultiHostName object.
   *
   * @returns The Core RelayByNameMultihost object.
   */
  toCore(): Cardano.RelayByNameMultihost {
    return {
      __typename: 'RelayByNameMultihost',
      dnsName: this.#dnsName
    };
  }

  /**
   * Creates a MultiHostName object from the given Core RelayByNameMultihost object.
   *
   * @param relay The core RelayByNameMultihost object.
   */
  static fromCore(relay: Cardano.RelayByNameMultihost) {
    return new MultiHostName(relay.dnsName);
  }

  /**
   * Gets the DNS name of the relay.
   *
   * @returns The DNS name of the relay (A SRV DNS record).
   */
  dnsName(): string {
    return this.#dnsName;
  }

  /**
   * Sets DNS name of the relay.
   *
   * @param dnsName The DNS name of the relay (A SRV DNS record).
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
