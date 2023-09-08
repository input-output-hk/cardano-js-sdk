import { Asset, Cardano } from '@cardano-sdk/core';
import { BalanceTracker, TransactionalObservables, TransactionsTracker } from './types';

import { Observable, distinct, distinctUntilChanged, from, map, switchMap } from 'rxjs';
import { isNotNil } from '@cardano-sdk/util';
import { utxoEquals } from './util';

export interface DatumMetadata {
  nft: Partial<
    Record<
      Cardano.AssetId,
      {
        metadata: Asset.NftMetadata;
        extra: Cardano.PlutusData;
      }
    >
  >;
}

export const createDatumMetadataTracker = (transactionsTracker: TransactionsTracker): Observable<DatumMetadata> =>
  transactionsTracker.history$.pipe(
    switchMap((txs) => from(txs)),
    distinct(),
    map((tx) => {
      const userTokens = tx.body.outputs
        .flatMap((txOut) => {
          if (!txOut.datum || !txOut.value.assets) return;
          return [...txOut.value.assets.keys()]
            .map((assetId) => {
              const assetName = Cardano.AssetId.getAssetName(assetId);
              const decoded = Asset.AssetNameLabel.decode(assetName);
              if (decoded?.label === Asset.AssetNameLabelNum.ReferenceNFT) {
                return Cardano.AssetId.fromParts(
                  Cardano.AssetId.getPolicyId(assetId),
                  Asset.AssetNameLabel.encode(decoded.content, Asset.AssetNameLabelNum.UserNFT)
                );
              }
              return null;
            })
            .filter(isNotNil);
        })
        .filter(isNotNil);
    })
  );
