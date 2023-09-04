import * as Cardano from '../../Cardano';
import * as Crypto from '@cardano-sdk/crypto';
import { CborReader, CborWriter } from '../CBOR';
import { CertificateKind } from './CertificateKind';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';

const EMBEDDED_GROUP_SIZE = 3;
const CREDENTIAL_SIZE = 2;

/**
 * This certificate is used when a stakeholder wants to delegate their stake to a
 * specific stake pool. It includes the stake pool id to which the stake is delegated.
 */
export class StakeDelegation {
  #credential: Cardano.Credential;
  #poolKeyHash: Crypto.Ed25519KeyHashHex;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the StakeDelegation class.
   *
   * @param credential The stake credential.
   * @param poolKeyHash The pool key hash.
   */
  constructor(credential: Cardano.Credential, poolKeyHash: Crypto.Ed25519KeyHashHex) {
    this.#credential = credential;
    this.#poolKeyHash = poolKeyHash;
  }

  /**
   * Serializes a StakeDelegation into CBOR format.
   *
   * @returns The StakeDelegation in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // stake_delegation = (2, stake_credential, pool_keyhash)
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);

    writer.writeInt(CertificateKind.StakeDelegation);

    // CDDL
    // stake_credential =
    //   [  0, addr_keyhash
    //   // 1, scripthash
    //   ]
    writer.writeStartArray(CREDENTIAL_SIZE);
    writer.writeInt(this.#credential.type);
    writer.writeByteString(Buffer.from(this.#credential.hash, 'hex'));

    writer.writeByteString(Buffer.from(this.#poolKeyHash, 'hex'));

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the StakeDelegation from a CBOR byte array.
   *
   * @param cbor The CBOR encoded StakeDelegation object.
   * @returns The new StakeDelegation instance.
   */
  static fromCbor(cbor: HexBlob): StakeDelegation {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== EMBEDDED_GROUP_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${EMBEDDED_GROUP_SIZE} elements, but got an array of ${length} elements`
      );

    const kind = Number(reader.readInt());

    if (kind !== CertificateKind.StakeDelegation)
      throw new InvalidArgumentError(
        'cbor',
        `Expected certificate kind ${CertificateKind.StakeDelegation}, but got ${kind}`
      );

    const credLength = reader.readStartArray();

    if (credLength !== CREDENTIAL_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${CREDENTIAL_SIZE} elements, but got an array of ${length} elements`
      );

    const type = Number(reader.readInt()) as Cardano.CredentialType;
    const hash = Crypto.Hash28ByteBase16(HexBlob.fromBytes(reader.readByteString()));

    reader.readEndArray();

    const poolKeyHash = Crypto.Ed25519KeyHashHex(HexBlob.fromBytes(reader.readByteString()));

    reader.readEndArray();

    const cert = new StakeDelegation({ hash, type }, poolKeyHash);
    cert.#originalBytes = cbor;

    return cert;
  }

  /**
   * Creates a Core StakeDelegationCertificate object from the current StakeDelegation object.
   *
   * @returns The Core StakeDelegationCertificate object.
   */
  toCore(): Cardano.StakeDelegationCertificate {
    return {
      __typename: Cardano.CertificateType.StakeDelegation,
      poolId: Cardano.PoolId.fromKeyHash(this.#poolKeyHash), // TODO: Core type does not support script hash as credential, fix?;
      stakeKeyHash: Crypto.Ed25519KeyHashHex(this.#credential.hash)
    };
  }

  /**
   * Creates a StakeDelegation object from the given Core StakeAddressCertificate object.
   *
   * @param cert core StakeDelegationCertificate object.
   */
  static fromCore(cert: Cardano.StakeDelegationCertificate) {
    return new StakeDelegation(
      { hash: Crypto.Hash28ByteBase16(cert.stakeKeyHash), type: Cardano.CredentialType.KeyHash },
      Cardano.PoolId.toKeyHash(cert.poolId)
    ); // TODO: Core type does not support script hash as credential, fix?
  }

  /**
   * Gets the stake credential from this certificate.
   *
   * @returns The stake credential.
   */
  stakeCredential(): Cardano.Credential {
    return this.#credential;
  }

  /**
   * Sets the stake credential from this certificate.
   *
   * @param credential The stake credential.
   */
  setStakeCredential(credential: Cardano.Credential): void {
    this.#credential = credential;
    this.#originalBytes = undefined;
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
}
