import { MetricsFilterError, MetricsFilters, MetricsFiltersFields, checkMetricsFilters } from '../../../src';

const testError = (
  filters: MetricsFilters,
  message: string,
  field: MetricsFiltersFields,
  subField: 'from' | 'to',
  check: 'lower' | 'order' | 'upper'
) => {
  expect.assertions(5);

  try {
    checkMetricsFilters(filters);
  } catch (error) {
    expect(error).toBeInstanceOf(MetricsFilterError);

    if (error instanceof MetricsFilterError) {
      expect(error.message).toEqual(message);
      expect(error.field).toEqual(field);
      expect(error.subField).toEqual(subField);
      expect(error.check).toEqual(check);
    }
  }
};

describe('checkMetricsFilters', () => {
  it("doesn't throw with value inside boundaries", () => {
    expect.assertions(0);
    checkMetricsFilters({ cost: { from: 200, to: 2000 }, margin: { from: 0.5 }, pledge: { to: 1_000_000n } });
  });

  it('throws with ros.from lower than lower boundary', () =>
    testError({ ros: { from: -2 } }, 'ros.from -2 lesser than lower boundary 0', 'ros', 'from', 'lower'));

  it('throws with stake.to greater than upper boundary', () =>
    testError(
      { stake: { to: 100_000_000_000_000n } },
      'stake.to 100000000000000 greater than upper boundary 80000000000000',
      'stake',
      'to',
      'upper'
    ));

  it('throws with blocks.from greater than blocks.to', () =>
    testError(
      { blocks: { from: 1000, to: 100 } },
      'blocks.from 1000 greater than blocks.to 100',
      'blocks',
      'from',
      'order'
    ));
});
