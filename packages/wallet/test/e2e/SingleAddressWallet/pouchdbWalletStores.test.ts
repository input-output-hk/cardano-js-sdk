import { PouchdbStore } from '../../../src/persistence/pouchdbStores/PouchdbStore';
import { SingleAddressWallet, SyncStatus, Wallet } from '../../../src';
import { WalletStores, createPouchdbWalletStores } from '../../../src/persistence';
import {
  assetProvider,
  keyAgentReady,
  stakePoolSearchProvider,
  timeSettingsProvider,
  txSubmitProvider,
  walletProvider
} from '../config';
import { filter, firstValueFrom } from 'rxjs';
import { uniq } from 'lodash-es';
import PouchDB from 'pouchdb';
import delay from 'delay';

describe('SingleAddressWallet/pouchdbWalletStores', () => {
  const walletName = 'DbTestWallet';
  let stores1: WalletStores;

  beforeAll(() => {
    stores1 = createPouchdbWalletStores(walletName);
  });

  const createWallet = async (stores: WalletStores) =>
    new SingleAddressWallet(
      { name: walletName },
      {
        assetProvider,
        keyAgent: await keyAgentReady,
        stakePoolSearchProvider,
        stores,
        timeSettingsProvider,
        txSubmitProvider,
        walletProvider
      }
    );

  // resolves when wallet fetched all responses from wallet provider
  // eslint-disable-next-line unicorn/consistent-function-scoping
  const waitForWalletUpToDate = (wallet: Wallet) =>
    firstValueFrom(wallet.syncStatus$.pipe(filter((status) => status === SyncStatus.UpToDate)));

  it('stores and restores SingleAddressWallet, continues sync after initial load', async () => {
    const wallet1 = await createWallet(stores1);
    // wallet1 fetched all responses from wallet provider
    await waitForWalletUpToDate(wallet1);
    // give it a second to store data to pouchdb, this is technically a race condition
    await delay(1000);
    // loading reward accounts involves loading many other pieces (transactions, stake pools etc.)
    const wallet1RewardAccounts = await firstValueFrom(wallet1.delegation.rewardAccounts$);
    wallet1.shutdown();
    // create a new wallet, with new stores sharing the underlying database
    const wallet2 = await createWallet(createPouchdbWalletStores(walletName));
    const tip = await firstValueFrom(wallet2.tip$);
    expect(await firstValueFrom(wallet1.delegation.rewardAccounts$)).toEqual(wallet1RewardAccounts);
    // if it's still syncing and reward accounts matched wallet1, it means it has loaded from storage.
    // technically a race condition too...
    expect(await firstValueFrom(wallet2.syncStatus$)).toBe(SyncStatus.Syncing);
    // assert that it's syncing after load.
    await waitForWalletUpToDate(wallet2);
    // asset that it's updating wallet properties after fetching new data from the provider (at least the tip)
    await firstValueFrom(wallet2.tip$.pipe(filter((newTip) => newTip.slot !== tip.slot)));
    wallet2.shutdown();
  });

  afterAll(async () => {
    await Promise.all(
      uniq(Object.values(stores1).map((store: PouchdbStore<unknown>) => store.dbName)).map((dbName) =>
        new PouchDB(dbName).destroy()
      )
    );
  });
});
