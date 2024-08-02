import * as Crypto from '@cardano-sdk/crypto';
import { CborReader, CborWriter } from '../CBOR';
import { CertificateKind } from './CertificateKind';
import { CertificateType } from '../../Cardano/types/Certificate';
import { DRep } from './DRep';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { hexToBytes } from '../../util/misc';
import type * as Cardano from '../../Cardano';

const EMBEDDED_GROUP_SIZE = 2;

/** This certificate Register the stake key and delegate with a single certificate to a DRep. */
export class VoteRegistrationDelegation {
  #credential: Cardano.Credential;
  #dRep: DRep;
  #deposit: Cardano.Lovelace;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the VoteRegistrationDelegation class.
   *
   * @param stakeCredential The stake credential to delegate.
   * @param deposit Must match the expected deposit amount specified by `ppKeyDepositL` in
   * the protocol parameters.
   * @param dRep The DRep to delegate to.
   */
  constructor(stakeCredential: Cardano.Credential, deposit: Cardano.Lovelace, dRep: DRep) {
    this.#credential = stakeCredential;
    this.#deposit = deposit;
    this.#dRep = dRep;
  }

  /**
   * Serializes a VoteRegistrationDelegation into CBOR format.
   *
   * @returns The VoteRegistrationDelegation in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // vote_reg_deleg_cert = (12, stake_credential, drep, coin)
    writer.writeStartArray(4);

    writer.writeInt(CertificateKind.VoteRegistrationDelegation);

    // CDDL
    // stake_credential =
    //   [  0, addr_keyhash
    //   // 1, scripthash
    //   ]
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);
    writer.writeInt(this.#credential.type);
    writer.writeByteString(Buffer.from(this.#credential.hash, 'hex'));

    writer.writeEncodedValue(hexToBytes(this.#dRep.toCbor()));
    writer.writeInt(this.#deposit);

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the VoteRegistrationDelegation from a CBOR byte array.
   *
   * @param cbor The CBOR encoded VoteRegistrationDelegation object.
   * @returns The new VoteRegistrationDelegation instance.
   */
  static fromCbor(cbor: HexBlob): VoteRegistrationDelegation {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== 4)
      throw new InvalidArgumentError('cbor', `Expected an array of 4 elements, but got an array of ${length} elements`);

    const kind = Number(reader.readInt());

    if (kind !== CertificateKind.VoteRegistrationDelegation)
      throw new InvalidArgumentError(
        'cbor',
        `Expected certificate kind ${CertificateKind.VoteRegistrationDelegation}, but got ${kind}`
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
    const deposit = reader.readInt();

    reader.readEndArray();

    const cert = new VoteRegistrationDelegation({ hash, type }, deposit, dRep);
    cert.#originalBytes = cbor;

    return cert;
  }

  /**
   * Creates a Core VoteRegistrationDelegationCertificate object from the current VoteRegistrationDelegation object.
   *
   * @returns The Core VoteRegistrationDelegationCertificate object.
   */
  toCore(): Cardano.VoteRegistrationDelegationCertificate {
    return {
      __typename: CertificateType.VoteRegistrationDelegation,
      dRep: this.#dRep.toCore(),
      deposit: this.#deposit,
      stakeCredential: this.#credential
    };
  }

  /**
   * Creates a VoteRegistrationDelegation object from the given Core VoteRegistrationDelegationCertificate object.
   *
   * @param deleg core VoteRegistrationDelegationCertificate object.
   */
  static fromCore(deleg: Cardano.VoteRegistrationDelegationCertificate) {
    return new VoteRegistrationDelegation(deleg.stakeCredential, deleg.deposit, DRep.fromCore(deleg.dRep));
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
   * Gets the deposit.
   *
   * @returns The deposit.
   */
  deposit(): Cardano.Lovelace {
    return this.#deposit;
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
