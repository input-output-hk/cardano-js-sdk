import { ProviderError, ProviderFailure } from '@cardano-sdk/core';
import type { PaginationOptions } from '@blockfrost/blockfrost-js/lib/types';

const isNotFoundError = (error: unknown) => error instanceof ProviderError && error.reason === ProviderFailure.NotFound;

// copied from @cardano-sdk/cardano-services and updated to use custom blockfrost client instead of blockfrost-js
export const fetchSequentially = async <Item, Arg, Response>(
  props: {
    request: (queryString: string) => Promise<Response[]>;
    responseTranslator?: (response: Response[]) => Item[];
    /**
     * @returns true to indicatate that current result set should be returned
     */
    haveEnoughItems?: (items: Item[]) => boolean;
    paginationOptions?: PaginationOptions;
  },
  page = 1,
  accumulated: Item[] = []
): Promise<Item[]> => {
  const count = props.paginationOptions?.count || 100;
  const order = props.paginationOptions?.order || 'asc';
  try {
    const response = await props.request(`count=${count}&page=${page}&order=${order}`);
    const maybeTranslatedResponse = props.responseTranslator ? props.responseTranslator(response) : response;
    const newAccumulatedItems = [...accumulated, ...maybeTranslatedResponse] as Item[];
    const haveEnoughItems = props.haveEnoughItems?.(newAccumulatedItems);
    if (response.length === count && !haveEnoughItems) {
      return fetchSequentially<Item, Arg, Response>(props, page + 1, newAccumulatedItems);
    }
    return newAccumulatedItems;
  } catch (error) {
    if (isNotFoundError(error)) {
      return [];
    }
    throw error;
  }
};
