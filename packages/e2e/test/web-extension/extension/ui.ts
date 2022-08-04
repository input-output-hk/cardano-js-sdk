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
import { KeyManagement, createWalletUtil } from '@cardano-sdk/wallet';
import {
  RemoteApiPropertyType,
  consumeObservableWallet,
  consumeRemoteApi,
  exposeApi,
  exposeKeyAgent
} from '@cardano-sdk/web-extension';
import { firstValueFrom } from 'rxjs';
import { runtime } from 'webextension-polyfill';

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
    api,
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

// Use observable wallet from UI:
const wallet = consumeObservableWallet({ walletName }, { logger, runtime });
wallet.addresses$.subscribe(([{ address }]) => (document.querySelector('#address')!.textContent = address.toString()));
wallet.balance.utxo.available$.subscribe(
  ({ coins }) => (document.querySelector('#balance')!.textContent = coins.toString())
);

document.querySelector('#createKeyAgent')!.addEventListener('click', async () => {
  const deviceConnection = await KeyManagement.LedgerKeyAgent.establishDeviceConnection(
    KeyManagement.CommunicationType.Web
  );

  const keyAgent = await KeyManagement.LedgerKeyAgent.createWithDevice(
    {
      accountIndex: 0,
      communicationType: KeyManagement.CommunicationType.Web,
      deviceConnection,
      networkId: 0,
      protocolMagic: 1_097_911_063
    },
    { inputResolver: createWalletUtil(wallet) }
  );

  // restoreKeyAgent or create a new one and expose it
  exposeKeyAgent(
    {
      keyAgent: KeyManagement.util.createAsyncKeyAgent(keyAgent),
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
  const signedTx = await wallet.finalizeTx(tx);
  document.querySelector('#signature')!.textContent = signedTx.witness.signatures.values().next().value;
});
