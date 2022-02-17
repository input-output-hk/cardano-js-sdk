/* eslint-disable @typescript-eslint/no-explicit-any */
import { Error as BlockfrostError } from '@blockfrost/blockfrost-js';
import { Cardano, InvalidStringError, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { PaginationOptions } from '@blockfrost/blockfrost-js/lib/types';

export const formatBlockfrostError = (error: unknown) => {
  const blockfrostError = error as BlockfrostError;
  if (typeof blockfrostError === 'string') {
    throw new ProviderError(ProviderFailure.Unknown, error, blockfrostError);
  }
  if (typeof blockfrostError !== 'object') {
    throw new ProviderError(ProviderFailure.Unknown, error, 'failed to parse error (response type)');
  }
  if (error instanceof InvalidStringError) {
    throw new ProviderError(ProviderFailure.InvalidResponse, error);
  }
  const errorAsType1 = blockfrostError as {
    status_code: number;
    message: string;
    error: string;
  };
  if (errorAsType1.status_code) {
    return errorAsType1;
  }
  const errorAsType2 = blockfrostError as {
    errno: number;
    message: string;
    code: string;
  };
  if (errorAsType2.code) {
    const status_code = Number.parseInt(errorAsType2.code);
    if (!status_code) {
      throw new ProviderError(ProviderFailure.Unknown, error, 'failed to parse error (status code)');
    }
    return {
      error: errorAsType2.errno.toString(),
      message: errorAsType1.message,
      status_code
    };
  }
  throw new ProviderError(ProviderFailure.Unknown, error, 'failed to parse error (response json)');
};

export const toProviderError = (error: unknown) => {
  const { status_code } = formatBlockfrostError(error);
  if (status_code === 404) {
    throw new ProviderError(ProviderFailure.NotFound);
  }
  throw new ProviderError(ProviderFailure.Unknown, error, `status_code: ${status_code}`);
};

export const fetchSequentially = async <Item, Arg, Response>(
  props: {
    arg: Arg;
    request: (arg: Arg, pagination: PaginationOptions) => Promise<Response[]>;
    responseTranslator?: (response: Response[], arg: Arg) => Item[];
  },
  itemsPerPage = 100,
  page = 1,
  accumulated: Item[] = []
): Promise<Item[]> => {
  try {
    const response = await props.request(props.arg, { count: itemsPerPage, page });
    const maybeTranslatedResponse = props.responseTranslator ? props.responseTranslator(response, props.arg) : response;
    const newAccumulatedItems = [...accumulated, ...maybeTranslatedResponse] as Item[];
    if (response.length === itemsPerPage) {
      return fetchSequentially<Item, Arg, Response>(props, itemsPerPage, page + 1, newAccumulatedItems);
    }
    return newAccumulatedItems;
  } catch (error) {
    if (formatBlockfrostError(error).status_code === 404) {
      return [];
    }
    throw error;
  }
};

const tryParseBigIntKey = (key: string) => {
  try {
    return BigInt(key);
  } catch {
    return key;
  }
};

/**
 * Recursively maps blockfrost JSON metadata to core metadata.
 * As JSON doesn't support numeric keys,
 * this function assumes that all metadata (and metadatum map) keys parseable by BigInt.parse are numeric.
 */
export const jsonToMetadatum = (obj: unknown): Cardano.Metadatum => {
  switch (typeof obj) {
    case 'number':
      return BigInt(obj);
    case 'string':
    case 'bigint':
      return obj;
    case 'object': {
      if (obj === null) break;
      if (Array.isArray(obj)) {
        return obj.map(jsonToMetadatum);
      }
      return new Map(Object.keys(obj).map((key) => [tryParseBigIntKey(key), jsonToMetadatum((obj as any)[key])]));
    }
  }
  throw new ProviderError(ProviderFailure.NotImplemented, null, `Unsupported metadatum type: ${typeof obj}`);
};
