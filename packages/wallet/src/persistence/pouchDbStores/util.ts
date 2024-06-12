import {
  FromSerializableObjectOptions,
  ToSerializableObjectOptions,
  fromSerializableObject,
  toSerializableObject
} from '@cardano-sdk/util';
import omit from 'lodash/omit.js';

const PouchDbDocMetadata = ['_id', '_rev', '_attachments', '_conflicts', '_revisions', '_revs_info'] as const;
type PouchDbDocMetadata = typeof PouchDbDocMetadata[number];
type PouchDbDoc = {
  [k in PouchDbDocMetadata]: unknown;
};

const transformationTypeKey = 'transformed_type_';
const TRANSFORMED_KEY_PREFIX = 'transformed_key_';

const serializeOptions: ToSerializableObjectOptions = {
  serializeKey: (key) => {
    if (key.startsWith('_')) {
      return `${TRANSFORMED_KEY_PREFIX}${key}`;
    }
    return key;
  },
  transformationTypeKey
};
const deserializeOptions: FromSerializableObjectOptions = {
  deserializeKey: (key) => {
    if (key.startsWith(TRANSFORMED_KEY_PREFIX)) {
      return key.slice(TRANSFORMED_KEY_PREFIX.length);
    }
    return key;
  },
  transformationTypeKey
};

// PouchDb doesn't know how to store bigint and Map
// toPouchDbDoc/fromPouchDbDoc converts to/from plain json objects
export const toPouchDbDoc = <T>(obj: T): unknown => {
  if (Array.isArray(obj)) {
    const value = obj.map((item) => toSerializableObject(item, serializeOptions));
    return {
      [transformationTypeKey]: 'Array',
      value
    };
  }
  return toSerializableObject(obj, serializeOptions);
};

export const fromPouchDbDoc = <T>(doc: unknown): T => {
  if (typeof doc === 'object') {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const docAsAny = doc as any;
    if (docAsAny[transformationTypeKey] === 'Array')
      return docAsAny.value.map((val: unknown) => fromSerializableObject(val, deserializeOptions));
  }
  return fromSerializableObject(doc, deserializeOptions);
};

// PouchDB adds some metadata on docs when you query them.
// Best to keep the objects used by the wallet clean.
// Would be great to have generic constraints on PouchDb stores, to say "not extends {_id, _rev...}".
// Don't think it's possible.
export const sanitizePouchDbDoc = <T>(doc: T & Partial<PouchDbDoc>): T =>
  fromPouchDbDoc(omit(doc, PouchDbDocMetadata)) as T;
