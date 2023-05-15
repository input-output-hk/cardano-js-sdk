import * as Ledger from '@cardano-foundation/ledgerjs-hw-app-cardano';
import { Cardano } from '@cardano-sdk/core';

const compareAssetNameCanonically = (a: Ledger.Token, b: Ledger.Token) => {
  if (a.assetNameHex === b.assetNameHex) {
    return a.assetNameHex > b.assetNameHex ? 1 : -1;
  } else if (a.assetNameHex.length > b.assetNameHex.length) return 1;
  return -1;
};

const comparePolicyIdCanonically = (a: Ledger.AssetGroup, b: Ledger.AssetGroup) => {
  if (a.policyIdHex === b.policyIdHex) {
    return a.policyIdHex > b.policyIdHex ? 1 : -1;
  } else if (a.policyIdHex.length > b.policyIdHex.length) return 1;
  return -1;
};

const tokenMapToAssetGroup = (tokenMap: Cardano.TokenMap): Ledger.AssetGroup[] => {
  const map = new Map<string, Array<Ledger.Token>>();

  for (const [key, value] of tokenMap.entries()) {
    const policyId = Cardano.AssetId.getPolicyId(key);
    const assetName = Cardano.AssetId.getAssetName(key);

    if (!map.has(policyId)) map.set(policyId, new Array<Ledger.Token>());

    map.get(policyId)!.push({
      amount: value,
      assetNameHex: assetName
    });
  }

  const tokenMapAssetsGroup = [];
  for (const [key, value] of map.entries()) {
    value.sort(compareAssetNameCanonically);
    tokenMapAssetsGroup.push({
      policyIdHex: key,
      tokens: value
    });
  }

  tokenMapAssetsGroup.sort(comparePolicyIdCanonically);

  return tokenMapAssetsGroup;
};

export const mapTokenMap = (tokenMap: Cardano.TokenMap | undefined) => {
  if (!tokenMap) return null;

  return tokenMapToAssetGroup(tokenMap);
};
