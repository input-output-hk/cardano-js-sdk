import * as Cardano from '../../../Cardano';
import { CborReader, CborWriter } from '../../CBOR';
import { GovernanceActionKind } from './GovernanceActionKind';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';

/**
 * Represents an action that has no direct effect on the blockchain,
 * but serves as an on-chain record or informative notice.
 */
export class InfoAction {
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Serializes a InfoAction into CBOR format.
   *
   * @returns The InfoAction in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // info_action = 6
    writer.writeInt(GovernanceActionKind.Info);
    return writer.encodeAsHex();
  }

  /**
   * Deserializes the InfoAction from a CBOR byte array.
   *
   * @param cbor The CBOR encoded InfoAction object.
   * @returns The new InfoAction instance.
   */
  static fromCbor(cbor: HexBlob): InfoAction {
    const reader = new CborReader(cbor);

    const kind = Number(reader.readUInt());

    if (kind !== GovernanceActionKind.Info)
      throw new InvalidArgumentError(
        'cbor',
        `Expected action kind, expected ${GovernanceActionKind.Info} but got ${kind}`
      );

    const action = new InfoAction();
    action.#originalBytes = cbor;

    return action;
  }

  /**
   * Creates a Core InfoAction object from the current InfoAction object.
   *
   * @returns The Core InfoAction object.
   */
  toCore(): Cardano.InfoAction {
    return {
      __typename: Cardano.GovernanceActionType.info_action
    };
  }

  /**
   * Creates a InfoAction object from the given Core InfoAction object.
   */
  static fromCore(_: Cardano.InfoAction) {
    return new InfoAction();
  }
}
