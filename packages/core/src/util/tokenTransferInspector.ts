/* eslint-disable promise/param-names */
import { Inspector, ResolutionResult, resolveInputs } from './txInspector';
import { TimeoutError } from '../errors';
import { coalesceValueQuantities } from './coalesceValueQuantities';
import { promiseTimeout } from './promiseTimeout';
import { subtractValueQuantities } from './subtractValueQuantities';
import { tryGetAssetInfos } from './tryGetAssetInfos';
import uniq from 'lodash/uniq.js';
import type * as Cardano from '../Cardano';
import type { AssetInfo } from '../Asset';
import type { AssetProvider } from '../Provider';
import type { Logger } from 'ts-log';
import type { Milliseconds } from './time';

export type AssetInfoWithAmount = { amount: Cardano.Lovelace; assetInfo: AssetInfo };

export type TokenTransferValue = {
  assets: Map<Cardano.AssetId, AssetInfoWithAmount>;
  coins: Cardano.Lovelace;
};

export type TokenTransferInspection = {
  fromAddress: Map<Cardano.PaymentAddress, TokenTransferValue>;
  toAddress: Map<Cardano.PaymentAddress, TokenTransferValue>;
};

/** Arguments for the token transfer inspector. */
export interface TokenTransferInspectorArgs {
  /** The input resolver. */
  inputResolver: Cardano.InputResolver;

  /** The asset provider to resolve AssetInfo for assets in the fromAddress field. */
  fromAddressAssetProvider: AssetProvider;

  /** The asset provider to resolve AssetInfo for assets in the toAddress field. */
  toAddressAssetProvider: AssetProvider;

  /** Timeout provided by the app that consumes the inspector to personalise the UI response */
  timeout: Milliseconds;

  /** logger */
  logger: Logger;
}

export type TokenTransferInspector = (args: TokenTransferInspectorArgs) => Inspector<TokenTransferInspection>;

type IntoTokenTransferValueProps = {
  addressMap: Map<Cardano.PaymentAddress, Cardano.Value>;
  assetProvider: AssetProvider;
  timeout: Milliseconds;
  logger: Logger;
};

const coalesceByAddress = <T extends { address: Cardano.PaymentAddress; value: Cardano.Value }>(
  elements: T[]
): Map<Cardano.PaymentAddress, Cardano.Value> => {
  const grouped = elements.reduce((acc, elem) => {
    if (!acc.has(elem.address)) acc.set(elem.address, []);
    acc.get(elem.address)?.push(elem);
    return acc;
  }, new Map<Cardano.PaymentAddress, T[]>());

  const coalescedByAddress = new Map<Cardano.PaymentAddress, Cardano.Value>();

  for (const [address, elem] of grouped) {
    coalescedByAddress.set(address, coalesceValueQuantities(elem.map((x) => x.value)));
  }

  return coalescedByAddress;
};

const initializeAddressMap = (addresses: Cardano.PaymentAddress[]): Map<Cardano.PaymentAddress, Cardano.Value> =>
  new Map<Cardano.PaymentAddress, Cardano.Value>(
    addresses.map((address) => [address, { assets: new Map(), coins: 0n }])
  );

const updateFromAddressMap = (
  addressMap: Map<Cardano.PaymentAddress, Cardano.Value>,
  key: Cardano.PaymentAddress,
  value: Cardano.Value
) => {
  if (value.coins < 0n) {
    addressMap.get(key)!.coins = value.coins;
  }

  for (const [assetId, quantity] of value.assets?.entries() ?? [])
    if (quantity < 0n) {
      addressMap.get(key)!.assets?.set(assetId, quantity);
    }
};

const updateToAddressMap = (
  addressMap: Map<Cardano.PaymentAddress, Cardano.Value>,
  key: Cardano.PaymentAddress,
  value: Cardano.Value
) => {
  if (value.coins > 0n) {
    addressMap.get(key)!.coins = value.coins;
  }

  for (const [assetId, quantity] of value.assets?.entries() ?? []) {
    if (quantity > 0n) {
      addressMap.get(key)!.assets?.set(assetId, quantity);
    }
  }
};

const computeNetDifferences = (
  inputs: Map<Cardano.PaymentAddress, Cardano.Value>,
  outputs: Map<Cardano.PaymentAddress, Cardano.Value>,
  fromAddress: Map<Cardano.PaymentAddress, Cardano.Value>,
  toAddress: Map<Cardano.PaymentAddress, Cardano.Value>
) => {
  for (const [key, inputValue] of inputs.entries()) {
    const outputValue = outputs.get(key) ?? { assets: new Map(), coins: 0n };
    const difference = subtractValueQuantities([outputValue, inputValue]);

    updateFromAddressMap(fromAddress, key, difference);
    updateToAddressMap(toAddress, key, difference);
  }

  // Process keys that are only in the output map
  for (const [key, outputValue] of outputs.entries()) {
    if (!inputs.has(key)) {
      updateToAddressMap(toAddress, key, outputValue);
    }
  }
};

const removeZeroBalanceEntries = (addressMap: Map<Cardano.PaymentAddress, Cardano.Value>) => {
  for (const [key, value] of addressMap.entries()) {
    if (value.coins === 0n && value.assets?.size === 0) {
      addressMap.delete(key);
    }
  }
};

const intoTokenTransferValue = async ({
  logger,
  assetProvider,
  timeout,
  addressMap
}: IntoTokenTransferValueProps): Promise<Map<Cardano.PaymentAddress, TokenTransferValue>> => {
  const tokenTransferValue = new Map<Cardano.PaymentAddress, TokenTransferValue>();

  for (const [address, value] of addressMap.entries()) {
    const coins = value.coins;
    const assetIds = uniq(value.assets && value.assets.size > 0 ? [...value.assets.keys()] : []);
    const assetInfos = new Map<Cardano.AssetId, AssetInfoWithAmount>();

    if (assetIds.length > 0) {
      const assets = await tryGetAssetInfos({
        assetIds,
        assetProvider,
        logger,
        timeout
      });

      for (const asset of assets) {
        const amount = value.assets?.get(asset.assetId) ?? 0n;
        assetInfos.set(asset.assetId, { amount, assetInfo: asset });
      }
    }

    tokenTransferValue.set(address, {
      assets: assetInfos,
      coins
    });
  }

  return tokenTransferValue;
};

/** Inspect a transaction and return a map of addresses and their balances. */
export const tokenTransferInspector: TokenTransferInspector =
  ({ inputResolver, fromAddressAssetProvider, toAddressAssetProvider, timeout, logger }) =>
  async (tx) => {
    let resolvedInputs: ResolutionResult['resolvedInputs'];

    try {
      const inputResolution = await promiseTimeout(resolveInputs(tx.body.inputs, inputResolver), timeout);
      resolvedInputs = inputResolution.resolvedInputs;
    } catch (error) {
      if (error instanceof TimeoutError) {
        logger.error('Error: Inputs resolution timed out');
      }

      resolvedInputs = [];
    }

    const coalescedInputsByAddress = coalesceByAddress(resolvedInputs);
    const coalescedOutputsByAddress = coalesceByAddress(tx.body.outputs);

    const addresses = uniq([...coalescedInputsByAddress.keys(), ...coalescedOutputsByAddress.keys()]);

    const fromAddress = initializeAddressMap(addresses);
    const toAddress = initializeAddressMap(addresses);

    computeNetDifferences(coalescedInputsByAddress, coalescedOutputsByAddress, fromAddress, toAddress);

    removeZeroBalanceEntries(fromAddress);
    removeZeroBalanceEntries(toAddress);

    return {
      fromAddress: await intoTokenTransferValue({
        addressMap: fromAddress,
        assetProvider: fromAddressAssetProvider,
        logger,
        timeout
      }),
      toAddress: await intoTokenTransferValue({
        addressMap: toAddress,
        assetProvider: toAddressAssetProvider,
        logger,
        timeout
      })
    };
  };
