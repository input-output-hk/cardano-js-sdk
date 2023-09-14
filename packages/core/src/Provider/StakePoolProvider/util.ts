/* eslint-disable @typescript-eslint/no-explicit-any */
export const PoolDataSortFields = ['name', 'cost'] as const;
export const PoolMetricsSortFields = ['saturation'] as const;
export const PoolAPYSortFields = ['apy'] as const;
export const PoolROSSortFields = ['ros', 'lastRos'] as const;

export const isPoolDataSortField = (value: string) => PoolDataSortFields.includes(value as any);
export const isPoolMetricsSortField = (value: string) => PoolMetricsSortFields.includes(value as any);
export const isPoolAPYSortField = (value: string) => PoolAPYSortFields.includes(value as any);
export const isPoolROSSortField = (value: string) => PoolROSSortFields.includes(value as any);

export const SortFields = [...PoolDataSortFields, ...PoolMetricsSortFields, ...PoolAPYSortFields, ...PoolROSSortFields];
