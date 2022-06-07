import {
  FromSerializableObjectOptions,
  ToSerializableObjectOptions,
  fromSerializableObject,
  toSerializableObject
} from '@cardano-sdk/util';
import omit from 'lodash/omit';

const PouchdbDocMetadata = ['_id', '_rev', '_attachments', '_conflicts', '_revisions', '_revs_info'] as const;
type PouchdbDocMetadata = typeof PouchdbDocMetadata[number];
type PouchdbDoc = {
  [k in PouchdbDocMetadata]: unknown;
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

// Pouchdb doesn't know how to store bigint and Map
// toPouchdbDoc/fromPouchdbDoc converts to/from plain json objects
export const toPouchdbDoc = <T>(obj: T): unknown => {
  if (Array.isArray(obj)) {
    const value = obj.map((item) => toSerializableObject(item, serializeOptions));
    return {
      [transformationTypeKey]: 'Array',
      value
    };
  }
  return toSerializableObject(obj, serializeOptions);
};

export const fromPouchdbDoc = <T>(doc: unknown): T => {
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
// Would be great to have generic constraints on pouchdb stores, to say "not extends {_id, _rev...}".
// Don't think it's possible.
export const sanitizePouchdbDoc = <T>(doc: T & Partial<PouchdbDoc>): T =>
  fromPouchdbDoc(omit(doc, PouchdbDocMetadata)) as T;
