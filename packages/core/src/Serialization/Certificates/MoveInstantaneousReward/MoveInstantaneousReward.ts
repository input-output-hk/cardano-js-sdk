import { CborReader, CborReaderState, CborWriter } from '../../CBOR';
import { CertificateKind } from '../CertificateKind';
import { HexBlob, InvalidArgumentError, InvalidStateError } from '@cardano-sdk/util';
import { MirCertificate, MirCertificateKind } from '../../../Cardano/types/Certificate';
import { MoveInstantaneousRewardToOtherPot } from './MoveInstantaneousRewardToOtherPot';
import { MoveInstantaneousRewardToStakeCreds } from './MoveInstantaneousRewardToStakeCreds';

const EMBEDDED_GROUP_SIZE = 2;

/**
 * Certificate used to facilitate an instantaneous transfer of rewards within the system.
 *
 * Typically, rewards in Cardano are accumulated and distributed through a carefully designed
 * process aligned with the staking and delegation mechanics. However, certain situations may
 * require a more immediate or specialized handling of rewards, and that's where this type of
 * certificate comes into play.
 *
 * The MoveInstantaneousReward certificate allows for immediate redistribution of rewards
 * within pots, or to a specified se of stake addresses.
 */
export class MoveInstantaneousReward {
  #toOtherPot: MoveInstantaneousRewardToOtherPot | undefined;
  #toStakeCreds: MoveInstantaneousRewardToStakeCreds | undefined;
  #kind: MirCertificateKind;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Serializes a MoveInstantaneousReward into CBOR format.
   *
   * @returns The MoveInstantaneousReward in CBOR format.
   */
  toCbor(): HexBlob {
    if (this.#originalBytes) return this.#originalBytes;

    let cbor;

    switch (this.#kind) {
      case MirCertificateKind.ToOtherPot:
        cbor = this.#toOtherPot!.toCbor();
        break;
      case MirCertificateKind.ToStakeCreds:
        cbor = this.#toStakeCreds!.toCbor();
        break;
      default:
        throw new InvalidStateError(`Unexpected kind value: ${this.#kind}`);
    }

    // CDDL
    // move_instantaneous_rewards_cert = (6, move_instantaneous_reward)
    const writer = new CborWriter();

    writer.writeStartArray(EMBEDDED_GROUP_SIZE);

    writer.writeInt(CertificateKind.MoveInstantaneousRewards);
    writer.writeEncodedValue(Buffer.from(cbor, 'hex'));

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the MoveInstantaneousReward from a CBOR byte array.
   *
   * @param cbor The CBOR encoded MoveInstantaneousReward object.
   * @returns The new MoveInstantaneousReward instance.
   */
  static fromCbor(cbor: HexBlob): MoveInstantaneousReward {
    const reader = new CborReader(cbor);

    let elementsCount = reader.readStartArray();
    if (elementsCount !== EMBEDDED_GROUP_SIZE)
      throw new InvalidArgumentError('cbor', `Expected elements size ${EMBEDDED_GROUP_SIZE}, but got ${elementsCount}`);

    const kind = Number(reader.readInt());

    if (kind !== CertificateKind.MoveInstantaneousRewards)
      throw new InvalidArgumentError(
        'cbor',
        `Expected certificate kind ${CertificateKind.MoveInstantaneousRewards}, but got ${kind}`
      );

    const embeddedCbor = HexBlob.fromBytes(reader.readEncodedValue());
    const embeddedCborReader = new CborReader(embeddedCbor);

    elementsCount = embeddedCborReader.readStartArray();
    if (elementsCount !== EMBEDDED_GROUP_SIZE)
      throw new InvalidArgumentError('cbor', `Expected elements size ${EMBEDDED_GROUP_SIZE}, but got ${elementsCount}`);

    const cert = new MoveInstantaneousReward();

    // Skip pot.
    embeddedCborReader.readInt();

    if (embeddedCborReader.peekState() === CborReaderState.UnsignedInteger) {
      cert.#toOtherPot = MoveInstantaneousRewardToOtherPot.fromCbor(embeddedCbor);
      cert.#kind = MirCertificateKind.ToOtherPot;
    } else if (
      embeddedCborReader.peekState() === CborReaderState.StartArray ||
      embeddedCborReader.peekState() === CborReaderState.StartMap
    ) {
      cert.#toStakeCreds = MoveInstantaneousRewardToStakeCreds.fromCbor(embeddedCbor);
      cert.#kind = MirCertificateKind.ToStakeCreds;
    } else {
      throw new InvalidArgumentError('cbor', 'Invalid CBOR string');
    }

    cert.#originalBytes = cbor;

    return cert;
  }

  /**
   * Creates a Core MirCertificate object from the current MoveInstantaneousReward object.
   *
   * @returns The Core MirCertificate object.
   */
  toCore(): MirCertificate {
    let core;

    switch (this.#kind) {
      case MirCertificateKind.ToOtherPot:
        core = this.#toOtherPot!.toCore();
        break;
      case MirCertificateKind.ToStakeCreds:
        core = this.#toStakeCreds!.toCore();
        break;
      default:
        throw new InvalidStateError(`Unexpected kind value: ${this.#kind}`);
    }

    return core;
  }

  /**
   * Creates a MoveInstantaneousReward object from the given Core MirCertificate object.
   *
   * @param cert The core MirCertificate object.
   */
  static fromCore(cert: MirCertificate): MoveInstantaneousReward {
    const mirCert = new MoveInstantaneousReward();

    switch (cert.kind) {
      case MirCertificateKind.ToOtherPot:
        mirCert.#toOtherPot = MoveInstantaneousRewardToOtherPot.fromCore(cert);
        mirCert.#kind = MirCertificateKind.ToOtherPot;
        break;
      case MirCertificateKind.ToStakeCreds:
        mirCert.#toStakeCreds = MoveInstantaneousRewardToStakeCreds.fromCore(cert);
        mirCert.#kind = MirCertificateKind.ToStakeCreds;
        break;
      default:
        throw new InvalidStateError(`Unexpected kind value: ${cert.kind}`);
    }

    return mirCert;
  }

  /**
   * Creates a move instantaneous rewards certificate that transfers finds
   * to the other accounting pot.
   *
   * @param mirCert The MoveInstantaneousRewardToOtherPot certificate.
   */
  static newToOtherPot(mirCert: MoveInstantaneousRewardToOtherPot): MoveInstantaneousReward {
    const cert = new MoveInstantaneousReward();

    cert.#toOtherPot = mirCert;
    cert.#kind = MirCertificateKind.ToOtherPot;

    return cert;
  }

  /**
   * Creates a move instantaneous rewards certificate that transfers funds
   * to the given set of reward accounts.
   *
   * @param mirCert The MoveInstantaneousRewardToStakeCreds certificate.
   */
  static newToStakeCreds(mirCert: MoveInstantaneousRewardToStakeCreds): MoveInstantaneousReward {
    const cert = new MoveInstantaneousReward();

    cert.#toStakeCreds = mirCert;
    cert.#kind = MirCertificateKind.ToStakeCreds;

    return cert;
  }

  /**
   * The kind of MoveInstantaneousReward certificate.
   *
   * - Reserve Pot: This pot is filled with a predefined amount of ADA at the
   *   launch of the network. It's used to fund various initiatives, and some of
   *   he funds are transferred to the reward pot to pay for staking rewards.
   *
   * - Treasury Pot: The treasury holds funds that can be used for various purposes,
   *   such as funding development and community initiatives. It's filled by taking
   *   a portion of the transaction fees and other specified sources.
   *
   * @returns The MoveInstantaneousReward kind.
   */
  kind(): MirCertificateKind {
    return this.#kind;
  }

  /**
   * Gets a MoveInstantaneousRewardToOtherPot from a MoveInstantaneousReward instance.
   *
   * @returns a MoveInstantaneousRewardToOtherPot if the MoveInstantaneousReward can be down cast, otherwise, undefined.
   */
  asToOtherPot(): MoveInstantaneousRewardToOtherPot | undefined {
    return this.#toOtherPot;
  }

  /**
   * Gets a MoveInstantaneousRewardToStakeCreds from a MoveInstantaneousReward instance.
   *
   * @returns a MoveInstantaneousRewardToStakeCreds if the MoveInstantaneousReward can be down cast, otherwise, undefined.
   */
  asToStakeCreds(): MoveInstantaneousRewardToStakeCreds | undefined {
    return this.#toStakeCreds;
  }
}
