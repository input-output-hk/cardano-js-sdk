import * as Cardano from '../../Cardano';
import * as Crypto from '@cardano-sdk/crypto';
import { CborReader, CborWriter } from '../CBOR';
import { CertificateKind } from './CertificateKind';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';

const EMBEDDED_GROUP_SIZE = 2;

/** This certificate is used then a committee member wants to resign early (will be marked on-chain as an expired member). */
export class ResignCommitteeCold {
  #committeeColdCred: Cardano.Credential;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the ResignCommitteeCold class.
   *
   * @param committeeColdCred The committee cold credential.
   */
  constructor(committeeColdCred: Cardano.Credential) {
    this.#committeeColdCred = committeeColdCred;
  }

  /**
   * Serializes a ResignCommitteeCold into CBOR format.
   *
   * @returns The ResignCommitteeCold in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // resign_committee_cold_cert = (15, committee_cold_credential)
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);

    writer.writeInt(CertificateKind.ResignCommitteeCold);

    // CDDL
    // stake_credential =
    //   [  0, addr_keyhash
    //   // 1, scripthash
    //   ]
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);
    writer.writeInt(this.#committeeColdCred.type);
    writer.writeByteString(Buffer.from(this.#committeeColdCred.hash, 'hex'));

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the ResignCommitteeCold from a CBOR byte array.
   *
   * @param cbor The CBOR encoded ResignCommitteeCold object.
   * @returns The new ResignCommitteeCold instance.
   */
  static fromCbor(cbor: HexBlob): ResignCommitteeCold {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== EMBEDDED_GROUP_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${EMBEDDED_GROUP_SIZE} elements, but got an array of ${length} elements`
      );

    const kind = Number(reader.readInt());

    if (kind !== CertificateKind.ResignCommitteeCold)
      throw new InvalidArgumentError(
        'cbor',
        `Expected certificate kind ${CertificateKind.ResignCommitteeCold}, but got ${kind}`
      );

    const coldCredLength = reader.readStartArray();

    if (coldCredLength !== EMBEDDED_GROUP_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${EMBEDDED_GROUP_SIZE} elements, but got an array of ${length} elements`
      );

    const coldType = Number(reader.readInt()) as Cardano.CredentialType;
    const coldHash = Crypto.Hash28ByteBase16(HexBlob.fromBytes(reader.readByteString()));

    reader.readEndArray();

    reader.readEndArray();

    const cert = new ResignCommitteeCold({ hash: coldHash, type: coldType });
    cert.#originalBytes = cbor;

    return cert;
  }

  /**
   * Creates a Core ResignCommitteeColdCertificate object from the current ResignCommitteeCold object.
   *
   * @returns The Core ResignCommitteeColdCertificate object.
   */
  toCore(): Cardano.ResignCommitteeColdCertificate {
    return {
      __typename: Cardano.CertificateType.ResignCommitteeCold,
      coldCredential: this.#committeeColdCred
    };
  }

  /**
   * Creates a ResignCommitteeCold object from the given Core ResignCommitteeColdCertificate object.
   *
   * @param cert core ResignCommitteeColdCertificate object.
   */
  static fromCore(cert: Cardano.ResignCommitteeColdCertificate) {
    return new ResignCommitteeCold(cert.coldCredential);
  }

  /**
   * Gets the cold credential.
   *
   * @returns The cold credential.
   */
  coldCredential(): Cardano.Credential {
    return this.#committeeColdCred;
  }
}
