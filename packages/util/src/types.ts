import { Primitive } from 'type-fest';

export interface Shutdown {
  shutdown(): void;
}

export type Awaited<T> = T extends PromiseLike<infer U> ? U : T;

/**
 * Recursively make all properties optional
 * Do not recurse into O types
 */
export type DeepPartial<T, O = never> = T extends O | Primitive
  ? T
  : {
      [P in keyof T]?: DeepPartial<T[P], O>;
    };
