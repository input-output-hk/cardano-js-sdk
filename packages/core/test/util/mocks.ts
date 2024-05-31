import * as Cardano from '../../src/Cardano';
import { Asset, AssetProvider, HealthCheckResponse } from '../../src';

export const createMockInputResolver = (
  historicalTxs: Cardano.HydratedTx[],
  resolveDelay = 0
): Cardano.InputResolver => ({
  async resolveInput(input: Cardano.TxIn) {
    const tx = historicalTxs.find((historicalTx) => historicalTx.id === input.txId);

    if (!tx || tx.body.outputs.length <= input.index) return Promise.resolve(null);

    return await new Promise((resolve) => {
      setTimeout(() => {
        resolve(tx.body.outputs[input.index]);
      }, resolveDelay);
    });
  }
});

export const createMockAssetProvider = (assets: Asset.AssetInfo[]): AssetProvider => ({
  getAsset: async ({ assetId }) =>
    assets.find((asset) => asset.assetId === assetId) ?? Promise.reject('Asset not found'),
  getAssets: async ({ assetIds }) => assets.filter((asset) => assetIds.includes(asset.assetId)),
  healthCheck: async () => Promise.resolve({} as HealthCheckResponse)
});
