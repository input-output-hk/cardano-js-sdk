import { BlockfrostClientError, isBlockfrostErrorResponse } from '@blockfrost/blockfrost-js/lib/utils/errors';
import { BlockfrostServerError } from '@blockfrost/blockfrost-js';
import {
  Cardano,
  EraSummary,
  Milliseconds,
  ProviderError,
  ProviderFailure,
  ProviderUtil,
  statusCodeMapToProviderFailure
} from '@cardano-sdk/core';
import { PaginationOptions } from '@blockfrost/blockfrost-js/lib/types';

export const isBlockfrostNotFoundError = (error: unknown) =>
  (error instanceof BlockfrostServerError || isBlockfrostErrorResponse(error)) && error.status_code === 404;

export const blockfrostToProviderError = (error: BlockfrostServerError | BlockfrostClientError | unknown) => {
  if (
    (error instanceof BlockfrostServerError || isBlockfrostErrorResponse(error)) &&
    statusCodeMapToProviderFailure.has(error.status_code)
  )
    return new ProviderError(statusCodeMapToProviderFailure.get(error.status_code)!, error, `${error.message}`);
  else if (
    isBlockfrostErrorResponse(error) ||
    error instanceof BlockfrostClientError ||
    error instanceof BlockfrostServerError
  )
    return new ProviderError(ProviderFailure.Unknown, error, `${error.message}`);
  else if (error instanceof ProviderError) {
    return error;
  }

  return new ProviderError(ProviderFailure.Unknown, error);
};

export const fetchSequentially = async <Item, Arg, Response>(
  props: {
    arg: Arg;
    request: (arg: Arg, pagination: PaginationOptions) => Promise<Response[]>;
    responseTranslator?: (response: Response[], arg: Arg) => Item[];
    /**
     * @returns true to indicatate that current result set should be returned
     */
    haveEnoughItems?: (items: Item[]) => boolean;
    paginationOptions?: PaginationOptions;
  },
  page = 1,
  accumulated: Item[] = []
): Promise<Item[]> => {
  props.paginationOptions = props.paginationOptions || { count: 100 };
  try {
    const response = await props.request(props.arg, { ...props.paginationOptions, page });
    const maybeTranslatedResponse = props.responseTranslator ? props.responseTranslator(response, props.arg) : response;
    const newAccumulatedItems = [...accumulated, ...maybeTranslatedResponse] as Item[];
    const haveEnoughItems = props.haveEnoughItems?.(newAccumulatedItems);
    if (response.length === props.paginationOptions.count && !haveEnoughItems) {
      return fetchSequentially<Item, Arg, Response>(props, page + 1, newAccumulatedItems);
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

export const fetchByAddressSequentially = async <Item, Response>(props: {
  address: Cardano.PaymentAddress;
  request: (address: Cardano.PaymentAddress, pagination: PaginationOptions) => Promise<Response[]>;
  responseTranslator?: (address: Cardano.PaymentAddress, response: Response[]) => Item[];
  /**
   * @returns true to indicatate that current result set should be returned
   */
  haveEnoughItems?: (items: Item[]) => boolean;
  paginationOptions?: PaginationOptions;
}): Promise<Item[]> =>
  fetchSequentially({
    arg: props.address,
    haveEnoughItems: props.haveEnoughItems,
    paginationOptions: props.paginationOptions,
    request: props.request,
    responseTranslator: props.responseTranslator
      ? (response, arg) => props.responseTranslator!(arg, response)
      : undefined
  });

export const networkMagicToIdMap: { [key in number]: Cardano.NetworkId } = {
  [Cardano.NetworkMagics.Mainnet]: Cardano.NetworkId.Mainnet,
  [Cardano.NetworkMagics.Preprod]: Cardano.NetworkId.Testnet
};

// copied from util-dev
export const testnetEraSummaries: EraSummary[] = [
  {
    parameters: { epochLength: 21_600, slotLength: Milliseconds(20_000) },
    start: { slot: 0, time: new Date(1_563_999_616_000) }
  },
  {
    parameters: { epochLength: 432_000, slotLength: Milliseconds(1000) },
    start: { slot: 1_598_400, time: new Date(1_595_967_616_000) }
  }
];
