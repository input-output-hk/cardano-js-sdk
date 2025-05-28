import type { Logger } from 'ts-log';
import type { Primitive } from 'type-fest';

export interface Shutdown {
  shutdown(): void;
}

export type Awaited<T> = T extends PromiseLike<infer U> ? U : T;

/** Recursively make all properties optional Do not recurse into O types */
export type DeepPartial<T, O = never> = T extends O | Primitive
  ? T
  : {
      [P in keyof T]?: DeepPartial<T[P], O>;
    };

export interface Freeable {
  free: () => void;
}

export interface WithLogger {
  logger: Logger;
}

// https://stackoverflow.com/a/57117594
// eslint-disable-next-line @typescript-eslint/no-explicit-any
type Impossible<K extends keyof any> = {
  [P in K]: never;
};
export type NoExtraProperties<T, U> = U & Impossible<Exclude<keyof U, keyof T>>;

export type Cache<T> = {
  get(key: string): Promise<T | undefined>;
  set(key: string, value: T): Promise<void>;
};
