import { util } from '../../src';

const serializeAndDeserialize = (obj: unknown) =>
  util.fromSerializableObject(JSON.parse(JSON.stringify(util.toSerializableObject(obj))));

describe('serializableObject', () => {
  it('supports plain types', () => {
    expect(serializeAndDeserialize(123)).toEqual(123);
    expect(serializeAndDeserialize('123')).toEqual('123');
    expect(serializeAndDeserialize(true)).toEqual(true);
    expect(serializeAndDeserialize(null)).toEqual(null);
  });

  it('supports nested arrays', () => {
    const obj = [123, [456, 789]];
    expect(serializeAndDeserialize(obj)).toEqual(obj);
  });

  it('supports nested objects', () => {
    const obj = {
      a: {
        b: {
          c: 'c',
          d: 'd'
        }
      }
    };
    expect(serializeAndDeserialize(obj)).toEqual(obj);
  });

  it('supports types that are used in SDK, but not natively supported in JSON', () => {
    const obj = {
      bigint: 123n,
      buffer: Buffer.from('data'),
      map: new Map([['key', 'value']]),
      undefined
    };
    expect(serializeAndDeserialize(obj)).toEqual(obj);
  });
});
