import * as Cardano from '../../../Cardano';
import { CborReader, CborReaderState, CborWriter } from '../../CBOR';
import { GovernanceActionKind } from './GovernanceActionKind';
import { GovernanceActionType } from '../../../Cardano';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { SerializationError, SerializationFailure } from '../../../errors';

const EMBEDDED_GROUP_SIZE = 2;

/**
 * Withdraws funds from the treasury.
 */
export class TreasuryWithdrawalsAction {
  #withdrawals: Map<Cardano.RewardAccount, Cardano.Lovelace>;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Creates a new TreasuryWithdrawalsAction instance.
   *
   * @param withdrawals A map specifying which rewards accounts to transfer the funds to.
   */
  constructor(withdrawals: Map<Cardano.RewardAccount, Cardano.Lovelace>) {
    this.#withdrawals = withdrawals;
  }

  /**
   * Serializes a TreasuryWithdrawalsAction into CBOR format.
   *
   * @returns The TreasuryWithdrawalsAction in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // treasury_withdrawals_action = (2, { reward_account => coin })
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);
    writer.writeInt(GovernanceActionKind.TreasuryWithdrawals);

    const sortedCanonically = new Map([...this.#withdrawals].sort((a, b) => (a > b ? 1 : -1)));

    writer.writeStartMap(sortedCanonically.size);

    for (const [key, value] of sortedCanonically) {
      const rewardAddress = Cardano.RewardAddress.fromAddress(Cardano.Address.fromBech32(key));

      if (!rewardAddress) {
        throw new SerializationError(SerializationFailure.InvalidAddress, `Invalid withdrawal address: ${key}`);
      }

      writer.writeByteString(Buffer.from(rewardAddress.toAddress().toBytes(), 'hex'));
      writer.writeInt(value);
    }

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the TreasuryWithdrawalsAction from a CBOR byte array.
   *
   * @param cbor The CBOR encoded TreasuryWithdrawalsAction object.
   * @returns The new TreasuryWithdrawalsAction instance.
   */
  static fromCbor(cbor: HexBlob): TreasuryWithdrawalsAction {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== EMBEDDED_GROUP_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${EMBEDDED_GROUP_SIZE} elements, but got an array of ${length} elements`
      );

    const kind = Number(reader.readUInt());

    if (kind !== GovernanceActionKind.TreasuryWithdrawals)
      throw new InvalidArgumentError(
        'cbor',
        `Expected action kind, expected ${GovernanceActionKind.TreasuryWithdrawals} but got ${kind}`
      );

    reader.readStartMap();

    const amounts = new Map<Cardano.RewardAccount, Cardano.Lovelace>();
    while (reader.peekState() !== CborReaderState.EndMap) {
      const account = Cardano.Address.fromBytes(
        HexBlob.fromBytes(reader.readByteString())
      ).toBech32() as Cardano.RewardAccount;

      const amount = reader.readInt();
      amounts.set(account, amount);
    }

    reader.readEndMap();

    const action = new TreasuryWithdrawalsAction(amounts);
    action.#originalBytes = cbor;

    return action;
  }

  /**
   * Creates a Core TreasuryWithdrawalsAction object from the current TreasuryWithdrawalsAction object.
   *
   * @returns The Core TreasuryWithdrawalsAction object.
   */
  toCore(): Cardano.TreasuryWithdrawalsAction {
    const withdrawals = new Set(
      [...this.#withdrawals.entries()].map((value) => ({
        coin: value[1],
        rewardAccount: value[0]
      }))
    );

    return {
      __typename: GovernanceActionType.treasury_withdrawals_action,
      withdrawals
    };
  }

  /**
   * Creates a TreasuryWithdrawalsAction object from the given Core TreasuryWithdrawalsAction object.
   *
   * @param treasuryWithdrawalsAction core TreasuryWithdrawalsAction object.
   */
  static fromCore(treasuryWithdrawalsAction: Cardano.TreasuryWithdrawalsAction) {
    return new TreasuryWithdrawalsAction(
      new Map([...treasuryWithdrawalsAction.withdrawals].map((value) => [value.rewardAccount, value.coin]))
    );
  }

  /**
   * Retrieves the withdrawals associated with the treasury withdrawal action.
   *
   * @returns The withdrawals.
   */
  withdrawals(): Map<Cardano.RewardAccount, Cardano.Lovelace> {
    return this.#withdrawals;
  }
}
