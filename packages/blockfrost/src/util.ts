/* eslint-disable @typescript-eslint/no-explicit-any */
import { Error as BlockfrostError } from '@blockfrost/blockfrost-js';
import { InvalidStringError, ProviderError, ProviderFailure } from '@cardano-sdk/core';
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

/**
 * Recursively replaces all numbers with bigints.
 */
export const replaceNumbersWithBigints = (obj: unknown): unknown => {
  if (typeof obj === 'number') return BigInt(obj);
  if (typeof obj !== 'object' || obj === null) return obj;
  if (Array.isArray(obj)) {
    return obj.map(replaceNumbersWithBigints);
  }
  const newObj: any = {};
  for (const k in obj) {
    newObj[k] = replaceNumbersWithBigints((obj as any)[k]);
  }
  return newObj;
};
