import { Cardano, WalletProvider } from '@cardano-sdk/core';
import { NftMetadataProvider } from './types';
import { Observable, firstValueFrom, from, map, mergeMap, of, take } from 'rxjs';
import { last } from 'lodash-es';
import { metadatumToCip25 } from './metadatumToCip25';

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
        map(({ auxiliaryData }) => metadatumToCip25(asset, auxiliaryData?.body.blob))
      )
    );
  };
