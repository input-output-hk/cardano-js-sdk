/* eslint-disable @typescript-eslint/no-explicit-any */
export const PoolDataSortFields = ['name'] as const;
export const PoolMetricsSortFields = ['saturation'] as const;

export const isPoolDataSortField = (value: string) => PoolDataSortFields.includes(value as any);
export const isPoolMetricsSortField = (value: string) => PoolMetricsSortFields.includes(value as any);
