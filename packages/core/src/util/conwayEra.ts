// LW-10773 remove this file

/**
 * Specifies if SDK should behave as in Conway era. Defaults to true; consumers needing
 * pre-Conway encodings must call setInConwayEra(false) and restore the default afterwards.
 */
// eslint-disable-next-line import/no-mutable-exports
export let inConwayEra = true;

export const setInConwayEra = (value: boolean) => (inConwayEra = value);
