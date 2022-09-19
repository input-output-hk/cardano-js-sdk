/* eslint-disable no-use-before-define */
import * as util from '../util';
import { Ed25519KeyHash } from './Key';
import { Slot } from './Block';

/**
 * Plutus script type.
 */
export enum ScriptType {
  Native = 'native',
  Plutus = 'plutus'
}

/**
 * native script kind.
 */
export enum NativeScriptKind {
  RequireSignature = 0,
  RequireAllOf = 1,
  RequireAnyOf = 2,
  RequireMOf = 3,
  RequireTimeAfter = 4,
  RequireTimeBefore = 5
}

/**
 * This script evaluates to true if the transaction also includes a valid key witness
 * where the witness verification key hashes to the given hash.
 *
 * In other words, this checks that the transaction is signed by a particular key, identified by its verification
 * key hash.
 */
export interface RequireSignatureScript {
  /**
   * Script type.
   */
  __type: ScriptType.Native;

  /**
   * The hash of a verification key.
   */
  keyHash: Ed25519KeyHash;

  /**
   * The native script kind.
   */
  kind: NativeScriptKind.RequireSignature;
}

/**
 * This script evaluates to true if  all the sub-scripts evaluate to true.
 *
 * If the list of sub-scripts is empty, this script evaluates to true.
 */
export interface RequireAllOfScript {
  /**
   * Script type.
   */
  __type: ScriptType.Native;

  /**
   * The list of sub-scripts.
   */
  scripts: NativeScript[];

  /**
   * The native script kind.
   */
  kind: NativeScriptKind.RequireAllOf;
}

/**
 * This script evaluates to true if any the sub-scripts evaluate to true. That is, if one
 * or more evaluate to true.
 *
 * If the list of sub-scripts is empty, this script evaluates to false.
 */
export interface RequireAnyOfScript {
  /**
   * Script type.
   */
  __type: ScriptType.Native;

  /**
   * The list of sub-scripts.
   */
  scripts: NativeScript[];

  /**
   * The native script kind.
   */
  kind: NativeScriptKind.RequireAnyOf;
}

/**
 * This script evaluates to true if at least M (required field) of the sub-scripts evaluate to true.
 */
export interface RequireAtLeastScript {
  /**
   * Script type.
   */
  __type: ScriptType.Native;

  /**
   * The number of sub-scripts that must evaluate to true for this script to evaluate to true.
   */
  required: number;

  /**
   * The list of sub-scripts.
   */
  scripts: NativeScript[];

  /**
   * The native script kind.
   */
  kind: NativeScriptKind.RequireMOf;
}

/**
 * This script evaluates to true if the upper bound of the transaction validity interval is a
 * slot number Y, and X <= Y.
 *
 * This condition guarantees that the actual slot number in which the transaction is included is
 * (strictly) less than slot number X.
 */
export interface RequireTimeBeforeScript {
  /**
   * Script type.
   */
  __type: ScriptType.Native;

  /**
   * The slot number specifying the upper bound of the validity interval.
   */
  slot: Slot;

  /**
   * The native script kind.
   */
  kind: NativeScriptKind.RequireTimeBefore;
}

/**
 * This script evaluates to true if the lower bound of the transaction validity interval is a
 * slot number Y, and Y <= X.
 *
 * This condition guarantees that the actual slot number in which the transaction is included
 * is greater than or equal to slot number X.
 */
export interface RequireTimeAfterScript {
  /**
   * Script type.
   */
  __type: ScriptType.Native;

  /**
   * The slot number specifying the lower bound of the validity interval.
   */
  slot: Slot;

  /**
   * The native script kind.
   */
  kind: NativeScriptKind.RequireTimeAfter;
}

/**
 * The Native scripts form an expression tree, the evaluation of the script produces either true or false.
 *
 * Note that it is recursive. There are no constraints on the nesting or size, except that imposed by the overall
 * transaction size limit (given that the script must be included in the transaction in a script witnesses).
 */
export type NativeScript =
  | RequireAllOfScript
  | RequireSignatureScript
  | RequireAnyOfScript
  | RequireAtLeastScript
  | RequireTimeBeforeScript
  | RequireTimeAfterScript;

/**
 * The Cardano ledger tags scripts with a language that determines what the ledger will do with the script.
 *
 * In most cases this language will be very similar to the ones that came before, we refer to these as
 * 'Plutus language versions'. However, from the ledger’s perspective they are entirely unrelated and there
 * is generally no requirement that they be similar or compatible in any way.
 */
export enum PlutusLanguageVersion {
  /**
   * V1 was the initial version of Plutus, introduced in the Alonzo hard fork.
   */
  V1 = 0,

  /**
   * V2 was introduced in the Vasil hard fork.
   *
   * The main changes in V2 of Plutus were to the interface to scripts. The ScriptContext was extended
   * to include the following information:
   *
   *  - The full “redeemers” structure, which contains all the redeemers used in the transaction
   *  - Reference inputs in the transaction (proposed in CIP-31)
   *  - Inline datums in the transaction (proposed in CIP-32)
   *  - Reference scripts in the transaction (proposed in CIP-33)
   */
  V2 = 1
}

/**
 * The datum is a piece of information that can be associated with a UTXO and is used to carry script state information
 * such as its owner or the timing details (which define when the UTXO can be spent)
 */
export type Datum = util.HexBlob;

/**
 * Plutus scripts are pieces of code that implement pure functions with True or False outputs. This functions take
 * several inputs such as Datum, Redeemer and the transaction context to decide whether an output can be spent or not.
 */
export interface PlutusScript {
  __type: ScriptType.Plutus;
  bytes: util.HexBlob;
  version: PlutusLanguageVersion;
}

/**
 * Program that decides whether the transaction that spends the output is authorized to do so.
 */
export type Script = NativeScript | PlutusScript;
