import { NativeScript, PolicyId } from '../Cardano';
import { nativeScript } from '../CML/coreToCml';
import { usingAutoFree } from '@cardano-sdk/util';

/**
 * Gets the policy id of the given native script.
 *
 * @param script The native script to get the policy ID of.
 * @returns the policy Id.
 */
export const nativeScriptPolicyId = (script: NativeScript): PolicyId =>
  usingAutoFree((scope) => {
    const managedScript = nativeScript(scope, script);
    return PolicyId(Buffer.from(scope.manage(managedScript.hash()).to_bytes()).toString('hex'));
  });
