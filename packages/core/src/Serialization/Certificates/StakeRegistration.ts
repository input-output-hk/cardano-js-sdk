import * as Crypto from '@cardano-sdk/crypto';
import { CborReader, CborWriter } from '../CBOR';
import { CertificateKind } from './CertificateKind';
import { CertificateType } from '../../Cardano/types/Certificate';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import type * as Cardano from '../../Cardano';

const EMBEDDED_GROUP_SIZE = 2;

/**
 * This certificate is used when an individual wants to register as a stakeholder.
 * It allows the holder to participate in the stake process by delegating their
 * stake or creating a stake pool.
 */
export class StakeRegistration {
  #credential: Cardano.Credential;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the StakeRegistration class.
   *
   * @param credential The stake credential.
   */
  constructor(credential: Cardano.Credential) {
    this.#credential = credential;
  }

  /**
   * Serializes a StakeRegistration into CBOR format.
   *
   * @returns The StakeRegistration in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // stake_registration = (0, stake_credential)
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);

    writer.writeInt(CertificateKind.StakeRegistration);

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
   * Deserializes the StakeRegistration from a CBOR byte array.
   *
   * @param cbor The CBOR encoded StakeRegistration object.
   * @returns The new StakeRegistration instance.
   */
  static fromCbor(cbor: HexBlob): StakeRegistration {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== EMBEDDED_GROUP_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${EMBEDDED_GROUP_SIZE} elements, but got an array of ${length} elements`
      );

    const kind = Number(reader.readInt());

    if (kind !== CertificateKind.StakeRegistration)
      throw new InvalidArgumentError(
        'cbor',
        `Expected certificate kind ${CertificateKind.StakeRegistration}, but got ${kind}`
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
    reader.readEndArray();

    const cert = new StakeRegistration({ hash, type });
    cert.#originalBytes = cbor;

    return cert;
  }

  /**
   * Creates a Core StakeAddressCertificate object from the current StakeRegistration object.
   *
   * @returns The Core StakeAddressCertificate object.
   */
  toCore(): Cardano.StakeAddressCertificate {
    return {
      __typename: CertificateType.StakeRegistration,
      stakeCredential: this.#credential
    };
  }

  /**
   * Creates a StakeRegistration object from the given Core StakeAddressCertificate object.
   *
   * @param cert core StakeAddressCertificate object.
   */
  static fromCore(cert: Cardano.StakeAddressCertificate) {
    return new StakeRegistration(cert.stakeCredential);
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
}
