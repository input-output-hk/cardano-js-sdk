import { CborReader, CborWriter } from '../../CBOR';
import { CertificateType, MirCertificateKind, MirCertificatePot } from '../../../Cardano/types/Certificate';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import type * as Cardano from '../../../Cardano';

const EMBEDDED_GROUP_SIZE = 2;

/** This certificate move instantaneous rewards funds between accounting pots. */
export class MoveInstantaneousRewardToOtherPot {
  #pot: Cardano.MirCertificatePot;
  #amount: Cardano.Lovelace;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the MoveInstantaneousRewardToOtherPot class.
   *
   * @param pot Determines where the funds are drawn from.
   * @param amount The amount to be transfer.
   */
  constructor(pot: Cardano.MirCertificatePot, amount: Cardano.Lovelace) {
    this.#pot = pot;
    this.#amount = amount;
  }

  /**
   * Serializes a MoveInstantaneousRewardToOtherPot into CBOR format.
   *
   * @returns The MoveInstantaneousRewardToOtherPot in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // move_instantaneous_reward = [ 0 / 1, coin ]
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);
    writer.writeInt(this.#pot === MirCertificatePot.Reserves ? 0 : 1);
    writer.writeInt(this.#amount);

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the ScriptAll from a CBOR byte array.
   *
   * @param cbor The CBOR encoded ScriptAll object.
   * @returns The new ScriptAll instance.
   */
  static fromCbor(cbor: HexBlob): MoveInstantaneousRewardToOtherPot {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== EMBEDDED_GROUP_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of two elements, but got an array of ${length} elements`
      );

    const pot = Number(reader.readInt());
    const amount = reader.readInt();

    if (pot < 0 || pot > 1)
      throw new InvalidArgumentError('cbor', `Expected a pot value between 0 and 1, but got ${pot}`);

    const cert = new MoveInstantaneousRewardToOtherPot(
      pot === 0 ? MirCertificatePot.Reserves : MirCertificatePot.Treasury,
      amount
    );

    cert.#originalBytes = cbor;

    return cert;
  }

  /**
   * Creates a Core MirCertificate object from the current MoveInstantaneousRewardToOtherPot object.
   *
   * @returns The Core MirCertificate object.
   */
  toCore(): Cardano.MirCertificate {
    return {
      __typename: CertificateType.MIR,
      kind: MirCertificateKind.ToOtherPot,
      pot: this.#pot,
      quantity: this.#amount
    };
  }

  /**
   * Creates a MoveInstantaneousRewardToOtherPot object from the given Core MirCertificate object.
   *
   * @param cert The core MirCertificate object.
   */
  static fromCore(cert: Cardano.MirCertificate) {
    if (cert.kind !== MirCertificateKind.ToOtherPot)
      throw new InvalidArgumentError('cert', `Expected a MIR certificate kind 'ToOtherPot', but got ${cert.kind}`);

    if (cert.quantity === undefined)
      throw new InvalidArgumentError('cert', 'Amount field of the given MIR certificate is undefined');

    return new MoveInstantaneousRewardToOtherPot(cert.pot, cert.quantity);
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
   * Gets the amount to be transferred to the other pot.
   *
   * @returns the amount to be transferred to the other pot.
   */
  getAmount(): Cardano.Lovelace {
    return this.#amount;
  }

  /**
   * Sets the amount to be transferred to the other pot.
   *
   * @param amount The amount to be transferred to the other pot.
   */
  setAmount(amount: Cardano.Lovelace): void {
    this.#amount = amount;
    this.#originalBytes = undefined;
  }
}
