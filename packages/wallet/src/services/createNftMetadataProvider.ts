import { Asset, Cardano, NftMetadataProvider, WalletProvider } from '@cardano-sdk/core';
import { Observable, firstValueFrom, from, map, mergeMap, of, take } from 'rxjs';
import { last } from 'lodash-es';

export const createNftMetadataProvider =
  (walletProvider: WalletProvider, transactions$: Observable<Cardano.TxAlonzo[]>): NftMetadataProvider =>
  (asset) => {
    const latestMintTxId = last(asset.history.filter(({ quantity }) => quantity > 0))!.transactionId;
    return firstValueFrom(
      transactions$.pipe(
        take(1),
        map((transactions) => transactions.find((tx) => tx.id === latestMintTxId)),
        mergeMap((localTx) =>
          // Use local transaction if available, otherwise fetch from WalletProvider
          localTx ? of(localTx) : from(walletProvider.queryTransactionsByHashes([latestMintTxId]).then(([tx]) => tx))
        ),
        map(({ auxiliaryData }) => Asset.util.metadatumToCip25(asset, auxiliaryData?.body.blob))
      )
    );
  };
