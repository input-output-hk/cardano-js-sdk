export const isNotNil = <T>(item: T | null | undefined | 0): item is T => !!item;
