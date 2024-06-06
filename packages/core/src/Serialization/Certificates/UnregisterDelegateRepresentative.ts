import * as Crypto from '@cardano-sdk/crypto';
import { CborReader, CborWriter } from '../CBOR/index.js';
import { CertificateKind } from './CertificateKind.js';
import { CertificateType } from '../../Cardano/index.js';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import type * as Cardano from '../../Cardano/index.js';

const EMBEDDED_GROUP_SIZE = 2;

/**
 * This certificate unregister an individual as a DRep.
 *
 * Note that a DRep is retired immediately upon the chain accepting a retirement certificate, and
 * the deposit is returned as part of the transaction that submits the retirement certificate
 * (the same way that stake credential registration deposits are returned).
 */
export class UnregisterDelegateRepresentative {
  #drepCredential: Cardano.Credential;
  #deposit: Cardano.Lovelace;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the UnregisterDelegateRepresentative class.
   *
   * @param drepCredential The DRep credential.
   * @param deposit The deposit.
   */
  constructor(drepCredential: Cardano.Credential, deposit: Cardano.Lovelace) {
    this.#drepCredential = drepCredential;
    this.#deposit = deposit;
  }

  /**
   * Serializes a UnregisterDelegateRepresentative into CBOR format.
   *
   * @returns The UnregisterDelegateRepresentative in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // unreg_drep_cert = (17, drep_credential, coin)
    writer.writeStartArray(3);

    writer.writeInt(CertificateKind.DrepUnregistration);

    // CDDL
    // stake_credential =
    //   [  0, addr_keyhash
    //   // 1, scripthash
    //   ]
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);
    writer.writeInt(this.#drepCredential.type);
    writer.writeByteString(Buffer.from(this.#drepCredential.hash, 'hex'));

    writer.writeInt(this.#deposit);

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the UnregisterDelegateRepresentative from a CBOR byte array.
   *
   * @param cbor The CBOR encoded UnregisterDelegateRepresentative object.
   * @returns The new UnregisterDelegateRepresentative instance.
   */
  static fromCbor(cbor: HexBlob): UnregisterDelegateRepresentative {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== 3)
      throw new InvalidArgumentError('cbor', `Expected an array of 3 elements, but got an array of ${length} elements`);

    const kind = Number(reader.readInt());

    if (kind !== CertificateKind.DrepUnregistration)
      throw new InvalidArgumentError(
        'cbor',
        `Expected certificate kind ${CertificateKind.DrepUnregistration}, but got ${kind}`
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

    const cert = new UnregisterDelegateRepresentative({ hash, type }, deposit);
    cert.#originalBytes = cbor;

    return cert;
  }

  /**
   * Creates a Core UnregisterDelegateRepresentativeCertificate object from the current UnregisterDelegateRepresentative object.
   *
   * @returns The Core UnregisterDelegateRepresentativeCertificate object.
   */
  toCore(): Cardano.UnRegisterDelegateRepresentativeCertificate {
    return {
      __typename: CertificateType.UnregisterDelegateRepresentative,
      dRepCredential: this.#drepCredential,
      deposit: this.#deposit
    };
  }

  /**
   * Creates a UnregisterDelegateRepresentative object from the given Core UnregisterDelegateRepresentativeCertificate object.
   *
   * @param cert core UnregisterDelegateRepresentativeCertificate object.
   */
  static fromCore(cert: Cardano.UnRegisterDelegateRepresentativeCertificate) {
    return new UnregisterDelegateRepresentative(cert.dRepCredential, cert.deposit);
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
}
