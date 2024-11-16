// this file contains utils that were copied from @blockfrost/blockfrost-js in order to avoid adding it to "dependencies"
import type { ErrorType } from '@blockfrost/blockfrost-js/lib/types';

const hasProp = <K extends PropertyKey>(data: object, prop: K): data is Record<K, unknown> => prop in data;

export const isBlockfrostErrorResponse = (data: unknown): data is Extract<ErrorType, { status_code: number }> =>
  // type guard for narrowing response body to an error object that should be returned by Blockfrost API
  typeof data === 'object' &&
  data !== null &&
  hasProp(data, 'status_code') &&
  hasProp(data, 'message') &&
  hasProp(data, 'error');
