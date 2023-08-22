import * as Trezor from '@trezor/connect';
import { Cardano } from '@cardano-sdk/core';

const compareAssetNameCanonically = (a: Trezor.CardanoToken, b: Trezor.CardanoToken) => {
  if (a.assetNameBytes.length === b.assetNameBytes.length) {
    return a.assetNameBytes > b.assetNameBytes ? 1 : -1;
  } else if (a.assetNameBytes.length > b.assetNameBytes.length) return 1;
  return -1;
};

const comparePolicyIdCanonically = (a: Trezor.CardanoAssetGroup, b: Trezor.CardanoAssetGroup) =>
  // PolicyId is always of the same length
  a.policyId > b.policyId ? 1 : -1;

const tokenMapToAssetGroup = (tokenMap: Cardano.TokenMap): Trezor.CardanoAssetGroup[] => {
  const map = new Map<string, Array<Trezor.CardanoToken>>();

  for (const [key, value] of tokenMap.entries()) {
    const policyId = Cardano.AssetId.getPolicyId(key);
    const assetName = Cardano.AssetId.getAssetName(key);

    if (!map.has(policyId)) map.set(policyId, []);

    map.get(policyId)!.push({
      amount: value.toString(),
      assetNameBytes: assetName
    });
  }

  const tokenMapAssetsGroup = [];
  for (const [key, value] of map.entries()) {
    value.sort(compareAssetNameCanonically);
    tokenMapAssetsGroup.push({
      policyId: key,
      tokenAmounts: value
    });
  }

  tokenMapAssetsGroup.sort(comparePolicyIdCanonically);

  return tokenMapAssetsGroup;
};

export const mapTokenMap = (tokenMap: Cardano.TokenMap | undefined) =>
  tokenMap ? tokenMapToAssetGroup(tokenMap) : undefined;
