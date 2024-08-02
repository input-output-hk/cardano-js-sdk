import * as Crypto from '@cardano-sdk/crypto';
import { Anchor } from '../Common';
import { CborReader, CborReaderState, CborWriter } from '../CBOR';
import { CertificateKind } from './CertificateKind';
import { CertificateType } from '../../Cardano/types/Certificate';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { hexToBytes } from '../../util/misc';
import type * as Cardano from '../../Cardano';

const EMBEDDED_GROUP_SIZE = 2;

/**
 * In Voltaire, existing stake credentials will be able to delegate their stake to DReps for voting
 * purposes, in addition to the current delegation to stake pools for block production.
 * DRep delegation will mimic the existing stake delegation mechanisms (via on-chain certificates).
 *
 * This certificate register a stake key as a DRep.
 */
export class RegisterDelegateRepresentative {
  #drepCredential: Cardano.Credential;
  #deposit: Cardano.Lovelace;
  #anchor: Anchor | undefined;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the RegisterDelegateRepresentative class.
   *
   * @param drepCredential The DRep credential.
   * @param deposit The deposit.
   * @param anchor The anchor.
   */
  constructor(drepCredential: Cardano.Credential, deposit: Cardano.Lovelace, anchor?: Anchor) {
    this.#drepCredential = drepCredential;
    this.#deposit = deposit;
    this.#anchor = anchor;
  }

  /**
   * Serializes a RegisterDelegateRepresentative into CBOR format.
   *
   * @returns The RegisterDelegateRepresentative in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // reg_drep_cert = (16, drep_credential, coin, anchor / null)
    writer.writeStartArray(4);

    writer.writeInt(CertificateKind.DrepRegistration);

    // CDDL
    // stake_credential =
    //   [  0, addr_keyhash
    //   // 1, scripthash
    //   ]
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);
    writer.writeInt(this.#drepCredential.type);
    writer.writeByteString(Buffer.from(this.#drepCredential.hash, 'hex'));

    writer.writeInt(this.#deposit);

    if (this.#anchor) {
      writer.writeEncodedValue(hexToBytes(this.#anchor.toCbor()));
    } else {
      writer.writeNull();
    }

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the RegisterDelegateRepresentative from a CBOR byte array.
   *
   * @param cbor The CBOR encoded RegisterDelegateRepresentative object.
   * @returns The new RegisterDelegateRepresentative instance.
   */
  static fromCbor(cbor: HexBlob): RegisterDelegateRepresentative {
    const reader = new CborReader(cbor);
    const length = reader.readStartArray();

    if (length !== 4)
      throw new InvalidArgumentError('cbor', `Expected an array of 4 elements, but got an array of ${length} elements`);

    const kind = Number(reader.readInt());

    if (kind !== CertificateKind.DrepRegistration)
      throw new InvalidArgumentError(
        'cbor',
        `Expected certificate kind ${CertificateKind.DrepRegistration}, but got ${kind}`
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
    let anchor;

    if (reader.peekState() === CborReaderState.Null) {
      reader.readNull();
    } else {
      anchor = Anchor.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
    }

    reader.readEndArray();

    const cert = new RegisterDelegateRepresentative({ hash, type }, deposit, anchor);
    cert.#originalBytes = cbor;

    return cert;
  }

  /**
   * Creates a Core RegisterDelegateRepresentativeCertificate object from the current RegisterDelegateRepresentative object.
   *
   * @returns The Core RegisterDelegateRepresentativeCertificate object.
   */
  toCore(): Cardano.RegisterDelegateRepresentativeCertificate {
    return {
      __typename: CertificateType.RegisterDelegateRepresentative,
      anchor: this.#anchor ? this.#anchor.toCore() : null,
      dRepCredential: this.#drepCredential,
      deposit: this.#deposit
    };
  }

  /**
   * Creates a RegisterDelegateRepresentative object from the given Core RegisterDelegateRepresentativeCertificate object.
   *
   * @param cert core RegisterDelegateRepresentativeCertificate object.
   */
  static fromCore(cert: Cardano.RegisterDelegateRepresentativeCertificate) {
    return new RegisterDelegateRepresentative(
      cert.dRepCredential,
      cert.deposit,
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
   * Gets the deposit.
   *
   * @returns The deposit.
   */
  deposit(): Cardano.Lovelace {
    return this.#deposit;
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
