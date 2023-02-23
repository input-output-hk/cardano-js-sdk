/* eslint-disable no-use-before-define */
import { BackgroundServices, UserPromptService, adaPriceProperties, env, logger } from './util';
import { Cardano } from '@cardano-sdk/core';
import {
  RemoteApiPropertyType,
  WalletManagerUi,
  consumeRemoteApi,
  consumeSupplyDistributionTracker,
  exposeApi
} from '@cardano-sdk/web-extension';
import { adaPriceServiceChannel, getObservableWalletName, userPromptServiceChannel, walletName } from './const';
import { bip32Ed25519Factory, keyManagementFactory } from '../../../src';

import { combineLatest, firstValueFrom, of } from 'rxjs';
import { runtime } from 'webextension-polyfill';
import { setupWallet } from '@cardano-sdk/wallet';

const api: UserPromptService = {
  allowOrigin(origin) {
    const container = document.querySelector<HTMLDivElement>('#requestAccess')!;
    container.style.display = 'block';
    document.querySelector<HTMLSpanElement>('#requestAccessOrigin')!.textContent = origin;
    const btnGrant = document.querySelector<HTMLButtonElement>('#requestAccessGrant')!;
    const btnDeny = document.querySelector<HTMLButtonElement>('#requestAccessDeny')!;
    return new Promise((resolve) => {
      const done = async (grant: boolean) => {
        btnGrant.removeEventListener('click', grantListener);
        btnDeny.removeEventListener('click', denyListener);
        container.style.display = 'none';
        resolve(grant);
      };
      const grantListener = () => done(true);
      const denyListener = () => done(false);
      btnGrant.addEventListener('click', grantListener);
      btnDeny.addEventListener('click', denyListener);
    });
  }
};

exposeApi<UserPromptService>(
  {
    api$: of(api),
    baseChannel: userPromptServiceChannel,
    properties: { allowOrigin: RemoteApiPropertyType.MethodReturningPromise }
  },
  { logger, runtime }
);

// Consume background services
const backgroundServices = consumeRemoteApi<BackgroundServices>(
  {
    baseChannel: adaPriceServiceChannel,
    properties: adaPriceProperties
  },
  { logger, runtime }
);
backgroundServices.adaUsd$.subscribe((price) => (document.querySelector('#adaPrice')!.textContent = price.toFixed(2)));
document
  .querySelector<HTMLButtonElement>('#clearAllowList')!
  .addEventListener('click', backgroundServices.clearAllowList);

// SupplyDistributionTracker is used only for extension messaging demo purposes testing purposes.
// It will not switch when the wallet is changed
const supplyDistribution = consumeSupplyDistributionTracker({ walletName }, { logger, runtime });
combineLatest([supplyDistribution.lovelaceSupply$, supplyDistribution.stake$]).subscribe(
  ([lovelaceSupply, stake]) =>
    (document.querySelector('#supplyDistribution')!.textContent = `${stake.live} out of ${lovelaceSupply.total}`)
);

const setAddresses = ({ address, stakeAddress }: { address: string; stakeAddress: string }): void => {
  document.querySelector('#address')!.textContent = address;
  document.querySelector('#stakeAddress')!.textContent = stakeAddress;
};

const setBalance = (text: string): void => {
  document.querySelector('#balance')!.textContent = text;
};

const setSignature = (text: string): void => {
  document.querySelector('#signature')!.textContent = text;
};

const setName = (text: string): void => {
  document.querySelector('#observableWalletName')!.textContent = text;
};

const clearWalletValues = (): void => {
  setName('-');
  setAddresses({ address: '-', stakeAddress: '-' });
  setBalance('-');
  setSignature('-');
};

const destroyWallet = async (): Promise<void> => {
  await walletManager.destroy();
  clearWalletValues();
};

const deactivateWallet = async (): Promise<void> => {
  await walletManager.deactivate();
  clearWalletValues();
};

const walletManager = new WalletManagerUi({ walletName }, { logger, runtime });
// Wallet object does not change when wallets are activated/deactivated.
// Instead, it's observable properties emit from the currently active wallet.
const wallet = walletManager.wallet;

// Wallet can be subscribed can be used even before it is actually created.
wallet.addresses$.subscribe(([{ address, rewardAccount }]) =>
  setAddresses({ address: address.toString(), stakeAddress: rewardAccount })
);
wallet.balance.utxo.available$.subscribe(({ coins }) => setBalance(coins.toString()));

const createWallet = async (accountIndex: number) => {
  clearWalletValues();

  // setupWallet call is required to provide context (InputResolver) to the key agent
  const { keyAgent } = await setupWallet({
    bip32Ed25519: await bip32Ed25519Factory.create(env.KEY_MANAGEMENT_PARAMS.bip32Ed25519, null, logger),
    createKeyAgent: async (dependencies) =>
      (
        await keyManagementFactory.create(
          env.KEY_MANAGEMENT_PROVIDER,
          {
            ...env.KEY_MANAGEMENT_PARAMS,
            accountIndex
          },
          logger
        )
      )(dependencies),
    createWallet: async () => wallet,
    logger
  });

  await walletManager.destroy();
  await walletManager.activate({ keyAgent, observableWalletName: getObservableWalletName(accountIndex) });

  // Same wallet object will return different names, based on which wallet is active
  // Calling this method before any wallet is active, will resolve only once a wallet becomes active
  setName(await wallet.getName());
};

document.querySelector('#activateWallet1')!.addEventListener('click', async () => await createWallet(0));
document.querySelector('#activateWallet2')!.addEventListener('click', async () => await createWallet(1));
document.querySelector('#deactivateWallet')!.addEventListener('click', async () => await deactivateWallet());
document.querySelector('#destroyWallet')!.addEventListener('click', async () => await destroyWallet());

document.querySelector('#buildAndSignTx')!.addEventListener('click', async () => {
  const [{ address: ownAddress }] = await firstValueFrom(wallet.addresses$);
  const tx = await wallet.initializeTx({
    outputs: new Set<Cardano.TxOut>([
      {
        address: ownAddress,
        value: { coins: 2_000_000n }
      }
    ])
  });
  const signedTx = await wallet.finalizeTx({ tx });
  setSignature(signedTx.witness.signatures.values().next().value);
});
