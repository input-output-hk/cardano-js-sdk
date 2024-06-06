import * as Cardano from '../../Cardano/index.js';
import * as Crypto from '@cardano-sdk/crypto';
import { CborReader, CborWriter } from '../CBOR/index.js';
import { CertificateKind } from './CertificateKind.js';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';

const EMBEDDED_GROUP_SIZE = 2;

/**
 * This certificate is used when an individual wants to register as a stakeholder.
 * It allows the holder to participate in the staking process by delegating their
 * stake or creating a stake pool.
 *
 * This certificate also provides the ability to specify the deposit amount.
 *
 * Deposit must match the expected deposit amount specified by `ppKeyDepositL` in
 * the protocol parameters.
 *
 * Remark: Replaces the deprecated `StakeRegistration` in after Conway era.
 */
export class Registration {
  #credential: Cardano.Credential;
  #deposit: Cardano.Lovelace;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the Registration class.
   *
   * @param credential The stake credential.
   * @param deposit Must match the expected deposit amount specified by `ppKeyDepositL` in
   * the protocol parameters..
   */
  constructor(credential: Cardano.Credential, deposit: Cardano.Lovelace) {
    this.#credential = credential;
    this.#deposit = deposit;
  }

  /**
   * Serializes a Registration into CBOR format.
   *
   * @returns The Registration in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // reg_cert = (7, stake_credential, coin)
    writer.writeStartArray(3);

    writer.writeInt(CertificateKind.Registration);

    // CDDL
    // stake_credential =
    //   [  0, addr_keyhash
    //   // 1, scripthash
    //   ]
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);
    writer.writeInt(this.#credential.type);
    writer.writeByteString(Buffer.from(this.#credential.hash, 'hex'));
    writer.writeInt(this.#deposit);

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the Registration from a CBOR byte array.
   *
   * @param cbor The CBOR encoded Registration object.
   * @returns The new Registration instance.
   */
  static fromCbor(cbor: HexBlob): Registration {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== 3)
      throw new InvalidArgumentError('cbor', `Expected an array of 3 elements, but got an array of ${length} elements`);

    const kind = Number(reader.readInt());

    if (kind !== CertificateKind.Registration)
      throw new InvalidArgumentError(
        'cbor',
        `Expected certificate kind ${CertificateKind.Registration}, but got ${kind}`
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

    const deposit = reader.readInt();

    reader.readEndArray();

    const cert = new Registration({ hash, type }, deposit);
    cert.#originalBytes = cbor;

    return cert;
  }

  /**
   * Creates a Core NewStakeAddressCertificate object from the current Registration object.
   *
   * @returns The Core NewStakeAddressCertificate object.
   */
  toCore(): Cardano.NewStakeAddressCertificate {
    return {
      __typename: Cardano.CertificateType.Registration,
      deposit: this.#deposit,
      stakeCredential: this.#credential
    };
  }

  /**
   * Creates a Registration object from the given Core StakeAddressCertificate object.
   *
   * @param cert core StakeAddressCertificate object.
   */
  static fromCore(cert: Cardano.NewStakeAddressCertificate) {
    return new Registration(cert.stakeCredential, cert.deposit);
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
   * Gets the deposit from this certificate.
   *
   * @returns The stake credential.
   */
  deposit(): Cardano.Lovelace {
    return this.#deposit;
  }

  /**
   * Sets the deposit from this certificate.
   *
   * @param deposit The deposit.
   */
  setDeposit(deposit: Cardano.Lovelace): void {
    this.#deposit = deposit;
    this.#originalBytes = undefined;
  }
}
