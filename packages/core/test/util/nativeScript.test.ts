import * as Cardano from '../../src/Cardano/index.js';
import { Ed25519KeyHashHex } from '@cardano-sdk/crypto';
import { NativeScriptKind, ScriptType, Slot } from '../../src/Cardano/index.js';
import { jsonToNativeScript, nativeScriptPolicyId } from '../../src/index.js';
import type { NativeScript } from '../../src/Cardano/index.js';

describe('nativeScript utils', () => {
  it('can derive the policy id from a NativeScript', () => {
    const script: NativeScript = {
      __type: ScriptType.Native,
      kind: NativeScriptKind.RequireAnyOf,
      scripts: [
        {
          __type: ScriptType.Native,
          keyHash: Ed25519KeyHashHex('b275b08c999097247f7c17e77007c7010cd19f20cc086ad99d398538'),
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
              keyHash: Ed25519KeyHashHex('966e394a544f242081e41d1965137b1bb412ac230d40ed5407821c37'),
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

  it('can convert a json representation of a sig script to core NativeScript', () => {
    // Arrange
    const jsonScript = {
      keyHash: 'e09d36c79dec9bd1b3d9e152247701cd0bb860b5ebfd1de8abb6735a',
      type: 'sig'
    };

    const expectedScript: NativeScript = {
      __type: Cardano.ScriptType.Native,
      keyHash: Ed25519KeyHashHex('e09d36c79dec9bd1b3d9e152247701cd0bb860b5ebfd1de8abb6735a'),
      kind: Cardano.NativeScriptKind.RequireSignature
    };

    // Act
    const actualScript = jsonToNativeScript(jsonScript);

    // Assert
    expect(expectedScript).toEqual(actualScript);
  });

  it('can convert a json representation of an all script to core NativeScript', () => {
    // Arrange
    const jsonScript = {
      scripts: [
        {
          keyHash: 'e09d36c79dec9bd1b3d9e152247701cd0bb860b5ebfd1de8abb6735a',
          type: 'sig'
        },
        {
          keyHash: 'a687dcc24e00dd3caafbeb5e68f97ca8ef269cb6fe971345eb951756',
          type: 'sig'
        },
        {
          keyHash: '0bd1d702b2e6188fe0857a6dc7ffb0675229bab58c86638ffa87ed6d',
          type: 'sig'
        }
      ],
      type: 'all'
    };

    const expectedScript: NativeScript = {
      __type: Cardano.ScriptType.Native,
      kind: Cardano.NativeScriptKind.RequireAllOf,
      scripts: [
        {
          __type: Cardano.ScriptType.Native,
          keyHash: Ed25519KeyHashHex('e09d36c79dec9bd1b3d9e152247701cd0bb860b5ebfd1de8abb6735a'),
          kind: Cardano.NativeScriptKind.RequireSignature
        },
        {
          __type: Cardano.ScriptType.Native,
          keyHash: Ed25519KeyHashHex('a687dcc24e00dd3caafbeb5e68f97ca8ef269cb6fe971345eb951756'),
          kind: Cardano.NativeScriptKind.RequireSignature
        },
        {
          __type: Cardano.ScriptType.Native,
          keyHash: Ed25519KeyHashHex('0bd1d702b2e6188fe0857a6dc7ffb0675229bab58c86638ffa87ed6d'),
          kind: Cardano.NativeScriptKind.RequireSignature
        }
      ]
    };
    // Act
    const actualScript = jsonToNativeScript(jsonScript);

    // Assert
    expect(expectedScript).toEqual(actualScript);
  });

  it('can convert a json representation of an any script to core NativeScript', () => {
    // Arrange
    const jsonScript = {
      scripts: [
        {
          keyHash: 'e09d36c79dec9bd1b3d9e152247701cd0bb860b5ebfd1de8abb6735a',
          type: 'sig'
        },
        {
          keyHash: 'a687dcc24e00dd3caafbeb5e68f97ca8ef269cb6fe971345eb951756',
          type: 'sig'
        },
        {
          keyHash: '0bd1d702b2e6188fe0857a6dc7ffb0675229bab58c86638ffa87ed6d',
          type: 'sig'
        }
      ],
      type: 'any'
    };

    const expectedScript: NativeScript = {
      __type: Cardano.ScriptType.Native,
      kind: Cardano.NativeScriptKind.RequireAnyOf,
      scripts: [
        {
          __type: Cardano.ScriptType.Native,
          keyHash: Ed25519KeyHashHex('e09d36c79dec9bd1b3d9e152247701cd0bb860b5ebfd1de8abb6735a'),
          kind: Cardano.NativeScriptKind.RequireSignature
        },
        {
          __type: Cardano.ScriptType.Native,
          keyHash: Ed25519KeyHashHex('a687dcc24e00dd3caafbeb5e68f97ca8ef269cb6fe971345eb951756'),
          kind: Cardano.NativeScriptKind.RequireSignature
        },
        {
          __type: Cardano.ScriptType.Native,
          keyHash: Ed25519KeyHashHex('0bd1d702b2e6188fe0857a6dc7ffb0675229bab58c86638ffa87ed6d'),
          kind: Cardano.NativeScriptKind.RequireSignature
        }
      ]
    };
    // Act
    const actualScript = jsonToNativeScript(jsonScript);

    // Assert
    expect(expectedScript).toEqual(actualScript);
  });

  it('can convert a json representation of an atLeast script to core NativeScript', () => {
    // Arrange
    const jsonScript = {
      required: 2,
      scripts: [
        {
          keyHash: 'e09d36c79dec9bd1b3d9e152247701cd0bb860b5ebfd1de8abb6735a',
          type: 'sig'
        },
        {
          keyHash: 'a687dcc24e00dd3caafbeb5e68f97ca8ef269cb6fe971345eb951756',
          type: 'sig'
        },
        {
          keyHash: '0bd1d702b2e6188fe0857a6dc7ffb0675229bab58c86638ffa87ed6d',
          type: 'sig'
        }
      ],
      type: 'atLeast'
    };

    const expectedScript: NativeScript = {
      __type: Cardano.ScriptType.Native,
      kind: Cardano.NativeScriptKind.RequireNOf,
      required: 2,
      scripts: [
        {
          __type: Cardano.ScriptType.Native,
          keyHash: Ed25519KeyHashHex('e09d36c79dec9bd1b3d9e152247701cd0bb860b5ebfd1de8abb6735a'),
          kind: Cardano.NativeScriptKind.RequireSignature
        },
        {
          __type: Cardano.ScriptType.Native,
          keyHash: Ed25519KeyHashHex('a687dcc24e00dd3caafbeb5e68f97ca8ef269cb6fe971345eb951756'),
          kind: Cardano.NativeScriptKind.RequireSignature
        },
        {
          __type: Cardano.ScriptType.Native,
          keyHash: Ed25519KeyHashHex('0bd1d702b2e6188fe0857a6dc7ffb0675229bab58c86638ffa87ed6d'),
          kind: Cardano.NativeScriptKind.RequireSignature
        }
      ]
    };
    // Act
    const actualScript = jsonToNativeScript(jsonScript);

    // Assert
    expect(expectedScript).toEqual(actualScript);
  });

  it('can convert a json representation of a after script to core NativeScript', () => {
    // Arrange
    const jsonScript = {
      scripts: [
        {
          slot: 1000,
          type: 'after'
        },
        {
          keyHash: '966e394a544f242081e41d1965137b1bb412ac230d40ed5407821c37',
          type: 'sig'
        }
      ],
      type: 'all'
    };

    const expectedScript: NativeScript = {
      __type: Cardano.ScriptType.Native,
      kind: Cardano.NativeScriptKind.RequireAllOf,
      scripts: [
        {
          __type: Cardano.ScriptType.Native,
          kind: Cardano.NativeScriptKind.RequireTimeAfter,
          slot: Cardano.Slot(1000)
        },
        {
          __type: Cardano.ScriptType.Native,
          keyHash: Ed25519KeyHashHex('966e394a544f242081e41d1965137b1bb412ac230d40ed5407821c37'),
          kind: Cardano.NativeScriptKind.RequireSignature
        }
      ]
    };
    // Act
    const actualScript = jsonToNativeScript(jsonScript);

    // Assert
    expect(expectedScript).toEqual(actualScript);
  });

  it('can convert a json representation of an before script to core NativeScript', () => {
    // Arrange
    const jsonScript = {
      scripts: [
        {
          slot: 1000,
          type: 'before'
        },
        {
          keyHash: '966e394a544f242081e41d1965137b1bb412ac230d40ed5407821c37',
          type: 'sig'
        }
      ],
      type: 'all'
    };

    const expectedScript: NativeScript = {
      __type: Cardano.ScriptType.Native,
      kind: Cardano.NativeScriptKind.RequireAllOf,
      scripts: [
        {
          __type: Cardano.ScriptType.Native,
          kind: Cardano.NativeScriptKind.RequireTimeBefore,
          slot: Cardano.Slot(1000)
        },
        {
          __type: Cardano.ScriptType.Native,
          keyHash: Ed25519KeyHashHex('966e394a544f242081e41d1965137b1bb412ac230d40ed5407821c37'),
          kind: Cardano.NativeScriptKind.RequireSignature
        }
      ]
    };
    // Act
    const actualScript = jsonToNativeScript(jsonScript);

    // Assert
    expect(expectedScript).toEqual(actualScript);
  });

  it('throws if the json is an invalid native script', () => {
    // Arrange
    const jsonScript = {
      value: 1000
    };

    // Act
    expect(() => jsonToNativeScript(jsonScript)).toThrow();
  });

  it('throws if the json is has an invalid script kind', () => {
    // Arrange
    const jsonScript = {
      scripts: [
        {
          slot: 1000,
          type: 'before'
        }
      ],
      type: 'every'
    };

    // Act
    expect(() => jsonToNativeScript(jsonScript)).toThrow();
  });
});
