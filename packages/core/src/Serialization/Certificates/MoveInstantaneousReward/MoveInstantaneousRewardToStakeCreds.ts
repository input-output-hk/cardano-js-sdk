import * as Cardano from '../../../Cardano/index.js';
import * as Crypto from '@cardano-sdk/crypto';
import { CborReader, CborReaderState, CborWriter } from '../../CBOR/index.js';
import { HexBlob, InvalidArgumentError, InvalidStateError } from '@cardano-sdk/util';

const EMBEDDED_GROUP_SIZE = 2;

/** Creates a move instantaneous rewards certificate that transfers funds to the given set of reward accounts. */
export class MoveInstantaneousRewardToStakeCreds {
  #pot: Cardano.MirCertificatePot;
  #credentials: Map<Cardano.Credential, Cardano.Lovelace>;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the MoveInstantaneousRewardToStakeCreds class.
   *
   * @param pot Determines where the funds are drawn from.
   * @param credentials A map specifying which stake credentials to transfer the funds to.
   */
  constructor(pot: Cardano.MirCertificatePot, credentials: Map<Cardano.Credential, bigint>) {
    this.#pot = pot;
    this.#credentials = credentials;
  }

  /**
   * Serializes a MoveInstantaneousRewardToStakeCreds into CBOR format.
   *
   * @returns The MoveInstantaneousRewardToStakeCreds in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // move_instantaneous_reward = [ 0 / 1, coin ]
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);
    writer.writeInt(this.#pot === Cardano.MirCertificatePot.Reserves ? 0 : 1);

    const sortedCanonically = new Map([...this.#credentials].sort((a, b) => (a > b ? 1 : -1)));

    writer.writeStartMap(sortedCanonically.size);

    for (const [key, value] of sortedCanonically) {
      // CDDL
      // encode key
      //
      // stake_credential =
      //   [  0, addr_keyhash
      //   // 1, scripthash
      //   ]
      writer.writeStartArray(EMBEDDED_GROUP_SIZE);
      writer.writeInt(key.type);
      writer.writeByteString(Buffer.from(key.hash, 'hex'));

      writer.writeInt(value);
    }

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the MoveInstantaneousRewardToStakeCreds from a CBOR byte array.
   *
   * @param cbor The CBOR encoded MoveInstantaneousRewardToStakeCreds object.
   * @returns The new MoveInstantaneousRewardToStakeCreds instance.
   */
  static fromCbor(cbor: HexBlob): MoveInstantaneousRewardToStakeCreds {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== EMBEDDED_GROUP_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of two elements, but got an array of ${length} elements`
      );

    const pot = Number(reader.readInt());

    if (pot < 0 || pot > 1)
      throw new InvalidArgumentError(
        'cbor',
        `Expected a pot value between 0 and 1, but got an array of ${pot} elements`
      );

    reader.readStartMap();

    const amounts = new Map<Cardano.Credential, Cardano.Lovelace>();
    while (reader.peekState() !== CborReaderState.EndMap) {
      // Read key
      reader.readStartArray();
      const credentialType = Number(reader.readInt());

      if (credentialType < 0 || credentialType > 1)
        throw new InvalidArgumentError(
          'cbor',
          `Expected a credential type value between 0 and 1, but got ${credentialType}`
        );

      const credHash = Crypto.Hash28ByteBase16(HexBlob.fromBytes(reader.readByteString()));
      reader.readEndArray();

      // Read value
      const amount = reader.readInt();

      amounts.set({ hash: credHash, type: credentialType as Cardano.CredentialType }, amount);
    }

    reader.readEndMap();

    const cert = new MoveInstantaneousRewardToStakeCreds(
      pot === 0 ? Cardano.MirCertificatePot.Reserves : Cardano.MirCertificatePot.Treasury,
      amounts
    );

    cert.#originalBytes = cbor;

    return cert;
  }

  /**
   * Creates a Core MirCertificate object from the current MoveInstantaneousRewardToStakeCreds object.
   *
   * @returns The Core MirCertificate object.
   */
  toCore(): Cardano.MirCertificate {
    // TODO: Mir certificate should hold a map of credentials rather than a single credential,
    // we will refactor further this interface once we fix Core cert type interfaces.
    if (this.#credentials.size === 0) throw new InvalidStateError('The credential map is empty.');

    const [[stakeCredential, quantity]] = this.#credentials;

    return {
      __typename: Cardano.CertificateType.MIR,
      kind: Cardano.MirCertificateKind.ToStakeCreds,
      pot: this.#pot,
      quantity,
      stakeCredential
    };
  }

  /**
   * Creates a MoveInstantaneousRewardToStakeCreds object from the given Core MirCertificate object.
   *
   * @param cert The core MirCertificate object.
   */
  static fromCore(cert: Cardano.MirCertificate) {
    if (cert.kind !== Cardano.MirCertificateKind.ToStakeCreds)
      throw new InvalidArgumentError('cert', `Expected a MIR certificate kind 'ToStakeCreds', but got ${cert.kind}`);

    if (cert.stakeCredential === undefined)
      throw new InvalidArgumentError('cert', 'stakeCredential field of the given MIR certificate is undefined');

    // TODO: Mir certificate should hold a map of credentials rather than a single credential,
    // we will refactor further this interface once we fix Core cert type interfaces.
    return new MoveInstantaneousRewardToStakeCreds(cert.pot, new Map([[cert.stakeCredential, cert.quantity]]));
  }

  /**
   * The rewards pot in this certificate.
   *
   * @returns The rewards pot where the funds are drawn from.
   */
  pot(): Cardano.MirCertificatePot {
    return this.#pot;
  }

  /**
   * Sets the rewards pot in this certificate.
   *
   * @param pot The rewards pot where the funds are drawn from.
   */
  setPot(pot: Cardano.MirCertificatePot): void {
    this.#pot = pot;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the amount to be transferred from the pot to the given set of
   * stake credentials.
   *
   * @returns The given set of stake credentials and the amounts to be transferred.
   */
  getStakeCreds(): Map<Cardano.Credential, bigint> | undefined {
    return this.#credentials;
  }

  /**
   * Sets the amounts to be transferred from the pot to the given set of
   * stake credentials.
   *
   * @param credentials The set of stake credentials and the amounts to be transferred.
   */
  setStakeCreds(credentials: Map<Cardano.Credential, bigint>): void {
    this.#credentials = credentials;
    this.#originalBytes = undefined;
  }
}
