/**
 * A hex-encoded string of the corresponding bytes.
 */
export type Bytes = string;

/**
 * A hex-encoded string representing CBOR either inside
 * of the Shelley Multi-asset binary spec or, if not present there,
 * from the CIP-0008 signing spec.
 */
export type Cbor = string;

/**
 *  Used to specify optional pagination for some API calls.
Limits results to {limit} each page, and uses a 0-indexing {page}
to refer to which of those pages of {limit} items each.
 */
export type Paginate = { page: number; limit: number };
