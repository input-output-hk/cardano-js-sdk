import { fetchSequentially, replaceNumbersWithBigints } from '../src/util';

describe('util', () => {
  test('replaceNumbersWithBigints', () => {
    expect(replaceNumbersWithBigints(1)).toBe(1n);
    expect(replaceNumbersWithBigints('a')).toBe('a');
    expect(replaceNumbersWithBigints(null)).toBe(null);
    // eslint-disable-next-line unicorn/no-useless-undefined
    expect(replaceNumbersWithBigints(undefined)).toBe(undefined);
    expect(replaceNumbersWithBigints(['a', 1, [2]])).toEqual(['a', 1n, [2n]]);
    expect(replaceNumbersWithBigints({ a: 'a', b: 1, c: { d: 2 } })).toEqual({ a: 'a', b: 1n, c: { d: 2n } });
  });

  test('fetchSequentially', async () => {
    const batch1 = [{ a: 1 }, { a: 2 }];
    const batch2 = [{ a: 3 }, { a: 4 }];
    const batch3 = [{ a: 5 }];
    const request = jest
      .fn<Promise<typeof batch1>, [string]>()
      .mockResolvedValueOnce(batch1)
      .mockResolvedValueOnce(batch2)
      .mockResolvedValueOnce(batch3);
    const arg = 'arg';
    const result = await fetchSequentially(
      {
        arg,
        request,
        responseTranslator: (items: Array<typeof batch1[0]>, arg0) => items.map(({ a }) => ({ arg: arg0, b: a }))
      },
      2
    );
    expect(result).toEqual([
      { arg, b: 1 },
      { arg, b: 2 },
      { arg, b: 3 },
      { arg, b: 4 },
      { arg, b: 5 }
    ]);
    expect(request).toBeCalledTimes(3);
  });
});
