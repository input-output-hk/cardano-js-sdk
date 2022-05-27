/* eslint-disable complexity */
/* eslint-disable sonarjs/cognitive-complexity */
import { serializeError } from 'serialize-error';
import { transform } from 'lodash-es';

const PLAIN_TYPES = new Set(['boolean', 'number', 'string']);

export type TransformKey = (key: string) => string;
export type GetErrorPrototype = (err: unknown) => typeof Error.prototype;

export interface ToSerializableObjectOptions {
  serializeKey?: TransformKey;
}

export interface FromSerializableObjectOptions {
  deserializeKey?: TransformKey;
  getErrorPrototype?: GetErrorPrototype;
}

const defaultGetErrorPrototype: GetErrorPrototype = () => Error.prototype;
const defaultTransformKey: TransformKey = (key) => key;

export const toSerializableObject = (obj: unknown, options?: ToSerializableObjectOptions): unknown => {
  if (PLAIN_TYPES.has(typeof obj)) return obj;
  if (typeof obj === 'undefined') {
    return {
      __type: 'undefined'
    };
  }
  if (typeof obj === 'object') {
    if (obj === null) return null;
    if (Array.isArray(obj)) {
      return obj.map((item) => toSerializableObject(item, options));
    }
    if (ArrayBuffer.isView(obj)) {
      const arr = new Uint8Array(obj.buffer, obj.byteOffset, obj.byteLength / Uint8Array.BYTES_PER_ELEMENT);
      const value = Buffer.from(arr).toString('hex');
      return { __type: 'Buffer', value };
    }
    if (obj instanceof Error) {
      return {
        __type: 'Error',
        value: serializeError(obj)
      };
    }
    if (obj instanceof Date) {
      return {
        __type: 'Date',
        value: obj.getTime()
      };
    }
    if (obj instanceof Map) {
      return {
        __type: 'Map',
        value: [...obj.entries()].map(([key, value]) => [
          toSerializableObject(key, options),
          toSerializableObject(value, options)
        ])
      };
    }
    const transformKey = options?.serializeKey || defaultTransformKey;
    return transform(
      obj,
      (result, value, key) => {
        result[transformKey(key)] = toSerializableObject(value, options);
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

const fromSerializableObjectUnknown = (obj: unknown, options?: FromSerializableObjectOptions): unknown => {
  if (PLAIN_TYPES.has(typeof obj)) return obj;
  if (typeof obj === 'object') {
    if (obj === null) return null;
    if (Array.isArray(obj)) {
      return obj.map((item) => fromSerializableObjectUnknown(item, options));
    }
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const docAsAny = obj as any;
    if (docAsAny.__type === 'undefined') return undefined;
    if (docAsAny.__type === 'bigint') return BigInt(docAsAny.value);
    if (docAsAny.__type === 'Buffer') return Buffer.from(docAsAny.value, 'hex');
    if (docAsAny.__type === 'Date') return new Date(docAsAny.value);
    if (docAsAny.__type === 'Map')
      return new Map(
        docAsAny.value.map((keyValues: unknown[]) => keyValues.map((kv) => fromSerializableObjectUnknown(kv, options)))
      );
    if (docAsAny.__type === 'Error') {
      const error = fromSerializableObjectUnknown(docAsAny.value, options);
      const getErrorPrototype = options?.getErrorPrototype || defaultGetErrorPrototype;
      return Object.setPrototypeOf(error, getErrorPrototype(error));
    }
    const transformKey = options?.deserializeKey || defaultTransformKey;
    return transform(
      obj,
      (result, value, key) => {
        result[transformKey(key)] = fromSerializableObjectUnknown(value, options);
        return result;
      },
      {} as Record<string | number | symbol, unknown>
    );
  }
};

export const fromSerializableObject = <T>(serializableObject: unknown, options?: FromSerializableObjectOptions) =>
  fromSerializableObjectUnknown(serializableObject, options) as T;
