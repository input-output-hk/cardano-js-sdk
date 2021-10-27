/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable no-proto */
/* eslint-disable unicorn/no-nested-ternary */

// Source of "replaceNullsWithUndefineds":
// https://github.com/apollographql/apollo-client/issues/2412#issuecomment-755449680
// Source of OptionalUndefined<T>:
// https://github.com/Microsoft/TypeScript/issues/12400#issuecomment-758523767

type KeysOfType<T, SelectedType> = {
  [key in keyof T]: SelectedType extends T[key] ? key : never;
}[keyof T];

type Optional<T> = Partial<Pick<T, KeysOfType<T, undefined>>>;

type Required<T> = Omit<T, KeysOfType<T, undefined>>;

export type OptionalUndefined<T> = Optional<T> & Required<T>;

// TODO: create use OptionalUndefined<> for objects in RecursivelyReplaceNullWithUndefined,
// and refactor core/Cardano/types/index exports to not duplicate the type helper

export type RecursivelyReplaceNullWithUndefined<T> = T extends null
  ? undefined // Note: Add interfaces here of all GraphQL scalars that will be transformed into an object
  : T extends Date
  ? T
  : {
      [K in keyof T]: T[K] extends (infer U)[]
        ? RecursivelyReplaceNullWithUndefined<U>[]
        : RecursivelyReplaceNullWithUndefined<T[K]>;
    };

/**
 * Recursively replaces all nulls with undefineds.
 * Skips object classes (that have a `.__proto__.constructor`).
 */
export const replaceNullsWithUndefineds = <T>(obj: T): RecursivelyReplaceNullWithUndefined<T> => {
  const newObj: any = {};
  for (const k of Object.keys(obj)) {
    const v: any = (obj as any)[k];
    newObj[k as keyof T] =
      v === null
        ? undefined
        : v && typeof v === 'object' && v.__proto__.constructor === Object
        ? replaceNullsWithUndefineds(v)
        : v;
  }
  return newObj;
};
