import * as Cardano from '../../../Cardano/index.js';
import { Anchor } from '../../Common/Anchor.js';
import { CborReader, CborWriter } from '../../CBOR/index.js';
import { GovernanceActionKind } from './GovernanceActionKind.js';
import { HardForkInitiationAction } from './HardForkInitiationAction.js';
import { HexBlob, InvalidStateError } from '@cardano-sdk/util';
import { InfoAction } from './InfoAction.js';
import { NewConstitution } from './NewConstitution.js';
import { NoConfidence } from './NoConfidence.js';
import { ParameterChangeAction } from './ParameterChangeAction.js';
import { SerializationError, SerializationFailure } from '../../../errors.js';
import { TreasuryWithdrawalsAction } from './TreasuryWithdrawalsAction.js';
import { UpdateCommittee } from './UpdateCommittee.js';
import { hexToBytes } from '../../../util/misc/index.js';

const PROCEDURE_ARRAY_SIZE = 4;

/** Governance proposal procedure for the Cardano blockchain, it supports various types of governance actions. */
export class ProposalProcedure {
  #parameterChangeAction: ParameterChangeAction | undefined = undefined;
  #hardForkInitiationAction: HardForkInitiationAction | undefined = undefined;
  #treasuryWithdrawalsAction: TreasuryWithdrawalsAction | undefined = undefined;
  #noConfidence: NoConfidence | undefined = undefined;
  #updateCommittee: UpdateCommittee | undefined = undefined;
  #newConstitution: NewConstitution | undefined = undefined;
  #infoAction: InfoAction | undefined = undefined;
  #kind: GovernanceActionKind;
  #deposit: Cardano.Lovelace;
  #rewardAccount: Cardano.RewardAccount;
  #anchor: Anchor;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Serializes a ProposalProcedure into CBOR format.
   *
   * @returns The ProposalProcedure in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    let actionCbor;

    switch (this.#kind) {
      case GovernanceActionKind.ParameterChange:
        actionCbor = this.#parameterChangeAction!.toCbor();
        break;
      case GovernanceActionKind.HardForkInitiation:
        actionCbor = this.#hardForkInitiationAction!.toCbor();
        break;
      case GovernanceActionKind.TreasuryWithdrawals:
        actionCbor = this.#treasuryWithdrawalsAction!.toCbor();
        break;
      case GovernanceActionKind.NoConfidence:
        actionCbor = this.#noConfidence!.toCbor();
        break;
      case GovernanceActionKind.UpdateCommittee:
        actionCbor = this.#updateCommittee!.toCbor();
        break;
      case GovernanceActionKind.NewConstitution:
        actionCbor = this.#newConstitution!.toCbor();
        break;
      case GovernanceActionKind.Info:
        actionCbor = this.#infoAction!.toCbor();
        break;
      default:
        throw new InvalidStateError(`Unexpected kind value: ${this.#kind}`);
    }

    // CDDL
    // proposal_procedure =
    //   [ deposit : coin
    //   , reward_account
    //   , gov_action
    //   , anchor
    //   ]
    writer.writeStartArray(PROCEDURE_ARRAY_SIZE);
    writer.writeInt(this.#deposit);

    const rewardAddress = Cardano.RewardAddress.fromAddress(Cardano.Address.fromBech32(this.#rewardAccount));
    if (!rewardAddress) {
      throw new SerializationError(
        SerializationFailure.InvalidAddress,
        `Invalid withdrawal address: ${this.#rewardAccount}`
      );
    }
    writer.writeByteString(Buffer.from(rewardAddress.toAddress().toBytes(), 'hex'));
    writer.writeEncodedValue(hexToBytes(actionCbor));
    writer.writeEncodedValue(hexToBytes(this.#anchor.toCbor()));

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the ProposalProcedure from a CBOR byte array.
   *
   * @param cbor The CBOR encoded ProposalProcedure object.
   * @returns The new ProposalProcedure instance.
   */
  static fromCbor(cbor: HexBlob): ProposalProcedure {
    let proposalProcedure: ProposalProcedure;

    const reader = new CborReader(cbor);
    reader.readStartArray();

    const deposit = reader.readInt();

    const rewardAccount = Cardano.Address.fromBytes(
      HexBlob.fromBytes(reader.readByteString())
    ).toBech32() as Cardano.RewardAccount;

    const actionCbor = HexBlob.fromBytes(reader.readEncodedValue());
    const anchor = Anchor.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
    reader.readEndArray();

    const actionReader = new CborReader(actionCbor);

    actionReader.readStartArray();

    let action;
    const kind = Number(actionReader.readInt());

    switch (kind) {
      case GovernanceActionKind.ParameterChange:
        action = ParameterChangeAction.fromCbor(actionCbor);
        proposalProcedure = ProposalProcedure.newParameterChangeAction(deposit, rewardAccount, anchor, action);
        break;
      case GovernanceActionKind.HardForkInitiation:
        action = HardForkInitiationAction.fromCbor(actionCbor);
        proposalProcedure = ProposalProcedure.newHardForkInitiationAction(deposit, rewardAccount, anchor, action);
        break;
      case GovernanceActionKind.TreasuryWithdrawals:
        action = TreasuryWithdrawalsAction.fromCbor(actionCbor);
        proposalProcedure = ProposalProcedure.newTreasuryWithdrawalsAction(deposit, rewardAccount, anchor, action);
        break;
      case GovernanceActionKind.NoConfidence:
        action = NoConfidence.fromCbor(actionCbor);
        proposalProcedure = ProposalProcedure.newNoConfidence(deposit, rewardAccount, anchor, action);
        break;
      case GovernanceActionKind.UpdateCommittee:
        action = UpdateCommittee.fromCbor(actionCbor);
        proposalProcedure = ProposalProcedure.newUpdateCommittee(deposit, rewardAccount, anchor, action);
        break;
      case GovernanceActionKind.NewConstitution:
        action = NewConstitution.fromCbor(actionCbor);
        proposalProcedure = ProposalProcedure.newNewConstitution(deposit, rewardAccount, anchor, action);
        break;
      case GovernanceActionKind.Info:
        action = InfoAction.fromCbor(actionCbor);
        proposalProcedure = ProposalProcedure.newInfoAction(deposit, rewardAccount, anchor, action);
        break;
      default:
        throw new InvalidStateError(`Unexpected kind value: ${kind}`);
    }

    proposalProcedure.#originalBytes = cbor;

    return proposalProcedure;
  }

  /**
   * Creates a Core ProposalProcedure object from the current ProposalProcedure object.
   *
   * @returns The Core ProposalProcedure object.
   */
  toCore(): Cardano.ProposalProcedure {
    let actionCore;

    switch (this.#kind) {
      case GovernanceActionKind.ParameterChange:
        actionCore = this.#parameterChangeAction!.toCore();
        break;
      case GovernanceActionKind.HardForkInitiation:
        actionCore = this.#hardForkInitiationAction!.toCore();
        break;
      case GovernanceActionKind.TreasuryWithdrawals:
        actionCore = this.#treasuryWithdrawalsAction!.toCore();
        break;
      case GovernanceActionKind.NoConfidence:
        actionCore = this.#noConfidence!.toCore();
        break;
      case GovernanceActionKind.UpdateCommittee:
        actionCore = this.#updateCommittee!.toCore();
        break;
      case GovernanceActionKind.NewConstitution:
        actionCore = this.#newConstitution!.toCore();
        break;
      case GovernanceActionKind.Info:
        actionCore = this.#infoAction!.toCore();
        break;
      default:
        throw new InvalidStateError(`Unexpected kind value: ${this.#kind}`);
    }

    return {
      anchor: this.#anchor.toCore(),
      deposit: this.#deposit,
      governanceAction: actionCore,
      rewardAccount: this.#rewardAccount
    };
  }

  /**
   * Creates a ProposalProcedure object from the given Core ProposalProcedure object.
   *
   * @param proposalProcedure The core ProposalProcedure object.
   */
  static fromCore(proposalProcedure: Cardano.ProposalProcedure): ProposalProcedure {
    let action;
    let procedure: ProposalProcedure;
    const anchor = Anchor.fromCore(proposalProcedure.anchor);

    switch (proposalProcedure.governanceAction.__typename) {
      case Cardano.GovernanceActionType.parameter_change_action:
        action = ParameterChangeAction.fromCore(proposalProcedure.governanceAction);
        procedure = ProposalProcedure.newParameterChangeAction(
          proposalProcedure.deposit,
          proposalProcedure.rewardAccount,
          anchor,
          action
        );
        break;
      case Cardano.GovernanceActionType.hard_fork_initiation_action:
        action = HardForkInitiationAction.fromCore(proposalProcedure.governanceAction);
        procedure = ProposalProcedure.newHardForkInitiationAction(
          proposalProcedure.deposit,
          proposalProcedure.rewardAccount,
          anchor,
          action
        );
        break;
      case Cardano.GovernanceActionType.treasury_withdrawals_action:
        action = TreasuryWithdrawalsAction.fromCore(proposalProcedure.governanceAction);
        procedure = ProposalProcedure.newTreasuryWithdrawalsAction(
          proposalProcedure.deposit,
          proposalProcedure.rewardAccount,
          anchor,
          action
        );
        break;
      case Cardano.GovernanceActionType.no_confidence:
        action = NoConfidence.fromCore(proposalProcedure.governanceAction);
        procedure = ProposalProcedure.newNoConfidence(
          proposalProcedure.deposit,
          proposalProcedure.rewardAccount,
          anchor,
          action
        );
        break;
      case Cardano.GovernanceActionType.update_committee:
        action = UpdateCommittee.fromCore(proposalProcedure.governanceAction);
        procedure = ProposalProcedure.newUpdateCommittee(
          proposalProcedure.deposit,
          proposalProcedure.rewardAccount,
          anchor,
          action
        );
        break;
      case Cardano.GovernanceActionType.new_constitution:
        action = NewConstitution.fromCore(proposalProcedure.governanceAction);
        procedure = ProposalProcedure.newNewConstitution(
          proposalProcedure.deposit,
          proposalProcedure.rewardAccount,
          anchor,
          action
        );
        break;
      case Cardano.GovernanceActionType.info_action:
        action = InfoAction.fromCore(proposalProcedure.governanceAction);
        procedure = ProposalProcedure.newInfoAction(
          proposalProcedure.deposit,
          proposalProcedure.rewardAccount,
          anchor,
          action
        );
        break;
      default:
        throw new InvalidStateError('Unexpected ProposalProcedure type');
    }

    return procedure;
  }

  /**
   * Factory method to create a new instance of ProposalProcedure with a ParameterChange action.
   *
   * @param deposit The deposit amount.
   * @param rewardAccount The reward account associated.
   * @param anchor The anchor for the procedure.
   * @param parameterChangeAction The parameter change action.
   * @returns A new instance of ProposalProcedure.
   */
  static newParameterChangeAction(
    deposit: Cardano.Lovelace,
    rewardAccount: Cardano.RewardAccount,
    anchor: Anchor,
    parameterChangeAction: ParameterChangeAction
  ): ProposalProcedure {
    const proposal = new ProposalProcedure();
    proposal.#kind = GovernanceActionKind.ParameterChange;
    proposal.#deposit = deposit;
    proposal.#rewardAccount = rewardAccount;
    proposal.#anchor = anchor;
    proposal.#parameterChangeAction = parameterChangeAction;

    return proposal;
  }

  /**
   * Factory method to create a new instance of ProposalProcedure with a HardForkInitiation action.
   *
   * @param deposit The deposit amount.
   * @param rewardAccount The reward account associated.
   * @param anchor -he anchor for the procedure.
   * @param hardForkInitiationAction The hard fork initiation action.
   * @returns A new instance of ProposalProcedure.
   */
  static newHardForkInitiationAction(
    deposit: Cardano.Lovelace,
    rewardAccount: Cardano.RewardAccount,
    anchor: Anchor,
    hardForkInitiationAction: HardForkInitiationAction
  ): ProposalProcedure {
    const proposal = new ProposalProcedure();
    proposal.#kind = GovernanceActionKind.HardForkInitiation;
    proposal.#deposit = deposit;
    proposal.#rewardAccount = rewardAccount;
    proposal.#anchor = anchor;
    proposal.#hardForkInitiationAction = hardForkInitiationAction;

    return proposal;
  }

  /**
   * Factory method to create a new instance of ProposalProcedure with a TreasuryWithdrawals action.
   *
   * @param deposit The deposit amount.
   * @param rewardAccount The reward account associated.
   * @param anchor -he anchor for the procedure.
   * @param treasuryWithdrawalsAction The treasury withdrawals action.
   * @returns A new instance of ProposalProcedure.
   */
  static newTreasuryWithdrawalsAction(
    deposit: Cardano.Lovelace,
    rewardAccount: Cardano.RewardAccount,
    anchor: Anchor,
    treasuryWithdrawalsAction: TreasuryWithdrawalsAction
  ): ProposalProcedure {
    const proposal = new ProposalProcedure();
    proposal.#kind = GovernanceActionKind.TreasuryWithdrawals;
    proposal.#deposit = deposit;
    proposal.#rewardAccount = rewardAccount;
    proposal.#anchor = anchor;
    proposal.#treasuryWithdrawalsAction = treasuryWithdrawalsAction;

    return proposal;
  }

  /**
   * Factory method to create a new instance of ProposalProcedure with a NoConfidence action.
   *
   * @param deposit The deposit amount.
   * @param rewardAccount The reward account associated.
   * @param anchor -he anchor for the procedure.
   * @param noConfidence The no confidence action.
   * @returns A new instance of ProposalProcedure.
   */
  static newNoConfidence(
    deposit: Cardano.Lovelace,
    rewardAccount: Cardano.RewardAccount,
    anchor: Anchor,
    noConfidence: NoConfidence
  ): ProposalProcedure {
    const proposal = new ProposalProcedure();
    proposal.#kind = GovernanceActionKind.NoConfidence;
    proposal.#deposit = deposit;
    proposal.#rewardAccount = rewardAccount;
    proposal.#anchor = anchor;
    proposal.#noConfidence = noConfidence;

    return proposal;
  }

  /**
   * Factory method to create a new instance of ProposalProcedure with a UpdateCommittee action.
   *
   * @param deposit The deposit amount.
   * @param rewardAccount The reward account associated.
   * @param anchor -he anchor for the procedure.
   * @param updateCommittee The update committee action.
   * @returns A new instance of ProposalProcedure.
   */
  static newUpdateCommittee(
    deposit: Cardano.Lovelace,
    rewardAccount: Cardano.RewardAccount,
    anchor: Anchor,
    updateCommittee: UpdateCommittee
  ): ProposalProcedure {
    const proposal = new ProposalProcedure();
    proposal.#kind = GovernanceActionKind.UpdateCommittee;
    proposal.#deposit = deposit;
    proposal.#rewardAccount = rewardAccount;
    proposal.#anchor = anchor;
    proposal.#updateCommittee = updateCommittee;

    return proposal;
  }

  /**
   * Factory method to create a new instance of ProposalProcedure with a NewConstitution action.
   *
   * @param deposit The deposit amount.
   * @param rewardAccount The reward account associated.
   * @param anchor -he anchor for the procedure.
   * @param newConstitution The new constitution action.
   * @returns A new instance of ProposalProcedure.
   */
  static newNewConstitution(
    deposit: Cardano.Lovelace,
    rewardAccount: Cardano.RewardAccount,
    anchor: Anchor,
    newConstitution: NewConstitution
  ): ProposalProcedure {
    const proposal = new ProposalProcedure();
    proposal.#kind = GovernanceActionKind.NewConstitution;
    proposal.#deposit = deposit;
    proposal.#rewardAccount = rewardAccount;
    proposal.#anchor = anchor;
    proposal.#newConstitution = newConstitution;

    return proposal;
  }

  /**
   * Factory method to create a new instance of ProposalProcedure with a InfoAction action.
   *
   * @param deposit The deposit amount.
   * @param rewardAccount The reward account associated.
   * @param anchor -he anchor for the procedure.
   * @param infoAction The info action.
   * @returns A new instance of ProposalProcedure.
   */
  static newInfoAction(
    deposit: Cardano.Lovelace,
    rewardAccount: Cardano.RewardAccount,
    anchor: Anchor,
    infoAction: InfoAction
  ): ProposalProcedure {
    const proposal = new ProposalProcedure();
    proposal.#kind = GovernanceActionKind.Info;
    proposal.#deposit = deposit;
    proposal.#rewardAccount = rewardAccount;
    proposal.#anchor = anchor;
    proposal.#infoAction = infoAction;

    return proposal;
  }

  /**
   * Gets the proposal procedure action kind.
   *
   * @returns the action kind.
   */
  kind(): GovernanceActionKind {
    return this.#kind;
  }

  /**
   * Gets the proposal procedure deposit.
   *
   * @returns the deposit.
   */
  deposit(): Cardano.Lovelace {
    return this.#deposit;
  }

  /**
   * Gets the proposal procedure reward account.
   *
   * @returns the reward account.
   */
  rewardAccount(): Cardano.RewardAccount {
    return this.#rewardAccount;
  }

  /**
   * Gets the proposal procedure anchor.
   *
   * @returns the anchor.
   */
  anchor(): Anchor {
    return this.#anchor;
  }

  /**
   * Retrieves the ParameterChangeAction associated with this ProposalProcedure, if present.
   *
   * @returns The ParameterChangeAction or undefined if not present.
   */
  getParameterChangeAction(): ParameterChangeAction | undefined {
    return this.#parameterChangeAction;
  }

  /**
   * Retrieves the HardForkInitiationAction associated with this ProposalProcedure, if present.
   *
   * @returns The HardForkInitiationAction or undefined if not present.
   */
  getHardForkInitiationAction(): HardForkInitiationAction | undefined {
    return this.#hardForkInitiationAction;
  }

  /**
   * Retrieves the TreasuryWithdrawalsAction associated with this ProposalProcedure, if present.
   *
   * @returns The TreasuryWithdrawalsAction or undefined if not present.
   */
  getTreasuryWithdrawalsAction(): TreasuryWithdrawalsAction | undefined {
    return this.#treasuryWithdrawalsAction;
  }

  /**
   * Retrieves the NoConfidence state associated with this ProposalProcedure, if present.
   *
   * @returns The NoConfidence state or undefined if not present.
   */
  getNoConfidence(): NoConfidence | undefined {
    return this.#noConfidence;
  }

  /**
   * Retrieves the UpdateCommittee state associated with this ProposalProcedure, if present.
   *
   * @returns The UpdateCommittee state or undefined if not present.
   */
  getUpdateCommittee(): UpdateCommittee | undefined {
    return this.#updateCommittee;
  }

  /**
   * Retrieves the NewConstitution associated with this ProposalProcedure, if present.
   *
   * @returns The NewConstitution or undefined if not present.
   */
  getNewConstitution(): NewConstitution | undefined {
    return this.#newConstitution;
  }

  /**
   * Retrieves the InfoAction associated with this ProposalProcedure, if present.
   *
   * @returns The InfoAction or undefined if not present.
   */
  getInfoAction(): InfoAction | undefined {
    return this.#infoAction;
  }
}
