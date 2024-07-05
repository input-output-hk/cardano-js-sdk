// LW-10773 remove this file

/** Specifies if SDK should behave as in Conway era. */
// eslint-disable-next-line import/no-mutable-exports
export let inConwayEra = false as const;

export const setInConwayEra = (value: boolean) => (inConwayEra = value as false);
