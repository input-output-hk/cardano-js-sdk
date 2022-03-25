import { omit, transform } from 'lodash-es';

const PouchdbDocMetadata = ['_id', '_rev', '_attachments', '_conflicts', '_revisions', '_revs_info'] as const;
type PouchdbDocMetadata = typeof PouchdbDocMetadata[number];
type PouchdbDoc = {
  [k in PouchdbDocMetadata]: unknown;
};

const PLAIN_TYPES = new Set(['boolean', 'number', 'string']);

// Pouchdb doesn't know how to store bigint and Map
// toPouchdbDoc/fromPouchdbDoc converts to/from plain json objects
export const toPouchdbDoc = (obj: unknown, isNestedObj: boolean): unknown => {
  if (PLAIN_TYPES.has(typeof obj)) return obj;
  if (typeof obj === 'undefined') {
    return {
      __type: 'undefined'
    };
  }
  if (typeof obj === 'object') {
    if (obj === null) return null;
    if (Array.isArray(obj)) {
      const value = obj.map((item) => toPouchdbDoc(item, true));
      if (isNestedObj) {
        return value;
      }
      return {
        __type: 'Array',
        value
      };
    }
    if (obj instanceof Map) {
      return {
        __type: 'Map',
        value: [...obj.entries()].map(([key, value]) => [toPouchdbDoc(key, true), toPouchdbDoc(value, true)])
      };
    }
    return transform(
      obj,
      (result, value, key) => {
        result[key] = toPouchdbDoc(value, true);
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

export const fromPouchdbDoc = (doc: unknown): unknown => {
  if (PLAIN_TYPES.has(typeof doc)) return doc;
  if (typeof doc === 'object') {
    if (doc === null) return null;
    if (Array.isArray(doc)) {
      return doc.map(fromPouchdbDoc);
    }
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const docAsAny = doc as any;
    if (docAsAny.__type === 'undefined') return undefined;
    if (docAsAny.__type === 'bigint') return BigInt(docAsAny.value);
    if (docAsAny.__type === 'Array') return docAsAny.value.map(fromPouchdbDoc);
    if (docAsAny.__type === 'Map')
      return new Map(docAsAny.value.map((keyValues: unknown[]) => keyValues.map(fromPouchdbDoc)));
    return transform(
      doc,
      (result, value, key) => {
        result[key] = fromPouchdbDoc(value);
        return result;
      },
      {} as Record<string | number | symbol, unknown>
    );
  }
};

// PouchDB adds some metadata on docs when you query them.
// Best to keep the objects used by the wallet clean.
// Would be great to have generic constraints on pouchdb stores, to say "not extends {_id, _rev...}".
// Don't think it's possible.
export const sanitizePouchdbDoc = <T>(doc: T & Partial<PouchdbDoc>): T =>
  fromPouchdbDoc(omit(doc, PouchdbDocMetadata)) as T;
