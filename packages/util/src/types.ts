export interface Shutdown {
  shutdown(): void;
}

export type Awaited<T> = T extends PromiseLike<infer U> ? U : T;
