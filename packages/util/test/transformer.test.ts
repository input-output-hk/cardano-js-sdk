import { transformObj } from '../src/index.js';
import type { Transformer } from '../src/index.js';

const stubDns = new Map<string, string>([
  ['localhost', '0.0.0.0'],
  ['someAddress', '192.168.0.1'],
  ['someAddress2', '192.168.0.2']
]);

describe('transformObj transforms the provided object using the provided Transformer object', () => {
  test('from larger type into a smaller type', async () => {
    type From = { a: string; b: string; c: { d: bigint } };
    type To = { a: number; b: number; d: number };
    const TestTransformer: Transformer<From, To> = {
      a: (from) => Number.parseInt(from.a),
      b: (from) => Number.parseInt(from.b),
      d: (from) => Number(from.c.d)
    };
    const transformed = await transformObj({ a: '1', b: '2', c: { d: 4n } }, TestTransformer);
    const expected: To = { a: 1, b: 2, d: 4 };
    expect(transformed).toEqual(expected);
  });

  test('from types with array in fields', async () => {
    type From = { a: string; b: string[]; c: { d: bigint[] } };
    type To = { a: number; b: number[]; d: number };
    const TestTransformer: Transformer<From, To> = {
      a: (from) => Number.parseInt(from.a),
      b: (from) => from.b.map(Number),
      d: (from) => Number(from.c.d.reduce((accumulator, currentValue) => accumulator + Number(currentValue), 0))
    };
    const transformed = await transformObj({ a: '1', b: ['2', '3', '4'], c: { d: [4n, 5n] } }, TestTransformer);
    const expected: To = { a: 1, b: [2, 3, 4], d: 9 };

    expect(transformed).toEqual(expected);
  });

  describe('smaller type into a larger type', () => {
    type From = { a: number; b: number; d: number };
    type To = { a: string; b: string; c: { d: bigint; e?: number } };
    const toTransform: From = { a: 1, b: 2, d: 4 };
    const expected: To = { a: '1', b: '2', c: { d: 4n } };

    test('through top level property mapping', async () => {
      const TopLevelTransformer: Transformer<From, To> = {
        a: (from) => from.a.toString(),
        b: (from) => from.b.toString(),
        c: (from) => ({ d: BigInt(from.d), e: void 0 })
      };
      const transformed = await transformObj(toTransform, TopLevelTransformer);
      expect(transformed).toEqual(expected);
      expect('e' in transformed.c).toBe(false);
    });

    test('through nested property mapping', async () => {
      const NestedTransformer: Transformer<From, To> = {
        a: (from) => from.a.toString(),
        b: (from) => from.b.toString(),
        c: {
          d: (from) => BigInt(from.d),
          e: () => void 0
        }
      };
      const transformed = await transformObj(toTransform, NestedTransformer);
      expect(transformed).toEqual(expected);
      expect('e' in transformed.c).toBe(false);
    });
  });

  test('can use a transformation context', async () => {
    // Types
    type IpAddress = string;
    type Domain = string;
    type Context = { dnsResolver: (domain: Domain) => IpAddress };
    type From = { a: { domain: Domain; b: { domain: Domain } } };
    type To = { a: { ip: IpAddress; b: { ip: IpAddress } } };

    const transformationContext = {
      dnsResolver: (domain: Domain) => (stubDns.has(domain) ? stubDns.get(domain)! : 'unknown')
    };

    const testTransformer: Transformer<From, To, Context> = {
      a: {
        b: {
          ip: (from, context) => context!.dnsResolver(from.a.b.domain)
        },
        ip: (from, context) => context!.dnsResolver(from.a.domain)
      }
    };

    const transformed = await transformObj(
      { a: { b: { domain: 'localhost' }, domain: 'someAddress2' } },
      testTransformer,
      transformationContext
    );

    const expected = { a: { b: { ip: '0.0.0.0' }, ip: '192.168.0.2' } };

    expect(transformed).toEqual(expected);
  });

  test('can use a transformation context with async operations', async () => {
    // Types
    type IpAddress = string;
    type Domain = string;
    type Context = { dnsResolver: (domain: Domain) => Promise<IpAddress> };
    type From = { a: { domain: Domain; b: { domain: Domain } } };
    type To = { a: { ip: IpAddress; b: { ip: IpAddress } } };

    const transformationContext = {
      dnsResolver: async (domain: Domain) => (stubDns.has(domain) ? stubDns.get(domain)! : 'unknown')
    };

    const testTransformer: Transformer<From, To, Context> = {
      a: {
        b: {
          ip: async (from, context) => await context!.dnsResolver(from.a.b.domain)
        },
        ip: async (from, context) => await context!.dnsResolver(from.a.domain)
      }
    };

    const transformed = await transformObj(
      { a: { b: { domain: 'localhost' }, domain: 'someAddress' } },
      testTransformer,
      transformationContext
    );

    const expected: To = { a: { b: { ip: '0.0.0.0' }, ip: '192.168.0.1' } };
    expect(transformed).toEqual(expected);
  });
});
