import type { BlockKind } from './types.js';
import type { Schema } from '@cardano-ogmios/client';

export const BYRON_TX_FEE_COEFFICIENT = 43_946_000_000;
export const BYRON_TX_FEE_CONSTANT = 155_381_000_000_000;

export const isNativeScript = (script: Schema.Script): script is Schema.Native => 'native' in script;

export const isPlutusV1Script = (script: Schema.Script): script is Schema.PlutusV1 => 'plutus:v1' in script;

export const isPlutusV2Script = (script: Schema.Script): script is Schema.PlutusV2 => 'plutus:v2' in script;

export const isRequireAllOf = (nativeScript: Schema.ScriptNative): nativeScript is Schema.All =>
  typeof nativeScript === 'object' && 'all' in nativeScript;

export const isRequireAnyOf = (nativeScript: Schema.ScriptNative): nativeScript is Schema.Any =>
  typeof nativeScript === 'object' && 'any' in nativeScript;

export const isExpiresAt = (nativeScript: Schema.ScriptNative): nativeScript is Schema.ExpiresAt =>
  typeof nativeScript === 'object' && 'expiresAt' in nativeScript;

export const isStartsAt = (nativeScript: Schema.ScriptNative): nativeScript is Schema.StartsAt =>
  typeof nativeScript === 'object' && 'startsAt' in nativeScript;

export const isRequireNOf = (nativeScript: Schema.ScriptNative): nativeScript is Schema.NOf =>
  typeof nativeScript === 'object' && !Number.isNaN(Number(Object.keys(nativeScript)[0]));

export const isAlonzoOrAbove = (kind: BlockKind) => kind === 'babbage' || kind === 'alonzo';

export const isMaryOrAbove = (kind: BlockKind) => isAlonzoOrAbove(kind) || kind === 'mary';

export const isShelleyTx = (kind: BlockKind) => kind === 'shelley';
