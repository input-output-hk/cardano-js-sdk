export type PromiseOrValue<T> = Promise<T> | T;

export const resolveObjectValues = async <T>(obj: { [k: string]: PromiseOrValue<T> }): Promise<{ [k: string]: T }> =>
  Object.fromEntries(
    await Promise.all(
      Object.entries(obj).map(([key, promise]) => Promise.resolve(promise).then((value) => [key, value]))
    )
  );

export const removeUndefinedFields = <T extends Record<string, any>>(obj: T): T => {
  for (const [key, value] of Object.entries(obj)) {
    if (value === undefined) {
      delete obj[key];
    }
  }
  return obj;
};
