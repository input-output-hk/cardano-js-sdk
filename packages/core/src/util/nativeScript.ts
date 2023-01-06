/* eslint-disable @typescript-eslint/no-explicit-any */
import * as Cardano from '../Cardano';
import * as toCml from '../CML/coreToCml';
import { SerializationError, SerializationFailure } from '../';
import { usingAutoFree } from '@cardano-sdk/util';

/**
 * Gets the policy id of the given native script.
 *
 * @param script The native script to get the policy ID of.
 * @returns the policy Id.
 */
export const nativeScriptPolicyId = (script: Cardano.NativeScript): Cardano.PolicyId =>
  usingAutoFree((scope) => {
    const managedScript = toCml.nativeScript(scope, script);
    return Cardano.PolicyId(Buffer.from(scope.manage(managedScript.hash()).to_bytes()).toString('hex'));
  });

/**
 * Converts a json representation of a native script into a NativeScript.
 *
 * @param json The JSON representation of a native script. The JSON must conform
 * to the following format:
 *
 * https://github.com/input-output-hk/cardano-node/blob/master/doc/reference/simple-scripts.md
 */
export const jsonToNativeScript = (json: any): Cardano.NativeScript => {
  let coreScript: Cardano.NativeScript;

  if (!json.type) {
    throw new SerializationError(SerializationFailure.InvalidScript, "Invalid Native Script. Missing 'type' field.");
  }

  switch (json.type) {
    case 'sig': {
      coreScript = {
        __type: Cardano.ScriptType.Native,
        keyHash: Cardano.Ed25519KeyHash(json.keyHash),
        kind: Cardano.NativeScriptKind.RequireSignature
      };

      break;
    }
    case 'all': {
      coreScript = {
        __type: Cardano.ScriptType.Native,
        kind: Cardano.NativeScriptKind.RequireAllOf,
        scripts: new Array<Cardano.NativeScript>()
      };
      for (let i = 0; i < json.scripts.length; ++i) {
        coreScript.scripts.push(jsonToNativeScript(json.scripts[i]));
      }

      break;
    }
    case 'any': {
      coreScript = {
        __type: Cardano.ScriptType.Native,
        kind: Cardano.NativeScriptKind.RequireAnyOf,
        scripts: new Array<Cardano.NativeScript>()
      };
      for (let i = 0; i < json.scripts.length; ++i) {
        coreScript.scripts.push(jsonToNativeScript(json.scripts[i]));
      }

      break;
    }
    case 'atLeast': {
      const required = Number.parseInt(json.required);
      coreScript = {
        __type: Cardano.ScriptType.Native,
        kind: Cardano.NativeScriptKind.RequireNOf,
        required,
        scripts: new Array<Cardano.NativeScript>()
      };

      for (let i = 0; i < json.scripts.length; ++i) {
        coreScript.scripts.push(jsonToNativeScript(json.scripts[i]));
      }

      break;
    }
    case 'before': {
      coreScript = {
        __type: Cardano.ScriptType.Native,
        kind: Cardano.NativeScriptKind.RequireTimeBefore,
        slot: Cardano.Slot(Number.parseInt(json.slot))
      };

      break;
    }
    case 'after': {
      coreScript = {
        __type: Cardano.ScriptType.Native,
        kind: Cardano.NativeScriptKind.RequireTimeAfter,
        slot: Cardano.Slot(Number.parseInt(json.slot))
      };

      break;
    }
    default: {
      throw new SerializationError(
        SerializationFailure.InvalidNativeScriptKind,
        `Native Script value '${json.type}' is not supported.`
      );
    }
  }

  return coreScript;
};
