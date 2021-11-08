import { Cardano } from '@cardano-sdk/core';
import { Transactions } from '../types';
import { filter, map } from 'rxjs';

export const certificateTransactions = (
  transactionsTracker: Transactions,
  certificateTypes: Cardano.CertificateType[]
) =>
  transactionsTracker.history.outgoing$.pipe(
    map((transactions) =>
      transactions.filter(
        ({ body: { certificates } }) =>
          certificates?.some(({ __typename }) => certificateTypes.includes(__typename)) || false
      )
    ),
    filter((transactions) => transactions.length > 0)
    // TODO
    // distinctUntilChanged(transactionsEquals)
  );
