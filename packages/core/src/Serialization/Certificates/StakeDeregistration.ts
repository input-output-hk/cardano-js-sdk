import * as Crypto from '@cardano-sdk/crypto';
import { CborReader, CborWriter } from '../CBOR';
import { CertificateKind } from './CertificateKind';
import { CertificateType, StakeAddressCertificate } from '../../Cardano/types/Certificate';
import { Credential, CredentialType } from '../../Cardano/Address/Address';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';

const EMBEDDED_GROUP_SIZE = 2;

/**
 * This certificate is used when a stakeholder no longer wants to participate in
 * staking. It revokes the stake registration and the associated stake is no
 * longer counted when calculating stake pool rewards.
 */
export class StakeDeregistration {
  #credential: Credential;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the StakeDeregistration class.
   *
   * @param credential The stake credential.
   */
  constructor(credential: Credential) {
    this.#credential = credential;
  }

  /**
   * Serializes a StakeDeregistration into CBOR format.
   *
   * @returns The StakeDeregistration in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // stake_deregistration = (1, stake_credential)
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);

    writer.writeInt(CertificateKind.StakeDeregistration);

    // CDDL
    // stake_credential =
    //   [  0, addr_keyhash
    //   // 1, scripthash
    //   ]
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);
    writer.writeInt(this.#credential.type);
    writer.writeByteString(Buffer.from(this.#credential.hash, 'hex'));

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the StakeDeregistration from a CBOR byte array.
   *
   * @param cbor The CBOR encoded StakeDeregistration object.
   * @returns The new StakeDeregistration instance.
   */
  static fromCbor(cbor: HexBlob): StakeDeregistration {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== EMBEDDED_GROUP_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${EMBEDDED_GROUP_SIZE} elements, but got an array of ${length} elements`
      );

    const kind = Number(reader.readInt());

    if (kind !== CertificateKind.StakeDeregistration)
      throw new InvalidArgumentError(
        'cbor',
        `Expected certificate kind ${CertificateKind.StakeDeregistration}, but got ${kind}`
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
    reader.readEndArray();

    const cert = new StakeDeregistration({ hash, type });
    cert.#originalBytes = cbor;

    return cert;
  }

  /**
   * Creates a Core StakeAddressCertificate object from the current StakeDeregistration object.
   *
   * @returns The Core StakeAddressCertificate object.
   */
  toCore(): StakeAddressCertificate {
    return {
      __typename: CertificateType.StakeDeregistration,
      stakeCredential: this.#credential
    };
  }

  /**
   * Creates a StakeDeregistration object from the given Core StakeAddressCertificate object.
   *
   * @param cert core StakeAddressCertificate object.
   */
  static fromCore(cert: StakeAddressCertificate) {
    return new StakeDeregistration(cert.stakeCredential);
  }

  /**
   * Gets the stake credential from this certificate.
   *
   * @returns The stake credential.
   */
  stakeCredential(): Credential {
    return this.#credential;
  }

  /**
   * Sets the stake credential from this certificate.
   *
   * @param credential The stake credential.
   */
  setStakeCredential(credential: Credential): void {
    this.#credential = credential;
    this.#originalBytes = undefined;
  }
}
