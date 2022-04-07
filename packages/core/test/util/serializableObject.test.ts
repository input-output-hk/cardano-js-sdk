import { CustomError } from 'ts-custom-error';
import { GetErrorPrototype } from '../../src/util/misc';
import { util } from '../../src';

const serializeAndDeserialize = (obj: unknown, getErrorPrototype?: GetErrorPrototype) =>
  util.fromSerializableObject(JSON.parse(JSON.stringify(util.toSerializableObject(obj))), getErrorPrototype);

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
      date: new Date(),
      error: new Error('error obj'),
      map: new Map([['key', 'value']]),
      undefined
    };
    expect(serializeAndDeserialize(obj)).toEqual(obj);
  });

  it('supports custom error types', () => {
    const err = new CustomError('msg');
    const deserialized = serializeAndDeserialize(err, () => CustomError.prototype);
    expect(deserialized).toEqual(err);
    expect(deserialized).toBeInstanceOf(CustomError);
  });
});
