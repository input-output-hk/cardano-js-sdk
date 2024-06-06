import * as Cardano from '../../Cardano/index.js';
import * as Crypto from '@cardano-sdk/crypto';
import { CborReader, CborWriter } from '../CBOR/index.js';
import { CertificateKind } from './CertificateKind.js';
import { CertificateType } from '../../Cardano/index.js';
import { DRep } from './DRep/index.js';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { hexToBytes } from '../../util/misc/index.js';

const EMBEDDED_GROUP_SIZE = 2;

/**
 * This certificate is used when an individual wants to delegate their voting
 * rights to any other DRep and simultaneously wants to delegate their stake to a
 * specific stake pool.
 */
export class StakeVoteDelegation {
  #credential: Cardano.Credential;
  #poolKeyHash: Crypto.Ed25519KeyHashHex;
  #dRep: DRep;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the StakeVoteDelegation class.
   *
   * @param stakeCredential The stake credential to delegate.
   * @param drep The DRep to delegate to.
   * @param poolKeyHash The pool key hash.
   */
  constructor(stakeCredential: Cardano.Credential, drep: DRep, poolKeyHash: Crypto.Ed25519KeyHashHex) {
    this.#credential = stakeCredential;
    this.#dRep = drep;
    this.#poolKeyHash = poolKeyHash;
  }

  /**
   * Serializes a StakeVoteDelegation into CBOR format.
   *
   * @returns The StakeVoteDelegation in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // stake_vote_deleg_cert = (10, stake_credential, pool_keyhash, drep)
    writer.writeStartArray(4);

    writer.writeInt(CertificateKind.StakeVoteDelegation);

    // CDDL
    // stake_credential =
    //   [  0, addr_keyhash
    //   // 1, scripthash
    //   ]
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);
    writer.writeInt(this.#credential.type);
    writer.writeByteString(Buffer.from(this.#credential.hash, 'hex'));

    writer.writeByteString(Buffer.from(this.#poolKeyHash, 'hex'));
    writer.writeEncodedValue(hexToBytes(this.#dRep.toCbor()));

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the StakeVoteDelegation from a CBOR byte array.
   *
   * @param cbor The CBOR encoded StakeVoteDelegation object.
   * @returns The new StakeVoteDelegation instance.
   */
  static fromCbor(cbor: HexBlob): StakeVoteDelegation {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== 4)
      throw new InvalidArgumentError('cbor', `Expected an array of 4 elements, but got an array of ${length} elements`);

    const kind = Number(reader.readInt());

    if (kind !== CertificateKind.StakeVoteDelegation)
      throw new InvalidArgumentError(
        'cbor',
        `Expected certificate kind ${CertificateKind.StakeVoteDelegation}, but got ${kind}`
      );

    const credLength = reader.readStartArray();

    if (credLength !== EMBEDDED_GROUP_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${EMBEDDED_GROUP_SIZE} elements, but got an array of ${length} elements`
      );

    const type = Number(reader.readInt()) as Cardano.CredentialType;
    const hash = Crypto.Hash28ByteBase16(HexBlob.fromBytes(reader.readByteString()));

    reader.readEndArray();

    const poolKeyHash = Crypto.Ed25519KeyHashHex(HexBlob.fromBytes(reader.readByteString()));
    const dRep = DRep.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));

    reader.readEndArray();

    const cert = new StakeVoteDelegation({ hash, type }, dRep, poolKeyHash);
    cert.#originalBytes = cbor;

    return cert;
  }

  /**
   * Creates a Core StakeVoteDelegationCertificate object from the current StakeVoteDelegation object.
   *
   * @returns The Core StakeVoteDelegationCertificate object.
   */
  toCore(): Cardano.StakeVoteDelegationCertificate {
    return {
      __typename: CertificateType.StakeVoteDelegation,
      dRep: this.#dRep.toCore(),
      poolId: Cardano.PoolId.fromKeyHash(this.#poolKeyHash),
      stakeCredential: this.#credential
    };
  }

  /**
   * Creates a StakeVoteDelegation object from the given Core StakeVoteDelegationCertificate object.
   *
   * @param deleg core StakeVoteDelegationCertificate object.
   */
  static fromCore(deleg: Cardano.StakeVoteDelegationCertificate) {
    return new StakeVoteDelegation(
      deleg.stakeCredential,
      DRep.fromCore(deleg.dRep),
      Cardano.PoolId.toKeyHash(deleg.poolId)
    );
  }

  /**
   * Gets the stake credential being delegated.
   *
   * @returns The stake credential.
   */
  stakeCredential(): Cardano.Credential {
    return this.#credential;
  }

  /**
   * Gets the DRep being delegated to.
   *
   * @returns The DRep.
   */
  drep(): DRep {
    return this.#dRep;
  }

  /**
   * Gets the pool has id from this certificate.
   *
   * @returns The pool key hash.
   */
  poolKeyHash(): Crypto.Ed25519KeyHashHex {
    return this.#poolKeyHash;
  }
}
