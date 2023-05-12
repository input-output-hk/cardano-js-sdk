export const isPromise = <T>(obj: T | Promise<T>): obj is Promise<T> =>
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  typeof obj === 'object' && typeof (obj as any).then === 'function';
