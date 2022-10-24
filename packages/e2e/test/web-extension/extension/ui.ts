/* eslint-disable no-use-before-define */
import {
  BackgroundServices,
  UserPromptService,
  adaPriceProperties,
  adaPriceServiceChannel,
  logger,
  userPromptServiceChannel,
  walletName
} from './util';
import { Cardano } from '@cardano-sdk/core';
import { InMemoryKeyAgent, util } from '@cardano-sdk/key-management';
import {
  RemoteApiPropertyType,
  consumeObservableWallet,
  consumeRemoteApi,
  consumeSupplyDistributionTracker,
  exposeApi,
  exposeKeyAgent
} from '@cardano-sdk/web-extension';
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

const supplyDistribution = consumeSupplyDistributionTracker({ walletName }, { logger, runtime });
combineLatest([supplyDistribution.lovelaceSupply$, supplyDistribution.stake$]).subscribe(
  ([lovelaceSupply, stake]) =>
    (document.querySelector('#supplyDistribution')!.textContent = `${stake.live} out of ${lovelaceSupply.total}`)
);

// Use observable wallet from UI:
const wallet = consumeObservableWallet({ walletName }, { logger, runtime });
wallet.addresses$.subscribe(([{ address }]) => (document.querySelector('#address')!.textContent = address.toString()));
wallet.balance.utxo.available$.subscribe(
  ({ coins }) => (document.querySelector('#balance')!.textContent = coins.toString())
);

document.querySelector('#createKeyAgent')!.addEventListener('click', async () => {
  // setupWallet call is required to provide context (InputResolver) to the key agent
  const { keyAgent } = await setupWallet({
    createKeyAgent: async (dependencies) =>
      util.createAsyncKeyAgent(
        await InMemoryKeyAgent.fromBip39MnemonicWords(
          {
            accountIndex: 0,
            getPassword: async () => Buffer.from(''),
            mnemonicWords: process.env.MNEMONIC_WORDS!.split(' '),
            networkId: 0
          },
          dependencies
        )
      ),
    createWallet: async () => wallet
  });
  // restoreKeyAgent or create a new one and expose it
  exposeKeyAgent(
    {
      keyAgent,
      walletName
    },
    { logger, runtime }
  );
});

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
  document.querySelector('#signature')!.textContent = signedTx.witness.signatures.values().next().value;
});
