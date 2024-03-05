import { BaseWallet, ObservableWallet, PublicCredentialsManagerType } from '@cardano-sdk/wallet';
import { ChainHistoryInputResolver } from './ChainHistoryInputResolver';
import { Cip30AddressDiscovery } from './Cip30AddressDiscovery';
import { Cip30TxSubmitProvider } from './Cip30TxSubmitProvider';
import { Cip30UtxoProvider } from './Cip30UtxoProvider';
import { Cip30Witnesser } from './Cip30Witnesser';
import type { Bip32Account } from '@cardano-sdk/key-management';
import type { Cip30WalletApiWithPossibleExtensions } from '@cardano-sdk/dapp-connector';
import type { ConnectWalletDependencies, InstalledWallet } from '../types';

export type WalletApiToObservableWalletProps = {
  api: Cip30WalletApiWithPossibleExtensions;
  wallet: Pick<InstalledWallet, 'id'>;
};

export const walletApiToObservableWallet = (
  props: WalletApiToObservableWalletProps,
  dependencies: ConnectWalletDependencies
): ObservableWallet =>
  new BaseWallet(
    { name: props.wallet.id },
    {
      publicCredentialsManager: {
        // REVIEW: add new 'cip30' type that doesn't have anything just the address discovery?
        __type: PublicCredentialsManagerType.BIP32_CREDENTIALS_MANAGER,
        addressDiscovery: new Cip30AddressDiscovery(props, dependencies),
        // TODO: refactor PersonalWallet to not require Bip32Account
        // TODO: refactor TxBuilder to not require Bip32Account when multi-delegating
        bip32Account: {
          // called by for getDRepPubKey during wallet initialization
          async derivePublicKey() {
            return {
              hex: () => 'deeb8f82f2af5836ebbc1b450b6dbf0b03c93afe5696f10d49e8a8304ebfac01'
            };
          }
        } as unknown as Bip32Account
      },
      txSubmitProvider: new Cip30TxSubmitProvider(props, dependencies),
      utxoProvider: new Cip30UtxoProvider(props, {
        inputResolver: new ChainHistoryInputResolver(dependencies),
        logger: dependencies.logger
      }),
      witnesser: new Cip30Witnesser(props, dependencies),
      ...dependencies
    }
  );
