/* eslint-disable no-use-before-define */

import { Ed25519KeyHash } from './Key';
import { Slot } from '@cardano-ogmios/schema';

/**
 * Native script type.
 */
export enum NativeScriptType {
  RequireAllOf = 'all',
  RequireAnyOf = 'any',
  RequireMOf = 'atLeast',
  RequireSignature = 'sig',
  RequireTimeAfter = 'after',
  RequireTimeBefore = 'before'
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
   * The hash of a verification key.
   */
  keyHash: Ed25519KeyHash;

  /**
   * Script type.
   */
  __type: NativeScriptType.RequireSignature;
}

/**
 * This script evaluates to true if  all the sub-scripts evaluate to true.
 *
 * If the list of sub-scripts is empty, this script evaluates to true.
 */
export interface RequireAllOfScript {
  /**
   * The list of sub-scripts.
   */
  scripts: NativeScript[];

  /**
   * Script type.
   */
  __type: NativeScriptType.RequireAllOf;
}

/**
 * This script evaluates to true if any the sub-scripts evaluate to true. That is, if one
 * or more evaluate to true.
 *
 * If the list of sub-scripts is empty, this script evaluates to false.
 */
export interface RequireAnyOfScript {
  /**
   * The list of sub-scripts.
   */
  scripts: NativeScript[];

  /**
   * Script type.
   */
  __type: NativeScriptType.RequireAnyOf;
}

/**
 * This script evaluates to true if at least M (required field) of the sub-scripts evaluate to true.
 */
export interface RequireAtLeastScript {
  /**
   * The number of sub-scripts that must evaluate to true for this script to evaluate to true.
   */
  required: number;

  /**
   * The list of sub-scripts.
   */
  scripts: NativeScript[];

  /**
   * Script type.
   */
  __type: NativeScriptType.RequireMOf;
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
   * The slot number specifying the upper bound of the validity interval.
   */
  slot: Slot;

  /**
   * Script type.
   */
  __type: NativeScriptType.RequireTimeBefore;
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
   * The slot number specifying the lower bound of the validity interval.
   */
  slot: Slot;

  /**
   * Script type.
   */
  __type: NativeScriptType.RequireTimeAfter;
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
