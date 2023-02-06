import * as Crypto from '@cardano-sdk/crypto';
import { AsyncKeyAgent, KeyAgentDependencies } from '@cardano-sdk/key-management';
import { Logger } from 'ts-log';
import { ObservableWallet } from './types';
import { WalletUtil, WalletUtilContext, createLazyWalletUtil } from './services';

export interface SetupWalletProps<TWallet, TKeyAgent> {
  createKeyAgent: (dependencies: KeyAgentDependencies) => Promise<TKeyAgent>;
  createWallet: (keyAgent: TKeyAgent) => Promise<TWallet>;
  logger: Logger;
  bip32Ed25519: Crypto.Bip32Ed25519;
}

/**
 * Creates a wallet and a key agent that has the context of that wallet.
 *
 * Use this if you want to create a KeyAgent that uses wallet as InputResolver.
 *
 * Encapsulates the logic to resolve circular dependency of Wallet->KeyAgent->InputResolver(WalletUtil)->Wallet.
 */
export const setupWallet = async <TWallet extends WalletUtilContext = ObservableWallet, TKeyAgent = AsyncKeyAgent>({
  createKeyAgent,
  createWallet,
  logger,
  bip32Ed25519
}: SetupWalletProps<TWallet, TKeyAgent>) => {
  const walletUtil = createLazyWalletUtil();
  const keyAgent = await createKeyAgent({ bip32Ed25519, inputResolver: walletUtil, logger });
  const wallet = await createWallet(keyAgent);
  walletUtil.initialize(wallet);
  return { keyAgent, wallet, walletUtil: walletUtil as WalletUtil };
};
