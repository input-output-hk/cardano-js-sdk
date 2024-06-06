import * as Cardano from '../../Cardano/index.js';
import * as Crypto from '@cardano-sdk/crypto';
import { Anchor } from '../Common/index.js';
import { CborReader, CborReaderState, CborWriter } from '../CBOR/index.js';
import { CertificateKind } from './CertificateKind.js';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { hexToBytes } from '../../util/misc/index.js';

const EMBEDDED_GROUP_SIZE = 2;

/** This certificate is used then a committee member wants to resign early (will be marked on-chain as an expired member). */
export class ResignCommitteeCold {
  #committeeColdCred: Cardano.Credential;
  #anchor: Anchor | undefined;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the ResignCommitteeCold class.
   *
   * @param committeeColdCred The committee cold credential.
   * @param anchor The anchor.
   */
  constructor(committeeColdCred: Cardano.Credential, anchor?: Anchor) {
    this.#committeeColdCred = committeeColdCred;
    this.#anchor = anchor;
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
    // resign_committee_cold_cert = (15, committee_cold_credential, anchor / null)
    writer.writeStartArray(3);

    writer.writeInt(CertificateKind.ResignCommitteeCold);

    // CDDL
    // stake_credential =
    //   [  0, addr_keyhash
    //   // 1, scripthash
    //   ]
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);
    writer.writeInt(this.#committeeColdCred.type);
    writer.writeByteString(Buffer.from(this.#committeeColdCred.hash, 'hex'));

    if (this.#anchor) {
      writer.writeEncodedValue(hexToBytes(this.#anchor.toCbor()));
    } else {
      writer.writeNull();
    }

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

    if (length !== 3)
      throw new InvalidArgumentError('cbor', `Expected an array of 3 elements, but got an array of ${length} elements`);

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

    let anchor;

    if (reader.peekState() === CborReaderState.Null) {
      reader.readNull();
    } else {
      anchor = Anchor.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
    }

    reader.readEndArray();

    const cert = new ResignCommitteeCold({ hash: coldHash, type: coldType }, anchor);
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
      anchor: this.#anchor ? this.#anchor.toCore() : null,
      coldCredential: this.#committeeColdCred
    };
  }

  /**
   * Creates a ResignCommitteeCold object from the given Core ResignCommitteeColdCertificate object.
   *
   * @param cert core ResignCommitteeColdCertificate object.
   */
  static fromCore(cert: Cardano.ResignCommitteeColdCertificate) {
    return new ResignCommitteeCold(cert.coldCredential, cert.anchor ? Anchor.fromCore(cert.anchor) : undefined);
  }

  /**
   * Gets the cold credential.
   *
   * @returns The cold credential.
   */
  coldCredential(): Cardano.Credential {
    return this.#committeeColdCred;
  }

  /**
   * Gets the anchor.
   *
   * @returns The anchor.
   */
  anchor(): Anchor | undefined {
    return this.#anchor;
  }
}
