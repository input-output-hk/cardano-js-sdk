import { MetricsFilters, MetricsFiltersFieldType, MetricsFiltersFields } from './types';

/* eslint-disable @typescript-eslint/no-explicit-any */
export const PoolDataSortFields = ['cost', 'name', 'margin', 'pledge', 'ticker'] as const;
export const PoolMetricsSortFields = ['blocks', 'liveStake', 'saturation'] as const;
export const PoolAPYSortFields = ['apy'] as const;
export const PoolROSSortFields = ['ros', 'lastRos'] as const;

export const isPoolDataSortField = (value: string) => PoolDataSortFields.includes(value as any);
export const isPoolMetricsSortField = (value: string) => PoolMetricsSortFields.includes(value as any);
export const isPoolAPYSortField = (value: string) => PoolAPYSortFields.includes(value as any);
export const isPoolROSSortField = (value: string) => PoolROSSortFields.includes(value as any);

export const SortFields = [...PoolDataSortFields, ...PoolMetricsSortFields, ...PoolAPYSortFields, ...PoolROSSortFields];

export const metricsFilterBoundaries: {
  [K in MetricsFiltersFields]: { lower: MetricsFiltersFieldType<K>; upper: MetricsFiltersFieldType<K> };
} = {
  blocks: { lower: 0, upper: 100_000 },
  cost: { lower: 170, upper: 1_000_000 },
  lastRos: { lower: 0, upper: 1 },
  margin: { lower: 0, upper: 1 },
  pledge: { lower: 0n, upper: 80_000_000_000_000n },
  ros: { lower: 0, upper: 1 },
  saturation: { lower: 0, upper: 1.5 },
  stake: { lower: 0n, upper: 80_000_000_000_000n }
};

export class MetricsFilterError<T extends MetricsFiltersFields> extends RangeError {
  constructor(
    public field: T,
    public subField: 'from' | 'to',
    public check: 'lower' | 'order' | 'upper',
    value: Exclude<MetricsFilters[T], undefined>
  ) {
    const message = (() => {
      switch (check) {
        case 'lower':
          return `lesser than lower boundary ${metricsFilterBoundaries[field].lower}`;
        case 'order':
          return `greater than ${field}.to ${value.to}`;
        case 'upper':
          return `greater than upper boundary ${metricsFilterBoundaries[field].upper}`;
      }
    })();

    super(`${field}.${subField} ${value[subField]} ${message}`);
  }
}

export const checkMetricsFiltersField = <T extends MetricsFiltersFields>(
  field: T,
  value: Exclude<MetricsFilters[T], undefined>
) => {
  if (value.from !== undefined) {
    if (value.from < metricsFilterBoundaries[field].lower) throw new MetricsFilterError(field, 'from', 'lower', value);
    if (value.from > metricsFilterBoundaries[field].upper) throw new MetricsFilterError(field, 'from', 'upper', value);
    if (value.to !== undefined && value.from > value.to) throw new MetricsFilterError(field, 'from', 'order', value);
  }

  if (value.to !== undefined) {
    if (value.to < metricsFilterBoundaries[field].lower) throw new MetricsFilterError(field, 'to', 'lower', value);
    if (value.to > metricsFilterBoundaries[field].upper) throw new MetricsFilterError(field, 'to', 'upper', value);
  }
};

export const checkMetricsFilters = (metrics?: MetricsFilters) => {
  if (!metrics) return;

  for (const field of MetricsFiltersFields) {
    const filter = metrics[field];

    if (filter) checkMetricsFiltersField(field, filter);
  }
};
