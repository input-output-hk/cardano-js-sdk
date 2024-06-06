import * as Crypto from '@cardano-sdk/crypto';
import { CborReader, CborWriter } from '../CBOR/index.js';
import { CertificateKind } from './CertificateKind.js';
import { CertificateType } from '../../Cardano/index.js';
import { DRep } from './DRep/index.js';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { hexToBytes } from '../../util/misc/index.js';
import type * as Cardano from '../../Cardano/index.js';

const EMBEDDED_GROUP_SIZE = 2;

/** This certificate is used when an individual wants to delegate their voting rights to any other DRep. */
export class VoteDelegation {
  #credential: Cardano.Credential;
  #dRep: DRep;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the VoteDelegation class.
   *
   * @param stakeCredential The stake credential to delegate.
   * @param dRep The DRep to delegate to.
   */
  constructor(stakeCredential: Cardano.Credential, dRep: DRep) {
    this.#credential = stakeCredential;
    this.#dRep = dRep;
  }

  /**
   * Serializes a VoteDelegation into CBOR format.
   *
   * @returns The VoteDelegation in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // vote_deleg_cert = (9, stake_credential, drep)
    writer.writeStartArray(3);

    writer.writeInt(CertificateKind.VoteDelegation);

    // CDDL
    // stake_credential =
    //   [  0, addr_keyhash
    //   // 1, scripthash
    //   ]
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);
    writer.writeInt(this.#credential.type);
    writer.writeByteString(Buffer.from(this.#credential.hash, 'hex'));

    writer.writeEncodedValue(hexToBytes(this.#dRep.toCbor()));

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the VoteDelegation from a CBOR byte array.
   *
   * @param cbor The CBOR encoded VoteDelegation object.
   * @returns The new VoteDelegation instance.
   */
  static fromCbor(cbor: HexBlob): VoteDelegation {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== 3)
      throw new InvalidArgumentError('cbor', `Expected an array of 3 elements, but got an array of ${length} elements`);

    const kind = Number(reader.readInt());

    if (kind !== CertificateKind.VoteDelegation)
      throw new InvalidArgumentError(
        'cbor',
        `Expected certificate kind ${CertificateKind.VoteDelegation}, but got ${kind}`
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

    const dRep = DRep.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));

    reader.readEndArray();

    const cert = new VoteDelegation({ hash, type }, dRep);
    cert.#originalBytes = cbor;

    return cert;
  }

  /**
   * Creates a Core VoteDelegationCertificate object from the current VoteDelegation object.
   *
   * @returns The Core VoteDelegationCertificate object.
   */
  toCore(): Cardano.VoteDelegationCertificate {
    return {
      __typename: CertificateType.VoteDelegation,
      dRep: this.#dRep.toCore(),
      stakeCredential: this.#credential
    };
  }

  /**
   * Creates a VoteDelegation object from the given Core VoteDelegationCertificate object.
   *
   * @param deleg core VoteDelegationCertificate object.
   */
  static fromCore(deleg: Cardano.VoteDelegationCertificate) {
    return new VoteDelegation(deleg.stakeCredential, DRep.fromCore(deleg.dRep));
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
   * Gets the DRep being delegated to.
   *
   * @returns The DRep.
   */
  dRep(): DRep {
    return this.#dRep;
  }
}
