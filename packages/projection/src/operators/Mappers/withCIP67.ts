import { Asset, Cardano } from '@cardano-sdk/core';
import { ProducedUtxo, WithUtxo } from './withUtxo';
import { isNotNil } from '@cardano-sdk/util';
import { unifiedProjectorOperator } from '../utils';
import groupBy from 'lodash/groupBy';

export interface CIP67Asset {
  assetId: Cardano.AssetId;
  policyId: Cardano.PolicyId;
  assetName: Cardano.AssetName;
  decoded: Asset.DecodedAssetName;
  utxo: ProducedUtxo;
}

export interface WithCIP67 {
  cip67: {
    byLabel: Partial<Record<Asset.AssetNameLabel, CIP67Asset[]>>;
    byAssetId: Partial<Record<Cardano.AssetId, CIP67Asset>>;
  };
}

export const withCIP67 = unifiedProjectorOperator<WithUtxo, WithCIP67>((evt) => {
  const cip67Assets = evt.utxo.produced
    .flatMap((utxo) =>
      [...(utxo[1].value.assets?.keys() || [])].map((assetId): CIP67Asset | null => {
        const assetName = Cardano.AssetId.getAssetName(assetId);
        const decoded = Asset.AssetNameLabel.decode(assetName);
        if (!decoded) return null;
        return {
          assetId,
          assetName,
          decoded,
          policyId: Cardano.AssetId.getPolicyId(assetId),
          utxo
        };
      })
    )
    .filter(isNotNil);
  return {
    ...evt,
    cip67: {
      byAssetId: Object.fromEntries(cip67Assets.map((asset) => [asset.assetId, asset])),
      byLabel: groupBy(cip67Assets, (e) => e.decoded.label)
    }
  };
});
