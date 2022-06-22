import { CardanoWalletFaucetProvider, FaucetProvider } from './';
import { ProviderFactory } from '@cardano-sdk/core';

// Get provider factory singleton instance

export const faucetProviderFactory = new ProviderFactory<FaucetProvider>();

// Register providers
faucetProviderFactory.register(CardanoWalletFaucetProvider.name, CardanoWalletFaucetProvider.create);
