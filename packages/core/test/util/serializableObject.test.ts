import { CustomError } from 'ts-custom-error';
import { FromSerializableObjectOptions } from '../../src/util/misc';
import { util } from '../../src';

const serializeAndDeserialize = (obj: unknown, deserializeOptions?: FromSerializableObjectOptions) =>
  util.fromSerializableObject(JSON.parse(JSON.stringify(util.toSerializableObject(obj))), deserializeOptions);

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
    const deserialized = serializeAndDeserialize(err, { getErrorPrototype: () => CustomError.prototype });
    expect(deserialized).toEqual(err);
    expect(deserialized).toBeInstanceOf(CustomError);
  });

  it('supports custom transformation discriminator key', () => {
    const customKeyOption = { transformationTypeKey: 'discriminator' };
    const obj = { bigint: 1n };
    const serializedObj = util.toSerializableObject(obj, customKeyOption);
    expect(util.fromSerializableObject(serializedObj)).not.toEqual(obj);
    expect(util.fromSerializableObject(serializedObj, customKeyOption)).toEqual(obj);
  });

  it('supports object key transformation', () => {
    const obj = {
      __a: 'val__a',
      b: 'valb'
    };
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const serializableObj: any = util.toSerializableObject(obj, {
      serializeKey(key) {
        if (key === '__a') return 'key__a';
        return key;
      }
    });
    expect(serializableObj).toEqual({
      b: obj.b,
      key__a: obj.__a
    });
    expect(
      util.fromSerializableObject(obj, {
        deserializeKey(key) {
          if (key === 'key__a') return '__a';
          return key;
        }
      })
    ).toEqual(obj);
  });
});
