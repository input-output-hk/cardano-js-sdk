import { NativeScript, PolicyId } from '../types';
import { nativeScript } from '../../CSL/coreToCsl';

/**
 * Gets the policy id of the given native script.
 *
 * @param script The native script to get the policy ID of.
 * @returns the policy Id.
 */
export const nativeScriptPolicyId = (script: NativeScript): PolicyId =>
  PolicyId(Buffer.from(nativeScript(script).hash().to_bytes()).toString('hex'));
