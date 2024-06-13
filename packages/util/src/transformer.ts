import isUndefined from 'lodash/isUndefined.js';
import merge from 'lodash/merge.js';

export interface Transform<From, To, Context = {}> {
  (from: From, context?: Context): To extends object
    ? {
        [k in keyof Required<To>]: To[k];
      }
    : To;
}

export type Transformer<From, To, Context = {}> = {
  [k in keyof Required<To>]:
    | Transform<From, To[k], Context>
    | Transform<From, Promise<To[k]>, Context>
    | Transformer<From, To[k], Context>
    | Transformer<From, Promise<To[k]>, Context>;
};

const deepOmitBy = (obj: unknown, predicate: (o: unknown) => boolean): unknown => {
  if (Array.isArray(obj)) return obj; // Leave arrays alone

  if (obj && typeof obj === 'object') {
    return (
      Object.entries(obj)
        .map(([k, v]) => [k, typeof v === 'object' ? deepOmitBy(v, predicate) : v, predicate(v)])
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        .reduce((result, [k, v, omit]) => (omit ? result : merge(result, { [k]: v })), {} as any)
    );
  }
  return obj;
};

/**
 * The provided object is used to build an object using the provided Transformer.
 * It's useful for enforcing complete transformation of one format to another.
 */
export const transformObj = async <From, To, Context = {}>(
  from: From,
  transformer: Transformer<From, To, Context>,
  context?: Context
): Promise<To> => {
  const entries = Object.entries(transformer);
  const result = Object.create({});

  for (const [key, value] of entries) {
    result[key] = await (typeof value === 'function'
      ? (value as Transform<From, unknown, unknown>)(from, context)
      : transformObj(from, value as Transformer<From, unknown, Context>, context));
  }

  return deepOmitBy(result, isUndefined) as To;
};
