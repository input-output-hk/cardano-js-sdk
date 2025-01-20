import { Cardano, ProviderError, ProviderFailure, ProviderUtil } from '@cardano-sdk/core';
import type { PaginationOptions } from '@blockfrost/blockfrost-js/lib/types';

import { BlockfrostError } from './BlockfrostClient';

export const isBlockfrostNotFoundError = (error: unknown) =>
  (error instanceof BlockfrostError && error.status === 404) ||
  (error instanceof ProviderError && error.reason === ProviderFailure.NotFound);

const buildQueryString = ({ page, count, order }: PaginationOptions) => {
  let queryString = '';
  const appendIfDefined = (value: unknown, param: string) => {
    if (typeof value !== 'undefined') {
      queryString += queryString ? `&${param}` : param;
    }
  };

  appendIfDefined(page, `page=${page}`);
  appendIfDefined(count, `count=${count}`);
  appendIfDefined(order, `order=${order}`);
  return queryString;
};

// copied from @cardano-sdk/cardano-services and updated to use custom blockfrost client instead of blockfrost-js
export const fetchSequentially = async <Response, Item = Response>(
  props: {
    request: (paginationQueryString: string) => Promise<Response[]>;
    responseTranslator?: (response: Response[]) => Item[];
    /**
     * @returns true to indicatate that current result set should be returned
     */
    haveEnoughItems?: (allItems: Item[], lastResponseBatch: Response[]) => boolean;
    paginationOptions?: PaginationOptions;
  },
  page = 1,
  accumulated: Item[] = []
): Promise<Item[]> => {
  const count = props.paginationOptions?.count || 100;
  try {
    const response = await props.request(buildQueryString({ count, order: props.paginationOptions?.order, page }));
    const maybeTranslatedResponse = props.responseTranslator ? props.responseTranslator(response) : response;
    const newAccumulatedItems = [...accumulated, ...maybeTranslatedResponse] as Item[];
    const haveEnoughItems = props.haveEnoughItems?.(newAccumulatedItems, response);
    if (response.length === count && !haveEnoughItems) {
      return fetchSequentially<Response, Item>(props, page + 1, newAccumulatedItems);
    }
    return newAccumulatedItems;
  } catch (error) {
    if (isBlockfrostNotFoundError(error)) {
      return [];
    }
    throw error;
  }
};

/**
 * Maps txs metadata from blockfrost into to a TxMetadata
 *
 * @returns {Cardano.TxMetadata} map with bigint as key and Metadatum as value
 */
export const blockfrostMetadataToTxMetadata = (
  metadata: {
    label: string;
    json_metadata: unknown;
  }[]
): Cardano.TxMetadata =>
  metadata.reduce((map, metadatum) => {
    const { json_metadata, label } = metadatum;
    if (!json_metadata || !label) return map;
    map.set(BigInt(label), ProviderUtil.jsonToMetadatum(json_metadata));
    return map;
  }, new Map<bigint, Cardano.Metadatum>());
