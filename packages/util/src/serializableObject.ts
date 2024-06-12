/* eslint-disable complexity */
/* eslint-disable sonarjs/cognitive-complexity */
import { serializeError } from 'serialize-error';
import transform from 'lodash/transform.js';

const PLAIN_TYPES = new Set(['boolean', 'number', 'string']);

export type TransformKey = (key: string) => string;

export interface ToSerializableObjectOptions {
  transformationTypeKey?: string;
  serializeKey?: TransformKey;
}

export interface ClassOf<T> extends Function {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  new (...args: any[]): T;
}
export type ErrorClass = ClassOf<Error>;

export interface FromSerializableObjectOptions {
  transformationTypeKey?: string;
  deserializeKey?: TransformKey;
  errorTypes?: ErrorClass[];
}

const matchPrototype = (errorTypes: ErrorClass[], error: unknown) => {
  if (typeof error === 'object' && error !== null) {
    for (let ErrorType of errorTypes) {
      if ((error as Error).name === ErrorType.name) {
        return ErrorType.prototype;
      }
      ErrorType = Object.getPrototypeOf(ErrorType.prototype)?.constructor;
    }
  }
  return Error.prototype;
};
const defaultTransformKey: TransformKey = (key) => key;
const defaultTransformationTypeKey = '__type';

const hasInnerError = (error: unknown): error is { innerError: unknown } =>
  error !== null && typeof error === 'object' && 'innerError' in (error as never);

const innerErrorHasData = (innerError: unknown): innerError is { data: unknown } =>
  typeof innerError === 'object' && innerError !== null && 'data' in innerError;

export const toSerializableObject = (obj: unknown, options: ToSerializableObjectOptions = {}): unknown => {
  if (PLAIN_TYPES.has(typeof obj)) return obj;
  const { transformationTypeKey = defaultTransformationTypeKey, serializeKey = defaultTransformKey } = options;
  if (typeof obj === 'undefined') {
    return {
      [transformationTypeKey]: 'undefined'
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
      return { [transformationTypeKey]: 'Buffer', value };
    }

    if (obj instanceof Error) {
      if (hasInnerError(obj) && innerErrorHasData(obj.innerError)) {
        obj.innerError.data = toSerializableObject(obj.innerError.data);
      }
      return {
        [transformationTypeKey]: 'Error',
        value: serializeError(obj)
      };
    }
    if (obj instanceof Date) {
      return {
        [transformationTypeKey]: 'Date',
        value: obj.getTime()
      };
    }
    if (obj instanceof Set) {
      return {
        [transformationTypeKey]: 'Set',
        value: [...obj].map((item) => toSerializableObject(item, options))
      };
    }
    if (obj instanceof Map) {
      return {
        [transformationTypeKey]: 'Map',
        value: [...obj.entries()].map(([key, value]) => [
          toSerializableObject(key, options),
          toSerializableObject(value, options)
        ])
      };
    }
    return transform(
      obj,
      (result, value, key) => {
        result[serializeKey(key)] = toSerializableObject(value, options);
        return result;
      },
      {} as Record<string | number | symbol, unknown>
    );
  }
  if (typeof obj === 'bigint')
    return {
      [transformationTypeKey]: 'bigint',
      value: obj.toString()
    };
};

const fromSerializableObjectUnknown = (obj: unknown, options: FromSerializableObjectOptions = {}): unknown => {
  if (PLAIN_TYPES.has(typeof obj)) return obj;
  if (typeof obj === 'object') {
    if (obj === null) return null;
    if (Array.isArray(obj)) {
      return obj.map((item) => fromSerializableObjectUnknown(item, options));
    }
    const {
      transformationTypeKey = defaultTransformationTypeKey,
      deserializeKey = defaultTransformKey,
      errorTypes = []
    } = options;
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const docAsAny = obj as any;
    switch (docAsAny[transformationTypeKey]) {
      case 'undefined':
        return undefined;
      case 'bigint':
        return BigInt(docAsAny.value);
      case 'Buffer':
        return new Uint8Array(Buffer.from(docAsAny.value, 'hex'));
      case 'Date':
        return new Date(docAsAny.value);
      case 'Set':
        return new Set(docAsAny.value.map((item: unknown) => fromSerializableObjectUnknown(item, options)));
      case 'Map':
        return new Map(
          docAsAny.value.map((keyValues: unknown[]) =>
            keyValues.map((kv) => fromSerializableObjectUnknown(kv, options))
          )
        );
      case 'Error': {
        const error = fromSerializableObjectUnknown(docAsAny.value, options);
        return Object.setPrototypeOf(error, matchPrototype(errorTypes, error));
      }
      default:
        return transform(
          obj,
          (result, value, key) => {
            result[deserializeKey(key)] = fromSerializableObjectUnknown(value, options);
            return result;
          },
          {} as Record<string | number | symbol, unknown>
        );
    }
  }
};

export const fromSerializableObject = <T>(serializableObject: unknown, options?: FromSerializableObjectOptions) =>
  fromSerializableObjectUnknown(serializableObject, options) as T;
