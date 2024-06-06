import * as Cardano from '../../Cardano/index.js';
import * as Crypto from '@cardano-sdk/crypto';
import { CborReader, CborWriter } from '../CBOR/index.js';
import { CertificateKind } from './CertificateKind.js';
import { CertificateType } from '../../Cardano/index.js';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';

const EMBEDDED_GROUP_SIZE = 2;

/** This certificate Register the stake key and delegate with a single certificate to a stake pool. */
export class StakeRegistrationDelegation {
  #credential: Cardano.Credential;
  #poolKeyHash: Crypto.Ed25519KeyHashHex;
  #deposit: Cardano.Lovelace;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the StakeRegistrationDelegation class.
   *
   * @param stakeCredential The stake credential to delegate.
   * @param deposit Must match the expected deposit amount specified by `ppKeyDepositL` in
   * the protocol parameters..
   * @param poolKeyHash The pool key hash.
   */
  constructor(stakeCredential: Cardano.Credential, deposit: Cardano.Lovelace, poolKeyHash: Crypto.Ed25519KeyHashHex) {
    this.#credential = stakeCredential;
    this.#deposit = deposit;
    this.#poolKeyHash = poolKeyHash;
  }

  /**
   * Serializes a StakeRegistrationDelegation into CBOR format.
   *
   * @returns The StakeRegistrationDelegation in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // stake_reg_deleg_cert = (11, stake_credential, pool_keyhash, coin)
    writer.writeStartArray(4);

    writer.writeInt(CertificateKind.StakeRegistrationDelegation);

    // CDDL
    // stake_credential =
    //   [  0, addr_keyhash
    //   // 1, scripthash
    //   ]
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);
    writer.writeInt(this.#credential.type);
    writer.writeByteString(Buffer.from(this.#credential.hash, 'hex'));

    writer.writeByteString(Buffer.from(this.#poolKeyHash, 'hex'));
    writer.writeInt(this.#deposit);

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the StakeRegistrationDelegation from a CBOR byte array.
   *
   * @param cbor The CBOR encoded StakeRegistrationDelegation object.
   * @returns The new StakeRegistrationDelegation instance.
   */
  static fromCbor(cbor: HexBlob): StakeRegistrationDelegation {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== 4)
      throw new InvalidArgumentError('cbor', `Expected an array of 4 elements, but got an array of ${length} elements`);

    const kind = Number(reader.readInt());

    if (kind !== CertificateKind.StakeRegistrationDelegation)
      throw new InvalidArgumentError(
        'cbor',
        `Expected certificate kind ${CertificateKind.StakeRegistrationDelegation}, but got ${kind}`
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
    const deposit = reader.readInt();

    reader.readEndArray();

    const cert = new StakeRegistrationDelegation({ hash, type }, deposit, poolKeyHash);
    cert.#originalBytes = cbor;

    return cert;
  }

  /**
   * Creates a Core StakeRegistrationDelegationCertificate object from the current StakeRegistrationDelegation object.
   *
   * @returns The Core StakeRegistrationDelegationCertificate object.
   */
  toCore(): Cardano.StakeRegistrationDelegationCertificate {
    return {
      __typename: CertificateType.StakeRegistrationDelegation,
      deposit: this.#deposit,
      poolId: Cardano.PoolId.fromKeyHash(this.#poolKeyHash),
      stakeCredential: this.#credential
    };
  }

  /**
   * Creates a StakeRegistrationDelegation object from the given Core StakeRegistrationDelegationCertificate object.
   *
   * @param deleg core StakeRegistrationDelegationCertificate object.
   */
  static fromCore(deleg: Cardano.StakeRegistrationDelegationCertificate) {
    return new StakeRegistrationDelegation(
      deleg.stakeCredential,
      deleg.deposit,
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
   * Gets the deposit.
   *
   * @returns The deposit.
   */
  deposit(): Cardano.Lovelace {
    return this.#deposit;
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
