import { deepEquals } from '../src';

describe('equals', () => {
  test('deepEquals', () => {
    expect(deepEquals([], [])).toBe(true);
    expect(deepEquals({}, {})).toBe(true);
    expect(deepEquals([{ prop: 'prop' }], [{ prop: 'prop' }])).toBe(true);
    expect(deepEquals([{ prop: 'prop' }], [{ prop: 'prop2' }])).toBe(false);
  });
});
