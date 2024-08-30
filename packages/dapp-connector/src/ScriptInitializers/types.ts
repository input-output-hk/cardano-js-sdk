import { OpaqueString } from '@cardano-sdk/util';

const typedString = (value: string) => value;

export type ApiName = OpaqueString<'ApiName'>;
export const ApiName = (target: string) => typedString(target);
