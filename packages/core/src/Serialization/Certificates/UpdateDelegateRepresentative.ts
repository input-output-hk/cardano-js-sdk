import * as Crypto from '@cardano-sdk/crypto';
import { Anchor } from '../Common';
import { CborReader, CborReaderState, CborWriter } from '../CBOR';
import { CertificateKind } from './CertificateKind';
import { CertificateType } from '../../Cardano/types/Certificate';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { hexToBytes } from '../../util/misc';
import type * as Cardano from '../../Cardano';

const EMBEDDED_GROUP_SIZE = 2;

/** Updates the DRep anchored metadata. */
export class UpdateDelegateRepresentative {
  #drepCredential: Cardano.Credential;
  #anchor: Anchor | undefined;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the UpdateDelegateRepresentative class.
   *
   * @param drepCredential The DRep credential.
   * @param anchor The anchor.
   */
  constructor(drepCredential: Cardano.Credential, anchor?: Anchor) {
    this.#drepCredential = drepCredential;
    this.#anchor = anchor;
  }

  /**
   * Serializes a UpdateDelegateRepresentative into CBOR format.
   *
   * @returns The UpdateDelegateRepresentative in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // update_drep_cert = (18, drep_credential, anchor / null)
    writer.writeStartArray(3);

    writer.writeInt(CertificateKind.UpdateDrep);

    // CDDL
    // stake_credential =
    //   [  0, addr_keyhash
    //   // 1, scripthash
    //   ]
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);
    writer.writeInt(this.#drepCredential.type);
    writer.writeByteString(Buffer.from(this.#drepCredential.hash, 'hex'));

    if (this.#anchor) {
      writer.writeEncodedValue(hexToBytes(this.#anchor.toCbor()));
    } else {
      writer.writeNull();
    }

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the UpdateDelegateRepresentative from a CBOR byte array.
   *
   * @param cbor The CBOR encoded UpdateDelegateRepresentative object.
   * @returns The new UpdateDelegateRepresentative instance.
   */
  static fromCbor(cbor: HexBlob): UpdateDelegateRepresentative {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== 3)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${EMBEDDED_GROUP_SIZE} elements, but got an array of ${length} elements`
      );

    const kind = Number(reader.readInt());

    if (kind !== CertificateKind.UpdateDrep)
      throw new InvalidArgumentError(
        'cbor',
        `Expected certificate kind ${CertificateKind.UpdateDrep}, but got ${kind}`
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

    let anchor;

    if (reader.peekState() === CborReaderState.Null) {
      reader.readNull();
    } else {
      anchor = Anchor.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
    }

    reader.readEndArray();

    const cert = new UpdateDelegateRepresentative({ hash, type }, anchor);
    cert.#originalBytes = cbor;

    return cert;
  }

  /**
   * Creates a Core UpdateDelegateRepresentativeCertificate object from the current UpdateDelegateRepresentative object.
   *
   * @returns The Core UpdateDelegateRepresentativeCertificate object.
   */
  toCore(): Cardano.UpdateDelegateRepresentativeCertificate {
    return {
      __typename: CertificateType.UpdateDelegateRepresentative,
      anchor: this.#anchor ? this.#anchor.toCore() : null,
      dRepCredential: this.#drepCredential
    };
  }

  /**
   * Creates a UpdateDelegateRepresentative object from the given Core UpdateDelegateRepresentativeCertificate object.
   *
   * @param cert core UpdateDelegateRepresentativeCertificate object.
   */
  static fromCore(cert: Cardano.UpdateDelegateRepresentativeCertificate) {
    return new UpdateDelegateRepresentative(
      cert.dRepCredential,
      cert.anchor ? Anchor.fromCore(cert.anchor) : undefined
    );
  }

  /**
   * Gets DRep credential.
   *
   * @returns The DRep credential.
   */
  credential(): Cardano.Credential {
    return this.#drepCredential;
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
