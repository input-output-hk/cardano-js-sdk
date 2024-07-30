import { BlockFrostAPI, BlockfrostServerError } from '@blockfrost/blockfrost-js';
import {
  Cardano,
  EraSummary,
  Milliseconds,
  NetworkInfoProvider,
  Provider,
  ProviderError,
  ProviderFailure,
  ProviderUtil
} from '@cardano-sdk/core';
import { PaginationOptions } from '@blockfrost/blockfrost-js/lib/types';
import { handleError, isBlockfrostErrorResponse } from '@blockfrost/blockfrost-js/lib/utils/errors';

export const formatBlockfrostError = (error: unknown) => handleError(error);

export const isBlockfrostNotFoundError = (error: unknown) =>
  (error instanceof BlockfrostServerError || isBlockfrostErrorResponse(error)) && error.status_code === 404;

export const toProviderError = (error: unknown) => {
  if (isBlockfrostNotFoundError(error)) {
    throw new ProviderError(ProviderFailure.NotFound);
  }

  const blockfrostError = formatBlockfrostError(error);
  throw new ProviderError(ProviderFailure.Unknown, error, `${blockfrostError.message}`);
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

export const eraSummaries: NetworkInfoProvider['eraSummaries'] = async () => testnetEraSummaries;

/**
 * Check health of the [Blockfrost service](https://docs.blockfrost.io/)
 *
 * @param {BlockFrostAPI} blockfrost BlockFrostAPI instance
 * @returns {HealthCheckResponse} HealthCheckResponse
 * @throws {ProviderError}
 */
export const healthCheck = async (blockfrost: BlockFrostAPI): ReturnType<Provider['healthCheck']> => {
  try {
    const result = await blockfrost.health();
    return { ok: result.is_healthy };
  } catch (error) {
    throw new ProviderError(ProviderFailure.Unknown, error);
  }
};
let blockfrostApi: BlockFrostAPI;

/**
 * Gets the singleton blockfrost API instance.
 *
 * @returns The blockfrost API instance, this function always returns the same instance.
 */
export const getBlockfrostApi = async () => {
  if (blockfrostApi !== undefined) return blockfrostApi;

  if (process.env.BLOCKFROST_API_KEY === undefined)
    throw new Error('BLOCKFROST_API_KEY environment variable is required');

  return new BlockFrostAPI({ network: 'preprod', projectId: process.env.BLOCKFROST_API_KEY });
};
