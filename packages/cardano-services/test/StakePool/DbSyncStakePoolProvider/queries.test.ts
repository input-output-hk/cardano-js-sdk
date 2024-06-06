import { withSort } from '../../../src/StakePool/DbSyncStakePoolProvider/queries.js';

describe('queries', () => {
  describe('withSort', () => {
    const dummyQuery = 'SELECT * FROM table';
    test('sort by field with no mapping', () => {
      const query = withSort(dummyQuery, { field: 'saturation', order: 'asc' });
      expect(query).toEqual(`${dummyQuery} ORDER BY saturation asc NULLS LAST, id asc NULLS LAST`);
    });
    test('sort by field with simple mapping', () => {
      const query = withSort(dummyQuery, { field: 'name', order: 'asc' });
      expect(query).toEqual(
        `${dummyQuery} ORDER BY lower((pod.json ->> 'name')::TEXT) asc NULLS LAST, pool_id asc NULLS LAST`
      );
    });
    test('sort by field with secondary sorts', () => {
      const query = withSort(dummyQuery, { field: 'cost', order: 'asc' });
      expect(query).toEqual(
        `${dummyQuery} ORDER BY fixed_cost asc NULLS LAST, margin asc NULLS LAST, pool_id asc NULLS LAST`
      );
    });
    test('single default sort', () => {
      const query = withSort(dummyQuery, undefined, [{ field: 'some_field', order: 'asc' }]);
      expect(query).toEqual(`${dummyQuery} ORDER BY some_field asc NULLS LAST`);
    });
    test('multiple default sort', () => {
      const query = withSort(dummyQuery, undefined, [
        { field: 'some_field', order: 'asc' },
        { field: 'another_field', order: 'desc' }
      ]);
      expect(query).toEqual(`${dummyQuery} ORDER BY some_field asc NULLS LAST, another_field desc NULLS LAST`);
    });
    test('multiple default sort with secondary mapped sorts', () => {
      const query = withSort(dummyQuery, undefined, [
        { field: 'some_field', order: 'asc' },
        { field: 'cost', order: 'desc' }
      ]);
      expect(query).toEqual(
        `${dummyQuery} ORDER BY some_field asc NULLS LAST, fixed_cost desc NULLS LAST, margin desc NULLS LAST`
      );
    });
  });
});
