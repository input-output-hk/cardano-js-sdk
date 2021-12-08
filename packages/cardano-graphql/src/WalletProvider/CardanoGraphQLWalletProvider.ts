import { Cardano, ProviderError, ProviderFailure, WalletProvider } from '@cardano-sdk/core';
import { ProviderFromSdk, createProvider } from '../util';

export const createGraphQLWalletProviderFromSdk: ProviderFromSdk<WalletProvider> = (sdk) =>
  ({
    async ledgerTip() {
      const { queryBlock } = await sdk.Tip();
      if (!queryBlock || queryBlock.length === 0) throw new ProviderError(ProviderFailure.NotFound);
      if (queryBlock.length !== 1)
        throw new ProviderError(ProviderFailure.InvalidResponse, null, 'Expected exactly 1 tip');
      const [tipResponse] = queryBlock;
      if (!tipResponse) throw new ProviderError(ProviderFailure.InvalidResponse);
      return {
        ...tipResponse,
        hash: Cardano.BlockId(tipResponse.hash),
        slot: tipResponse.slot.number
      };
    }
  } as WalletProvider);

export const createGraphQLWalletProvider = createProvider<WalletProvider>(createGraphQLWalletProviderFromSdk);
