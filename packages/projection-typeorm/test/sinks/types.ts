/* eslint-disable @typescript-eslint/no-explicit-any */

// Consider moving this to projection package src types
type InferArg<T> = T extends (arg: infer Arg) => any ? Arg : never;
export type SinkEventType<Sink extends { sink: any }> = InferArg<Sink['sink']>;
