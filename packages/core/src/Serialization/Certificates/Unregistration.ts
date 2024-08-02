import * as Crypto from '@cardano-sdk/crypto';
import { CborReader, CborWriter } from '../CBOR';
import { CertificateKind } from './CertificateKind';
import { CertificateType } from '../../Cardano/types/Certificate';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import type * as Cardano from '../../Cardano';

const EMBEDDED_GROUP_SIZE = 2;

/**
 * This certificate is used when a stakeholder no longer wants to participate in
 * staking. It revokes the stake Unregistration and the associated stake is no
 * longer counted when calculating stake pool rewards.
 *
 * Deposit must match the expected deposit amount specified by `ppKeyDepositL` in
 * the protocol parameters.
 *
 * Remark: Replaces the deprecated `StakeDeregistration` in after Conway era.
 */
export class Unregistration {
  #credential: Cardano.Credential;
  #deposit: Cardano.Lovelace;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the Unregistration class.
   *
   * @param credential The stake credential.
   * @param deposit Must match the expected deposit amount specified by `ppKeyDepositL` in
   * the protocol parameters.
   */
  constructor(credential: Cardano.Credential, deposit: Cardano.Lovelace) {
    this.#credential = credential;
    this.#deposit = deposit;
  }

  /**
   * Serializes a Unregistration into CBOR format.
   *
   * @returns The Unregistration in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // unreg_cert = (8, stake_credential, coin)
    writer.writeStartArray(3);

    writer.writeInt(CertificateKind.Unregistration);

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
   * Deserializes the Unregistration from a CBOR byte array.
   *
   * @param cbor The CBOR encoded Unregistration object.
   * @returns The new Unregistration instance.
   */
  static fromCbor(cbor: HexBlob): Unregistration {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== 3)
      throw new InvalidArgumentError('cbor', `Expected an array of 3 elements, but got an array of ${length} elements`);

    const kind = Number(reader.readInt());

    if (kind !== CertificateKind.Unregistration)
      throw new InvalidArgumentError(
        'cbor',
        `Expected certificate kind ${CertificateKind.Unregistration}, but got ${kind}`
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

    const cert = new Unregistration({ hash, type }, deposit);
    cert.#originalBytes = cbor;

    return cert;
  }

  /**
   * Creates a Core NewStakeAddressCertificate object from the current Unregistration object.
   *
   * @returns The Core NewStakeAddressCertificate object.
   */
  toCore(): Cardano.NewStakeAddressCertificate {
    return {
      __typename: CertificateType.Unregistration,
      deposit: this.#deposit,
      stakeCredential: this.#credential
    };
  }

  /**
   * Creates a Unregistration object from the given Core StakeAddressCertificate object.
   *
   * @param cert core StakeAddressCertificate object.
   */
  static fromCore(cert: Cardano.NewStakeAddressCertificate) {
    return new Unregistration(cert.stakeCredential, cert.deposit);
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
