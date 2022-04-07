import { transform } from 'lodash-es';

const PLAIN_TYPES = new Set(['boolean', 'number', 'string']);

export const toSerializableObject = (obj: unknown): unknown => {
  if (PLAIN_TYPES.has(typeof obj)) return obj;
  if (typeof obj === 'undefined') {
    return {
      __type: 'undefined'
    };
  }
  if (typeof obj === 'object') {
    if (obj === null) return null;
    if (Array.isArray(obj)) {
      return obj.map((item) => toSerializableObject(item));
    }
    if (ArrayBuffer.isView(obj)) {
      const arr = new Uint8Array(obj.buffer, obj.byteOffset, obj.byteLength / Uint8Array.BYTES_PER_ELEMENT);
      const value = Buffer.from(arr).toString('hex');
      return { __type: 'Buffer', value };
    }
    if (obj instanceof Map) {
      return {
        __type: 'Map',
        value: [...obj.entries()].map(([key, value]) => [toSerializableObject(key), toSerializableObject(value)])
      };
    }
    return transform(
      obj,
      (result, value, key) => {
        result[key] = toSerializableObject(value);
        return result;
      },
      {} as Record<string | number | symbol, unknown>
    );
  }
  if (typeof obj === 'bigint')
    return {
      __type: 'bigint',
      value: obj.toString()
    };
};

// eslint-disable-next-line sonarjs/cognitive-complexity
const fromSerializableObjectUnknown = (obj: unknown): unknown => {
  if (PLAIN_TYPES.has(typeof obj)) return obj;
  if (typeof obj === 'object') {
    if (obj === null) return null;
    if (Array.isArray(obj)) {
      return obj.map(fromSerializableObjectUnknown);
    }
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const docAsAny = obj as any;
    if (docAsAny.__type === 'undefined') return undefined;
    if (docAsAny.__type === 'bigint') return BigInt(docAsAny.value);
    if (docAsAny.__type === 'Buffer') return Buffer.from(docAsAny.value, 'hex');
    if (docAsAny.__type === 'Map')
      return new Map(docAsAny.value.map((keyValues: unknown[]) => keyValues.map(fromSerializableObjectUnknown)));
    return transform(
      obj,
      (result, value, key) => {
        result[key] = fromSerializableObjectUnknown(value);
        return result;
      },
      {} as Record<string | number | symbol, unknown>
    );
  }
};

export const fromSerializableObject = <T>(serializableObject: unknown) =>
  fromSerializableObjectUnknown(serializableObject) as T;
