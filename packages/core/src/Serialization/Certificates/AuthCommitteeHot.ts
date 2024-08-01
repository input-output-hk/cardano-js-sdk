import * as Crypto from '@cardano-sdk/crypto';
import { AuthorizeCommitteeHotCertificate, CertificateType } from '../../Cardano/types/Certificate';
import { CborReader, CborWriter } from '../CBOR';
import { CertificateKind } from './CertificateKind';
import { Credential, CredentialType } from '../../Cardano/Address/Address';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';

const EMBEDDED_GROUP_SIZE = 2;

/** This certificate registers the Hot and Cold credentials of a committee member. */
export class AuthCommitteeHot {
  #committeeColdCred: Credential;
  #committeeHotCred: Credential;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the AuthCommitteeHot class.
   *
   * @param committeeColdCred The committee cold credential.
   * @param committeeHotCred The committee hot credential.
   */
  constructor(committeeColdCred: Credential, committeeHotCred: Credential) {
    this.#committeeColdCred = committeeColdCred;
    this.#committeeHotCred = committeeHotCred;
  }

  /**
   * Serializes a AuthCommitteeHot into CBOR format.
   *
   * @returns The AuthCommitteeHot in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // auth_committee_hot_cert = (14, committee_cold_credential, committee_hot_credential)
    writer.writeStartArray(3);

    writer.writeInt(CertificateKind.AuthCommitteeHot);

    // CDDL
    // stake_credential =
    //   [  0, addr_keyhash
    //   // 1, scripthash
    //   ]
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);
    writer.writeInt(this.#committeeColdCred.type);
    writer.writeByteString(Buffer.from(this.#committeeColdCred.hash, 'hex'));

    writer.writeStartArray(EMBEDDED_GROUP_SIZE);
    writer.writeInt(this.#committeeHotCred.type);
    writer.writeByteString(Buffer.from(this.#committeeHotCred.hash, 'hex'));

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the AuthCommitteeHot from a CBOR byte array.
   *
   * @param cbor The CBOR encoded AuthCommitteeHot object.
   * @returns The new AuthCommitteeHot instance.
   */
  static fromCbor(cbor: HexBlob): AuthCommitteeHot {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== 3)
      throw new InvalidArgumentError('cbor', `Expected an array of 3 elements, but got an array of ${length} elements`);

    const kind = Number(reader.readInt());

    if (kind !== CertificateKind.AuthCommitteeHot)
      throw new InvalidArgumentError(
        'cbor',
        `Expected certificate kind ${CertificateKind.AuthCommitteeHot}, but got ${kind}`
      );

    const coldCredLength = reader.readStartArray();

    if (coldCredLength !== EMBEDDED_GROUP_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${EMBEDDED_GROUP_SIZE} elements, but got an array of ${length} elements`
      );

    const coldType = Number(reader.readInt()) as CredentialType;
    const coldHash = Crypto.Hash28ByteBase16(HexBlob.fromBytes(reader.readByteString()));

    reader.readEndArray();

    const hotCredLength = reader.readStartArray();

    if (hotCredLength !== EMBEDDED_GROUP_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${EMBEDDED_GROUP_SIZE} elements, but got an array of ${length} elements`
      );

    const hotType = Number(reader.readInt()) as CredentialType;
    const hotHash = Crypto.Hash28ByteBase16(HexBlob.fromBytes(reader.readByteString()));

    reader.readEndArray();

    reader.readEndArray();

    const cert = new AuthCommitteeHot({ hash: coldHash, type: coldType }, { hash: hotHash, type: hotType });
    cert.#originalBytes = cbor;

    return cert;
  }

  /**
   * Creates a Core AuthCommitteeHotCertificate object from the current AuthCommitteeHot object.
   *
   * @returns The Core AuthCommitteeHotCertificate object.
   */
  toCore(): AuthorizeCommitteeHotCertificate {
    return {
      __typename: CertificateType.AuthorizeCommitteeHot,
      coldCredential: this.#committeeColdCred,
      hotCredential: this.#committeeHotCred
    };
  }

  /**
   * Creates a AuthCommitteeHot object from the given Core AuthCommitteeHotCertificate object.
   *
   * @param cert core AuthCommitteeHotCertificate object.
   */
  static fromCore(cert: AuthorizeCommitteeHotCertificate) {
    return new AuthCommitteeHot(cert.coldCredential, cert.hotCredential);
  }

  /**
   * Gets the cold credential.
   *
   * @returns The cold credential.
   */
  coldCredential(): Credential {
    return this.#committeeColdCred;
  }

  /**
   * Gets the hot credential.
   *
   * @returns The hot credential.
   */
  hotCredential(): Credential {
    return this.#committeeHotCred;
  }
}
