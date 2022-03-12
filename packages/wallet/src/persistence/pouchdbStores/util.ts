import { omit } from 'lodash-es';

const PouchdbDocMetadata = ['_id', '_rev', '_attachments', '_conflicts', '_revisions', '_revs_info'] as const;
type PouchdbDocMetadata = typeof PouchdbDocMetadata[number];
type PouchdbDoc = {
  [k in PouchdbDocMetadata]: unknown;
};

// PouchDB adds some metadata on docs when you query them.
// Best to keep the objects used by the wallet clean.
// Would be great to have generic constraints on pouchdb stores, to say "not extends {_id, _rev...}".
// Don't think it's possible.
export const sanitizePouchdbDoc = <T>(doc: T & Partial<PouchdbDoc>): T => omit(doc, PouchdbDocMetadata) as T;
