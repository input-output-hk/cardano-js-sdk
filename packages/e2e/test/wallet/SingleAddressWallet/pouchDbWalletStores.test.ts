import { dummyLogger } from 'ts-log';
import { env } from '../environment';
import { filter, firstValueFrom } from 'rxjs';
import { getWallet } from '../../../src/factories';
import { storage } from '@cardano-sdk/wallet';
import { waitForWalletStateSettle } from '../util';
import delay from 'delay';

describe('SingleAddressWallet/pouchDbWalletStores', () => {
  const walletName = 'DbTestWallet';
  let stores1: storage.WalletStores;

  beforeAll(() => {
    stores1 = storage.createPouchDbWalletStores(walletName, { logger: dummyLogger });
  });

  it('stores and restores SingleAddressWallet, continues sync after initial load', async () => {
    const wallet1 = (await getWallet({ env, name: 'Test Wallet', stores: stores1 })).wallet;
    // wallet1 fetched all responses from wallet provider
    await waitForWalletStateSettle(wallet1);
    // give it a second to store data to PouchDb, this is technically a race condition
    await delay(1000);
    // loading reward accounts involves loading many other pieces (transactions, stake pools etc.)
    const wallet1RewardAccounts = await firstValueFrom(wallet1.delegation.rewardAccounts$);
    const wallet1RewardsHistory = await firstValueFrom(wallet1.delegation.rewardsHistory$);
    wallet1.shutdown();
    // create a new wallet, with new stores sharing the underlying database
    const wallet2 = (
      await getWallet({
        env,
        name: walletName,
        stores: storage.createPouchDbWalletStores(walletName, { logger: dummyLogger })
      })
    ).wallet;
    const tip = await firstValueFrom(wallet2.tip$);
    expect(await firstValueFrom(wallet2.delegation.rewardsHistory$)).toEqual(wallet1RewardsHistory);
    expect(await firstValueFrom(wallet1.delegation.rewardAccounts$)).toEqual(wallet1RewardAccounts);
    // if it's still syncing and reward accounts matched wallet1, it means it has loaded from storage.
    // technically a race condition too...
    expect(await firstValueFrom(wallet2.syncStatus.isSettled$)).toBe(false);
    // will time out if it's not syncing after load.
    await waitForWalletStateSettle(wallet2);
    // assert that it's updating wallet properties after fetching new data from the provider (at least the tip)
    await firstValueFrom(wallet2.tip$.pipe(filter((newTip) => newTip.slot !== tip.slot)));
    wallet2.shutdown();
  });

  afterAll(() => firstValueFrom(stores1.destroy()));
});
