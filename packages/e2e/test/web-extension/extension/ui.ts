/* eslint-disable no-use-before-define */
import {
  BackgroundServices,
  UserPromptService,
  adaPriceProperties,
  disconnectPortTestObjProperties,
  env,
  logger
} from './util';
import {
  RemoteApiPropertyType,
  WalletManagerUi,
  consumeRemoteApi,
  consumeSupplyDistributionTracker,
  exposeApi
} from '@cardano-sdk/web-extension';
import { adaPriceServiceChannel, getObservableWalletName, userPromptServiceChannel, walletName } from './const';
import { bip32Ed25519Factory, keyManagementFactory } from '../../../src';

import { Cardano } from '@cardano-sdk/core';
import { combineLatest, firstValueFrom, of } from 'rxjs';
import { runtime } from 'webextension-polyfill';
import { setupWallet } from '@cardano-sdk/wallet';

const delegationConfig = {
  count: 3,
  distribution: [10, 30, 60]
};

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

/** Get pools from background service and assign weights */
const displayPoolIdsAndPreparePortfolio = async (): Promise<{ pool: Cardano.StakePool; weight: number }[]> => {
  const pools = await backgroundServices.getPoolIds(delegationConfig.count);
  const poolsSpan = document.querySelector('#multiDelegation .delegate .pools');
  poolsSpan!.textContent = pools.map(({ id }) => id).join(' ');
  return pools.map((pool, idx) => ({ pool, weight: delegationConfig.distribution[idx] }));
};

/** Build, sign and submit delegation transaction */
const sendDelegationTx = async (portfolio: { pool: Cardano.StakePool; weight: number }[]): Promise<void> => {
  const pools = portfolio.map(({ pool: { hexId: id }, weight }) => ({ id, weight }));
  const txBuilder = wallet.createTxBuilder();

  let msg: string;
  try {
    const signedTx = await txBuilder.delegatePortfolio({ pools }).build().sign();
    const txId = await wallet.submitTx(signedTx);
    msg = `TxId: ${txId}`;
  } catch (error) {
    msg = `ERROR delegating: ${JSON.stringify(error)}`;
  }
  document.querySelector('#multiDelegation .delegateTxId')!.textContent = msg;
};

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

/**
 * Wallet does not have any active delegations.
 * Show a `<p class="noDelegation">No delegation found</p>`
 */
const createEmptyDelegationEl = () => {
  const emptyDistribution = document.createElement('p');
  emptyDistribution.classList.add('noDelegation');
  emptyDistribution.textContent = 'No delegation found';
  return emptyDistribution;
};

/**
 * Create a list item for a delegation
 * `<li> <span class="poolId">thePoolId</span> <span class="percent">50</span> </li>`
 */
const createDelegationLi = (poolId: string, percent: string) => {
  const delegationLi = document.createElement('li');
  const poolIdSpan = document.createElement('span');
  poolIdSpan.classList.add('poolId');
  poolIdSpan.textContent = poolId;
  const delegationPercentageSpan = document.createElement('span');
  delegationPercentageSpan.classList.add('percent');
  delegationPercentageSpan.textContent = percent;
  const separatorSpan = document.createElement('span');
  separatorSpan.textContent = ' - ';
  delegationLi.append(poolIdSpan);
  delegationLi.append(separatorSpan);
  delegationLi.append(delegationPercentageSpan);
  return delegationLi;
};

/** Remove empty delegation message or multi-delegation list items to display new data */
const cleanupMultidelegationInfo = (multiDelegationDiv: Element) => {
  multiDelegationDiv.querySelector('p.noDelegation')?.remove();
  for (const delegationLi of multiDelegationDiv.querySelectorAll('ul > li')) {
    delegationLi.remove();
  }
};

const walletManager = new WalletManagerUi({ walletName }, { logger, runtime });
// Wallet object does not change when wallets are activated/deactivated.
// Instead, it's observable properties emit from the currently active wallet.
const wallet = walletManager.wallet;

// Wallet can be subscribed can be used even before it is actually created.
wallet.addresses$.subscribe(([{ address, rewardAccount }]) => setAddresses({ address, stakeAddress: rewardAccount }));
wallet.balance.utxo.available$.subscribe(({ coins }) => setBalance(coins.toString()));
wallet.delegation.distribution$.subscribe((delegationDistrib) => {
  const multiDelegationDiv = document.querySelector('#multiDelegation .distribution');
  cleanupMultidelegationInfo(multiDelegationDiv!);

  if (delegationDistrib.size === 0) {
    multiDelegationDiv?.appendChild(createEmptyDelegationEl());
  } else {
    const distributionUl = multiDelegationDiv?.querySelector('ul');
    for (const [poolId, delegation] of delegationDistrib) {
      distributionUl?.appendChild(createDelegationLi(poolId, (delegation.percentage * 100).toString()));
    }
  }
});

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
document.querySelector('#multiDelegation .delegate button')!.addEventListener('click', async () => {
  const poolsAndWeights = await displayPoolIdsAndPreparePortfolio();
  // multi-delegate with 10%, 30%, 60% distribution
  await sendDelegationTx(poolsAndWeights);
});

document.querySelector('#buildAndSignTx')!.addEventListener('click', async () => {
  const [{ address: ownAddress }] = await firstValueFrom(wallet.addresses$);
  const builtTx = wallet
    .createTxBuilder()
    .addOutput({
      address: ownAddress,
      value: { coins: 2_000_000n }
    })
    .build();
  const { body } = await builtTx.inspect();
  logger.info('Built tx', body.outputs.length);
  const { tx: signedTx } = await builtTx.sign();
  setSignature(signedTx.witness.signatures.values().next().value);
});

// Code below tests that a disconnected port in background script will result in the consumed API method call promise to reject
// UI consumes API -> BG exposes fake API that closes port
const disconnectPortTestObj = consumeRemoteApi(
  { baseChannel: 'ui-to-bg-port-disconnect-channel', properties: disconnectPortTestObjProperties },
  { logger, runtime }
);

const bgPortDisconnectPromiseDiv = document.querySelector('#remoteApiPortDisconnect .bgPortDisconnect');
disconnectPortTestObj
  .promiseMethod()
  .then(() => (bgPortDisconnectPromiseDiv!.textContent = 'Background port disconnect -> Promise resolves'))
  .catch(() => (bgPortDisconnectPromiseDiv!.textContent = 'Background port disconnect -> Promise rejects'));

// Dummy exposeApi-like object that closes the port as soon as it gets a message.
// Background promise call should reject as a result of this.
// Using another channel (backgroundServices.apiDisconnectResult$) to get the actual result from background script.
const uiPortDisconnectPromiseDiv = document.querySelector('#remoteApiPortDisconnect .uiPortDisconnect');
backgroundServices.apiDisconnectResult$.subscribe((msg) => (uiPortDisconnectPromiseDiv!.textContent = msg));
// BG consumes API -> UI exposes fake API that closes port
const port = runtime.connect({ name: 'bg-to-ui-port-disconnect-channel' });
port.onMessage.addListener((_msg, p) => {
  p.disconnect();
});
