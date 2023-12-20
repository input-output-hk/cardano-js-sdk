import {
  AnyWallet,
  StoresFactory,
  WalletFactory,
  WalletManager,
  WalletManagerActivateProps,
  WalletRepository,
  WalletType,
  consumeSignerManagerApi,
  exposeApi,
  observableWalletProperties,
  repositoryChannel,
  walletChannel,
  walletManagerChannel,
  walletManagerProperties,
  walletRepositoryProperties
} from '@cardano-sdk/web-extension';

import { InvalidArgumentError, isNotNil } from '@cardano-sdk/util';
import { Metadata, env, logger } from '../util';
import { storage as WebExtensionStorage, runtime } from 'webextension-polyfill';
import { Witnesser } from '@cardano-sdk/key-management';
import { filter, from, merge, of } from 'rxjs';
import { getWallet } from '../../../../src';
import { storage } from '@cardano-sdk/wallet';
import { toEmpty } from '@cardano-sdk/util-rxjs';
import { walletName } from '../const';

export interface WalletFactoryDependencies {
  witnesser: Witnesser;
  stores: storage.WalletStores;
}

/**
 * Gets the wallet name.
 *
 * @param wallet The wallet to get the name from.
 * @param accountIndex The account index to get the name from.
 * @private
 */
const getWalletName = (wallet: AnyWallet<Metadata>, accountIndex?: number): string => {
  let name = '';
  switch (wallet.type) {
    case WalletType.InMemory:
    case WalletType.Ledger:
    case WalletType.Trezor: {
      if (accountIndex === undefined)
        throw new InvalidArgumentError('accountIndex', `Account index is required for ${wallet.type} wallet`);

      const account = wallet.accounts.find((acc) => acc.accountIndex === accountIndex);

      if (!account)
        throw new InvalidArgumentError('accountIndex', `Account ${accountIndex} not found in ${wallet.type} wallet`);

      name = account.metadata.name;
      break;
    }
    case WalletType.Script:
      name = wallet.metadata.name;
      break;
  }

  return name;
};

/**
 * {@link WalletManagerActivateProps.provider} could be used to pass the necessary information
 * to construct providers for different networks.
 * Please check its documentation for examples.
 */
const walletFactory: WalletFactory<Metadata> = {
  create: async (
    props: WalletManagerActivateProps,
    wallet: AnyWallet<Metadata>,
    { witnesser, stores }: WalletFactoryDependencies
  ) =>
    (
      await getWallet({
        env,
        logger,
        name: getWalletName(wallet, props.accountIndex),
        stores,
        witnesser
      })
    ).wallet
};

const storesFactory: StoresFactory = {
  create: ({ name }) => storage.createPouchDbWalletStores(name, { logger })
};

const walletRepository = new WalletRepository<Metadata>({
  logger,
  store: new storage.InMemoryCollectionStore()
});

const signerManagerApi = consumeSignerManagerApi({ logger, runtime });

const walletManager = new WalletManager<Metadata>(
  { name: walletName },
  {
    logger,
    managerStorage: WebExtensionStorage.local,
    runtime,
    signerManagerApi,
    storesFactory,
    walletFactory,
    walletRepository
  }
);

exposeApi(
  {
    api$: of(walletRepository),
    baseChannel: repositoryChannel(walletName),
    properties: walletRepositoryProperties
  },
  { logger, runtime }
);

exposeApi(
  {
    api$: of(walletManager),
    baseChannel: walletManagerChannel(walletName),
    properties: walletManagerProperties
  },
  { logger, runtime }
);

exposeApi(
  {
    api$: walletManager.activeWallet$.asObservable(),
    baseChannel: walletChannel(walletName),
    properties: observableWalletProperties
  },
  { logger, runtime }
);

export const wallet$ = (() =>
  merge(walletManager.activeWallet$.pipe(filter(isNotNil)), from(walletManager.initialize()).pipe(toEmpty)))();
