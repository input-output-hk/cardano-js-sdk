export type ModuleState = null | 'initializing' | 'initialized';
// TODO: move to `util` package once implemented
export type Awaited<T> = T extends PromiseLike<infer U> ? U : T;
