export const isNotNil = <T>(item: T | null | undefined): item is T => typeof item !== 'undefined' && item !== null;
