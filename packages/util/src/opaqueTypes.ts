import type { Tagged } from 'type-fest';

export type OpaqueString<T extends PropertyKey> = Tagged<string, T>;
export type OpaqueNumber<T extends PropertyKey> = Tagged<number, T>;
