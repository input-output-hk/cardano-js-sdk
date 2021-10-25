export const percentageDescription = 'Percentage in range [0; 1]';
export const coinDescription = 'Coin quantity';

export type BigIntsAsStrings<T> = bigint extends T
  ? string // Note: Add interfaces here of all GraphQL scalars that will be transformed into an object
  : T extends Date
  ? T
  : {
      [K in keyof T]: T[K] extends (infer U)[] ? BigIntsAsStrings<U>[] : BigIntsAsStrings<T[K]>;
    };
