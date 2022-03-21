/* eslint-disable no-use-before-define */
import { NativeScript } from './NativeScript';
import { PlutusScript } from './PlutusScript';
import { createUnionType } from 'type-graphql';

export const Script = createUnionType({
  name: 'Script',
  types: () => [PlutusScript, NativeScript] as const
});
