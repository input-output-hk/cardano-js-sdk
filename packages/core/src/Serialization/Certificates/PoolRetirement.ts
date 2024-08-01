import * as Crypto from '@cardano-sdk/crypto';
import { CborReader, CborWriter } from '../CBOR';
import { CertificateKind } from './CertificateKind';
import { CertificateType, EpochNo, PoolId, PoolRetirementCertificate } from '../../Cardano/types';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';

const EMBEDDED_GROUP_SIZE = 3;

/** This certificate is used to retire a stake pool. It includes an epoch number indicating when the pool will be retired. */
export class PoolRetirement {
  #poolKeyHash: Crypto.Ed25519KeyHashHex;
  #epoch: EpochNo;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the PoolRetirement class.
   *
   * @param poolKeyHash The pool key hash.
   * @param epoch The epoch at which the pool will be retired.
   */
  constructor(poolKeyHash: Crypto.Ed25519KeyHashHex, epoch: EpochNo) {
    this.#poolKeyHash = poolKeyHash;
    this.#epoch = epoch;
  }

  /**
   * Serializes a PoolRetirement into CBOR format.
   *
   * @returns The PoolRetirement in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // pool_retirement = (4, pool_keyhash, epoch)
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);

    writer.writeInt(CertificateKind.PoolRetirement);

    writer.writeByteString(Buffer.from(this.#poolKeyHash, 'hex'));
    writer.writeInt(this.#epoch);

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the PoolRetirement from a CBOR byte array.
   *
   * @param cbor The CBOR encoded PoolRetirement object.
   * @returns The new PoolRetirement instance.
   */
  static fromCbor(cbor: HexBlob): PoolRetirement {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== EMBEDDED_GROUP_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${EMBEDDED_GROUP_SIZE} elements, but got an array of ${length} elements`
      );

    const kind = Number(reader.readInt());

    if (kind !== CertificateKind.PoolRetirement)
      throw new InvalidArgumentError(
        'cbor',
        `Expected certificate kind ${CertificateKind.PoolRetirement}, but got ${kind}`
      );

    const poolKeyHash = Crypto.Ed25519KeyHashHex(HexBlob.fromBytes(reader.readByteString()));
    const epoch = reader.readInt();

    reader.readEndArray();

    const cert = new PoolRetirement(poolKeyHash, EpochNo(Number(epoch)));
    cert.#originalBytes = cbor;

    return cert;
  }

  /**
   * Creates a Core PoolRetirementCertificate object from the current PoolRetirement object.
   *
   * @returns The Core PoolRetirementCertificate object.
   */
  toCore(): PoolRetirementCertificate {
    return {
      __typename: CertificateType.PoolRetirement,
      epoch: this.#epoch,
      poolId: PoolId.fromKeyHash(this.#poolKeyHash)
    };
  }

  /**
   * Creates a PoolRetirement object from the given Core StakeAddressCertificate object.
   *
   * @param cert core PoolRetirementCertificate object.
   */
  static fromCore(cert: PoolRetirementCertificate) {
    return new PoolRetirement(PoolId.toKeyHash(cert.poolId), cert.epoch);
  }

  /**
   * Gets the pool has id from this certificate.
   *
   * @returns The pool key hash.
   */
  poolKeyHash(): Crypto.Ed25519KeyHashHex {
    return this.#poolKeyHash;
  }

  /**
   * Sets the pool has id from this certificate.
   *
   * @param poolKeyHash The pool key hash.
   */
  setPoolKeyHash(poolKeyHash: Crypto.Ed25519KeyHashHex): void {
    this.#poolKeyHash = poolKeyHash;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the epoch at which the pool will be retired.
   *
   * @returns The epoch at which the pool will be retired.
   */
  epoch(): EpochNo {
    return this.#epoch;
  }

  /**
   * Sets the epoch at which the pool will be retired.
   *
   * @param epoch The epoch at which the pool will be retired.
   */
  setEpoch(epoch: EpochNo): void {
    this.#epoch = epoch;
    this.#originalBytes = undefined;
  }
}
