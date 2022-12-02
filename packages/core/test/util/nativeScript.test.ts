import { Ed25519KeyHash, NativeScript, NativeScriptKind, ScriptType, Slot } from '../../src/Cardano';
import { nativeScriptPolicyId } from '../../src';

describe('nativeScript utils', () => {
  it('can derive the policy id from a NativeScript', () => {
    const script: NativeScript = {
      __type: ScriptType.Native,
      kind: NativeScriptKind.RequireAnyOf,
      scripts: [
        {
          __type: ScriptType.Native,
          keyHash: Ed25519KeyHash('b275b08c999097247f7c17e77007c7010cd19f20cc086ad99d398538'),
          kind: NativeScriptKind.RequireSignature
        },
        {
          __type: ScriptType.Native,
          kind: NativeScriptKind.RequireAllOf,
          scripts: [
            {
              __type: ScriptType.Native,
              kind: NativeScriptKind.RequireTimeBefore,
              slot: Slot(3000)
            },
            {
              __type: ScriptType.Native,
              keyHash: Ed25519KeyHash('966e394a544f242081e41d1965137b1bb412ac230d40ed5407821c37'),
              kind: NativeScriptKind.RequireSignature
            },
            {
              __type: ScriptType.Native,
              kind: NativeScriptKind.RequireTimeAfter,
              slot: Slot(4000)
            }
          ]
        }
      ]
    };
    expect(nativeScriptPolicyId(script)).toEqual('8b8370c97ae17eb69a8c97f733888f7485b60fd820c69211c8bbeb56');
  });
});
