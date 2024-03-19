import * as Cardano from '../../Cardano';
import { CborReader, CborWriter } from '../CBOR';
import { CertificateKind } from './CertificateKind';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { PoolParams } from './PoolParams';

// The group flattens the PoolParams along with one field for the certificate type
const EMBEDDED_GROUP_SIZE = PoolParams.subgroupCount + 1;

/**
 * This certificate is used to register a new stake pool. It includes various details
 * about the pool such as the pledge, costs, margin, reward account, and the pool's owners and relays.
 */
export class PoolRegistration {
  #params: PoolParams;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the PoolRegistration class.
   *
   * @param params The pool registration/update parameters.
   */
  constructor(params: PoolParams) {
    this.#params = params;
  }

  /**
   * Serializes a PoolRegistration into CBOR format.
   *
   * @returns The PoolRegistration in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // pool_registration = (3, pool_params)
    // pool_params is a basic group which means its fields will flatten into pool_registration
    // rather that inserted as a subgroup.
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);

    writer.writeInt(CertificateKind.PoolRegistration);

    return this.#params.toFlattenedCbor(writer);
  }

  /**
   * Deserializes the PoolRegistration from a CBOR byte array.
   *
   * @param cbor The CBOR encoded PoolRegistration object.
   * @returns The new PoolRegistration instance.
   */
  static fromCbor(cbor: HexBlob): PoolRegistration {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== EMBEDDED_GROUP_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${EMBEDDED_GROUP_SIZE} elements, but got an array of ${length} elements`
      );

    const kind = Number(reader.readInt());

    if (kind !== CertificateKind.PoolRegistration)
      throw new InvalidArgumentError(
        'cbor',
        `Expected certificate kind ${CertificateKind.PoolRegistration}, but got ${kind}`
      );

    const params = PoolParams.fromFlattenedCbor(reader);

    reader.readEndArray();

    const cert = new PoolRegistration(params);
    cert.#originalBytes = cbor;

    return cert;
  }

  /**
   * Creates a Core PoolRegistrationCertificate object from the current PoolRegistration object.
   *
   * @returns The Core PoolRegistrationCertificate object.
   */
  toCore(): Cardano.PoolRegistrationCertificate {
    return {
      __typename: Cardano.CertificateType.PoolRegistration,
      poolParameters: this.#params.toCore()
    };
  }

  /**
   * Creates a PoolRegistration object from the given Core PoolRegistrationCertificate object.
   *
   * @param cert core PoolRegistrationCertificate object.
   */
  static fromCore(cert: Cardano.PoolRegistrationCertificate) {
    return new PoolRegistration(PoolParams.fromCore(cert.poolParameters)); // TODO: Core type does not support script hash as credential, fix?
  }

  /**
   * Gets the pool parameters from this certificate.
   *
   * @returns The pool parameters.
   */
  poolParameters(): PoolParams {
    return this.#params;
  }

  /**
   * Sets the pool parameters from this certificate.
   *
   * @param parameters The pool parameters.
   */
  setPoolParameters(parameters: PoolParams): void {
    this.#params = parameters;
    this.#originalBytes = undefined;
  }
}
