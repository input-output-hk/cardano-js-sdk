import { BlockFrostAPI, Error as BlockfrostError } from '@blockfrost/blockfrost-js';
import {
  Cardano,
  // eslint-disable-next-line @typescript-eslint/ban-ts-comment
  // @ts-ignore
  HealthCheckResponse,
  InvalidStringError,
  NetworkInfoProvider,
  Provider,
  ProviderError,
  ProviderFailure,
  ProviderUtil,
  testnetEraSummaries
} from '@cardano-sdk/core';
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
    if (formatBlockfrostError(error).status_code === 404) {
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
  address: Cardano.Address;
  request: (address: Cardano.Address, pagination: PaginationOptions) => Promise<Response[]>;
  responseTranslator?: (address: Cardano.Address, response: Response[]) => Item[];
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
  [Cardano.CardanoNetworkMagic.Mainnet]: Cardano.NetworkId.mainnet,
  [Cardano.CardanoNetworkMagic.Testnet]: Cardano.NetworkId.testnet
};

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
