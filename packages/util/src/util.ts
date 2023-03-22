export type PromiseOrValue<T> = Promise<T> | T;

export const resolveObjectValues = async <T>(obj: { [k: string]: PromiseOrValue<T> }): Promise<{ [k: string]: T }> =>
  Object.fromEntries(
    await Promise.all(
      Object.entries(obj).map(([key, promise]) => Promise.resolve(promise).then((value) => [key, value]))
    )
  );
