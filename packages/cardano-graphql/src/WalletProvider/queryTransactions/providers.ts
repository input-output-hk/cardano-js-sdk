import { WalletProvider } from '@cardano-sdk/core';
import { WalletProviderFnProps } from '../WalletProviderFnProps';
import { graphqlTransactionsToCore } from './graphqlTransactionsToCore';

export const queryTransactionsByHashesProvider =
  ({ sdk, getExactlyOneObject }: WalletProviderFnProps): WalletProvider['queryTransactionsByHashes'] =>
  async (hashes) =>
    graphqlTransactionsToCore(
      await sdk.TransactionsByHashes({
        hashes: hashes as unknown as string[]
      }),
      getExactlyOneObject
    );
