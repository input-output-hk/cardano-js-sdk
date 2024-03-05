import { Cardano } from '@cardano-sdk/core';
import { DappConnectorError } from './errors';
import { Observable, ReplaySubject, from, map, switchMap } from 'rxjs';
import { getCardanoNamespace } from './util';
import { walletApiToObservableWallet } from './walletApiToObservableWallet';
import type { ConnectWalletDependencies, InstalledWallet, WalletId } from './types';
import type { ObservableWallet } from '@cardano-sdk/wallet';
import type { WalletApiExtension } from '@cardano-sdk/dapp-connector';

export type ConnectedWallet = {
  wallet: ObservableWallet;
  networkId: Cardano.NetworkId;
};

const connections: Partial<Record<WalletId, ReplaySubject<ConnectedWallet>>> = {};

export const connectWallet = (
  wallet: Pick<InstalledWallet, 'id' | 'isEnabled'>,
  dependencies: ConnectWalletDependencies,
  extensions: WalletApiExtension[] = []
): Observable<ConnectedWallet> => {
  if (!connections[wallet.id]) {
    connections[wallet.id] = new ReplaySubject(1);
    from(
      (async () => {
        if (await wallet.isEnabled()) {
          dependencies.logger.warn(
            'Enabling wallet that returned true for isEnabled(), but was not enabled via dapp-connector-client'
          );
        }

        const cardanoNamespace = getCardanoNamespace();
        if (!cardanoNamespace) {
          throw new DappConnectorError('Cardano namespace not found');
        }

        const initialApi = cardanoNamespace[wallet.id];
        if (!initialApi) {
          throw new DappConnectorError(`Initial API for wallet '${wallet.id}' not found`);
        }

        return await initialApi.enable({ extensions });
      })()
    )
      .pipe(
        switchMap((fullApi) =>
          // TODO: implement polling of getNetworkId, when it changes:
          // - re-create ObservableWallet
          // - shutdown ObservableWallet of a previous network
          from(fullApi.getNetworkId()).pipe(
            map(
              (networkId): ConnectedWallet => ({
                networkId,
                wallet: walletApiToObservableWallet(
                  {
                    api: fullApi,
                    wallet
                  },
                  dependencies
                )
              })
            )
          )
        )
      )
      .subscribe(connections[wallet.id]);
  }
  return connections[wallet.id]!;
};
