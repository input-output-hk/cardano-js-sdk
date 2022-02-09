import { JsonSerializer } from 'graphql-request/dist/types.dom';
import JSONbig from 'json-bigint';

export const jsonSerializer: JsonSerializer = JSONbig({ useNativeBigInt: true });
