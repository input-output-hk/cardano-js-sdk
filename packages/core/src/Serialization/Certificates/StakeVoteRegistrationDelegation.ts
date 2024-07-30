import * as Crypto from '@cardano-sdk/crypto';
import { CborReader, CborWriter } from '../CBOR';
import { CertificateKind } from './CertificateKind';
import { CertificateType, Lovelace, PoolId, StakeVoteRegistrationDelegationCertificate } from '../../Cardano/types';
import { Credential, CredentialType } from '../../Cardano/Address/Address';
import { DRep } from './DRep';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { hexToBytes } from '../../util/misc';

const EMBEDDED_GROUP_SIZE = 2;

/**
 * This certificate is used when an individual wants to register its stake key,
 * delegate their voting rights to any other DRep and simultaneously wants to delegate
 * their stake to a specific stake pool.
 */
export class StakeVoteRegistrationDelegation {
  #credential: Credential;
  #dRep: DRep;
  #poolKeyHash: Crypto.Ed25519KeyHashHex;
  #deposit: Lovelace;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the StakeVoteRegistrationDelegation class.
   *
   * @param stakeCredential The stake credential to delegate.
   * @param deposit Must match the expected deposit amount specified by `ppKeyDepositL` in
   * the protocol parameters.
   * @param dRep The DRep to delegate to.
   * @param poolKeyHash The pool key hash.
   */
  constructor(stakeCredential: Credential, deposit: Lovelace, dRep: DRep, poolKeyHash: Crypto.Ed25519KeyHashHex) {
    this.#credential = stakeCredential;
    this.#deposit = deposit;
    this.#dRep = dRep;
    this.#poolKeyHash = poolKeyHash;
  }

  /**
   * Serializes a StakeVoteRegistrationDelegation into CBOR format.
   *
   * @returns The StakeVoteRegistrationDelegation in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // stake_vote_reg_deleg_cert = (13, stake_credential, pool_keyhash, drep, coin)
    writer.writeStartArray(5);

    writer.writeInt(CertificateKind.StakeVoteRegistrationDelegation);

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
    writer.writeInt(this.#deposit);

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the StakeVoteRegistrationDelegation from a CBOR byte array.
   *
   * @param cbor The CBOR encoded StakeVoteRegistrationDelegation object.
   * @returns The new StakeVoteRegistrationDelegation instance.
   */
  static fromCbor(cbor: HexBlob): StakeVoteRegistrationDelegation {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== 5)
      throw new InvalidArgumentError('cbor', `Expected an array of 5 elements, but got an array of ${length} elements`);

    const kind = Number(reader.readInt());

    if (kind !== CertificateKind.StakeVoteRegistrationDelegation)
      throw new InvalidArgumentError(
        'cbor',
        `Expected certificate kind ${CertificateKind.StakeVoteRegistrationDelegation}, but got ${kind}`
      );

    const credLength = reader.readStartArray();

    if (credLength !== EMBEDDED_GROUP_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${EMBEDDED_GROUP_SIZE} elements, but got an array of ${length} elements`
      );

    const type = Number(reader.readInt()) as CredentialType;
    const hash = Crypto.Hash28ByteBase16(HexBlob.fromBytes(reader.readByteString()));

    reader.readEndArray();

    const poolKeyHash = Crypto.Ed25519KeyHashHex(HexBlob.fromBytes(reader.readByteString()));
    const dRep = DRep.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
    const deposit = reader.readInt();

    reader.readEndArray();

    const cert = new StakeVoteRegistrationDelegation({ hash, type }, deposit, dRep, poolKeyHash);
    cert.#originalBytes = cbor;

    return cert;
  }

  /**
   * Creates a Core StakeVoteRegistrationDelegationCertificate object from the current StakeVoteRegistrationDelegation object.
   *
   * @returns The Core StakeVoteRegistrationDelegationCertificate object.
   */
  toCore(): StakeVoteRegistrationDelegationCertificate {
    return {
      __typename: CertificateType.StakeVoteRegistrationDelegation,
      dRep: this.#dRep.toCore(),
      deposit: this.#deposit,
      poolId: PoolId.fromKeyHash(this.#poolKeyHash),
      stakeCredential: this.#credential
    };
  }

  /**
   * Creates a StakeVoteRegistrationDelegation object from the given Core StakeVoteRegistrationDelegationCertificate object.
   *
   * @param deleg core StakeVoteRegistrationDelegationCertificate object.
   */
  static fromCore(deleg: StakeVoteRegistrationDelegationCertificate) {
    return new StakeVoteRegistrationDelegation(
      deleg.stakeCredential,
      deleg.deposit,
      DRep.fromCore(deleg.dRep),
      PoolId.toKeyHash(deleg.poolId)
    );
  }

  /**
   * Gets the stake credential being delegated.
   *
   * @returns The stake credential.
   */
  stakeCredential(): Credential {
    return this.#credential;
  }

  /**
   * Gets the deposit.
   *
   * @returns The deposit.
   */
  deposit(): Lovelace {
    return this.#deposit;
  }

  /**
   * Gets the DRep being delegated to.
   *
   * @returns The DRep.
   */
  dRep(): DRep {
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
