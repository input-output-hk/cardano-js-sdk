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
  SignerManager,
  WalletType,
  consumeRemoteApi,
  consumeSupplyDistributionTracker,
  createKeyAgentFactory,
  exposeApi,
  exposeSignerManagerApi,
  observableWalletProperties,
  repositoryChannel,
  walletChannel,
  walletManagerChannel,
  walletManagerProperties,
  walletRepositoryProperties
} from '@cardano-sdk/web-extension';
import { adaPriceServiceChannel, selectors, userPromptServiceChannel, walletName } from './const';

import * as Crypto from '@cardano-sdk/crypto';
import { Buffer } from 'buffer';
import { Cardano } from '@cardano-sdk/core';
import {
  CommunicationType,
  InMemoryKeyAgent,
  SerializableInMemoryKeyAgentData,
  emip3encrypt,
  util
} from '@cardano-sdk/key-management';
import { HexBlob } from '@cardano-sdk/util';
import { SodiumBip32Ed25519 } from '@cardano-sdk/crypto';
import { combineLatest, firstValueFrom, merge, of } from 'rxjs';
import { runtime } from 'webextension-polyfill';

const delegationConfig = {
  count: 3,
  distribution: [10, 30, 60]
};

const api: UserPromptService = {
  allowOrigin(origin) {
    const container = document.querySelector<HTMLDivElement>('#requestAccess')!;
    container.style.display = 'block';
    document.querySelector<HTMLSpanElement>('#requestAccessOrigin')!.textContent = origin;
    const btnGrant = document.querySelector<HTMLButtonElement>(selectors.btnGrantAccess)!;
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
backgroundServices.adaUsd$.subscribe(
  (price) => (document.querySelector(selectors.divAdaPrice)!.textContent = price.toFixed(2))
);
document
  .querySelector<HTMLButtonElement>('#clearAllowList')!
  .addEventListener('click', backgroundServices.clearAllowList);

// SupplyDistributionTracker is used only for extension messaging demo purposes testing purposes.
// It will not switch when the wallet is changed
const supplyDistribution = consumeSupplyDistributionTracker({ walletName }, { logger, runtime });
combineLatest([supplyDistribution.lovelaceSupply$, supplyDistribution.stake$]).subscribe(
  ([lovelaceSupply, stake]) =>
    (document.querySelector(
      selectors.spanSupplyDistribution
    )!.textContent = `${stake.live} out of ${lovelaceSupply.total}`)
);

/** Get pools from background service and assign weights */
const displayPoolIdsAndPreparePortfolio = async (): Promise<{ pool: Cardano.StakePool; weight: number }[]> => {
  const pools = await backgroundServices.getPoolIds(delegationConfig.count);
  const poolsSpan = document.querySelector(selectors.spanPoolIds);
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

const signDataWithDRepID = async (): Promise<void> => {
  let msg: string;
  const dRepId = 'drep1vpzcgfrlgdh4fft0p0ju70czkxxkuknw0jjztl3x7aqgm9q3hqyaz';
  try {
    const signature = await wallet.signData({
      payload: HexBlob('abc123'),
      signWith: Cardano.DRepID(dRepId)
    });
    msg = JSON.stringify(signature);
  } catch (error) {
    msg = `ERROR signing data with DRepID: ${JSON.stringify(error)}`;
  }

  // Set text with signature or error
  document.querySelector(selectors.divDataSignature)!.textContent = msg;
};

const setAddresses = ({ address, stakeAddress }: { address: string; stakeAddress: string }): void => {
  document.querySelector(selectors.spanAddress)!.textContent = address;
  document.querySelector(selectors.spanStakeAddress)!.textContent = stakeAddress;
};

const setBalance = (text: string): void => {
  document.querySelector(selectors.spanBalance)!.textContent = text;
};

const setSignature = (text: string): void => {
  document.querySelector(selectors.divSignature)!.textContent = text;
};

const setName = (text: string): void => {
  document.querySelector(selectors.activeWalletName)!.textContent = text;
};

const clearWalletValues = (): void => {
  setName('-');
  setAddresses({ address: '-', stakeAddress: '-' });
  setBalance('-');
  setSignature('-');
};

const destroyWallet = async (): Promise<void> => {
  await walletManager.deactivate();
  const activeWalletId = await firstValueFrom(walletManager.activeWalletId$);
  await walletManager.destroyData(activeWalletId.walletId, env.KEY_MANAGEMENT_PARAMS.chainId);
  clearWalletValues();
};

const deactivateWallet = async (): Promise<void> => {
  await walletManager.deactivate();
  clearWalletValues();
};

/** Wallet does not have any active delegations. Show a `<p class="noDelegation">No delegation found</p>` */
const createEmptyDelegationEl = () => {
  const emptyDistribution = document.createElement('p');
  emptyDistribution.classList.add('noDelegation');
  emptyDistribution.textContent = 'No delegation found';
  return emptyDistribution;
};

/** Create a list item for a delegation `<li> <span class="poolId">thePoolId</span> <span class="percent">50</span> </li>` */
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

const signerManager = new SignerManager(
  {
    hwOptions: {
      communicationType: CommunicationType.Web,
      manifest: {
        appUrl: 'https://web-extension.app',
        email: 'e2e@web-extension.app'
      }
    }
  },
  {
    keyAgentFactory: createKeyAgentFactory({
      bip32Ed25519: new Crypto.SodiumBip32Ed25519(),
      logger
    })
  }
);

const passphraseByteArray = Uint8Array.from(
  env.KEY_MANAGEMENT_PARAMS.passphrase.split('').map((letter) => letter.charCodeAt(0))
);
merge(signerManager.signDataRequest$, signerManager.transactionWitnessRequest$).subscribe((req) => {
  logger.info('Sign request', req);
  if (req.walletType === WalletType.InMemory) {
    void req.sign(new Uint8Array(passphraseByteArray));
  } else {
    void req.sign();
  }
  logger.info('Signed', req);
});

// Setup

// Expose local objects.
exposeSignerManagerApi(
  {
    signerManager
  },
  { logger, runtime }
);

// Consume remote objects.
const walletManager = consumeRemoteApi(
  { baseChannel: walletManagerChannel(walletName), properties: walletManagerProperties },
  { logger, runtime }
);

const repository = consumeRemoteApi(
  { baseChannel: repositoryChannel(walletName), properties: walletRepositoryProperties },
  { logger, runtime }
);

// Wallet object does not change when wallets are activated/deactivated.
// Instead, it's observable properties emit from the currently active wallet.
const wallet = consumeRemoteApi(
  { baseChannel: walletChannel(walletName), properties: observableWalletProperties },
  { logger, runtime }
);

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

const createWalletIfNotExistsAndActivate = async (accountIndex: number) => {
  const wallets = await firstValueFrom(repository.wallets$);
  let walletId = wallets.find(
    (w) => w.type !== WalletType.Script && w.accounts.some((a) => a.accountIndex === accountIndex)
  )?.walletId;
  if (!walletId) {
    logger.log('creating wallet');
    clearWalletValues();
    const bip32Ed25519 = new SodiumBip32Ed25519();
    const mnemonicWords = env.KEY_MANAGEMENT_PARAMS.mnemonic.split(' ');
    const passphrase = new Uint8Array(passphraseByteArray);
    const keyAgent = await InMemoryKeyAgent.fromBip39MnemonicWords(
      {
        accountIndex,
        chainId: env.KEY_MANAGEMENT_PARAMS.chainId,
        getPassphrase: async () => passphrase,
        mnemonicWords
      },
      { bip32Ed25519, logger }
    );
    const encryptedRootPrivateKey = (keyAgent.serializableData as SerializableInMemoryKeyAgentData)
      .encryptedRootPrivateKeyBytes;

    const entropy = Buffer.from(util.mnemonicWordsToEntropy(mnemonicWords), 'hex');
    const encryptedEntropy = await emip3encrypt(entropy, passphraseByteArray);

    logger.log('adding to repository wallet');
    // Add wallet to the repository.
    walletId = await repository.addWallet({
      encryptedSecrets: {
        entropy: HexBlob.fromBytes(encryptedEntropy),
        rootPrivateKeyBytes: HexBlob.fromBytes(new Uint8Array(encryptedRootPrivateKey))
      },
      extendedAccountPublicKey: keyAgent.serializableData.extendedAccountPublicKey,
      type: WalletType.InMemory
    });
    await repository.addAccount({
      accountIndex,
      metadata: { name: `wallet-${accountIndex}` },
      walletId
    });

    logger.log(`Wallet added: ${walletId}`);
  } else {
    logger.info(`Wallet with accountIndex ${accountIndex} already exists`);
  }

  // await walletManager.destroy();
  await walletManager.activate({
    accountIndex,
    chainId: env.KEY_MANAGEMENT_PARAMS.chainId,
    walletId
  });

  // Same wallet object will return different names, based on which wallet is active
  // Calling this method before any wallet is active, will resolve only once a wallet becomes active
  setName(await wallet.getName());
};

document
  .querySelector(selectors.btnActivateWallet1)!
  .addEventListener('click', async () => await createWalletIfNotExistsAndActivate(0));
document
  .querySelector(selectors.btnActivateWallet2)!
  .addEventListener('click', async () => await createWalletIfNotExistsAndActivate(1));
document.querySelector(selectors.deactivateWallet)!.addEventListener('click', async () => await deactivateWallet());
document.querySelector(selectors.destroyWallet)!.addEventListener('click', async () => await destroyWallet());
document.querySelector(selectors.btnDelegate)!.addEventListener('click', async () => {
  const poolsAndWeights = await displayPoolIdsAndPreparePortfolio();
  // multi-delegate with 10%, 30%, 60% distribution
  await sendDelegationTx(poolsAndWeights);
});

document.querySelector(selectors.btnSignAndBuildTx)!.addEventListener('click', async () => {
  logger.info('Building transaction');
  const [{ address: ownAddress }] = await firstValueFrom(wallet.addresses$);
  logger.info(`Address: ${ownAddress}`);

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

document
  .querySelector(selectors.btnSignDataWithDRepId)!
  .addEventListener('click', async () => await signDataWithDRepID());

// Code below tests that a disconnected port in background script will result in the consumed API method call promise to reject
// UI consumes API -> BG exposes fake API that closes port
const disconnectPortTestObj = consumeRemoteApi(
  { baseChannel: 'ui-to-bg-port-disconnect-channel', properties: disconnectPortTestObjProperties },
  { logger, runtime }
);

const bgPortDisconnectPromiseDiv = document.querySelector(selectors.divBgPortDisconnectStatus);
disconnectPortTestObj
  .promiseMethod()
  .then(() => (bgPortDisconnectPromiseDiv!.textContent = 'Background port disconnect -> Promise resolves'))
  .catch(() => (bgPortDisconnectPromiseDiv!.textContent = 'Background port disconnect -> Promise rejects'));

// Dummy exposeApi-like object that closes the port as soon as it gets a message.
// Background promise call should reject as a result of this.
// Using another channel (backgroundServices.apiDisconnectResult$) to get the actual result from background script.
const uiPortDisconnectPromiseDiv = document.querySelector(selectors.divUiPortDisconnectStatus);
backgroundServices.apiDisconnectResult$.subscribe((msg) => (uiPortDisconnectPromiseDiv!.textContent = msg));
// BG consumes API -> UI exposes fake API that closes port
const port = runtime.connect({ name: 'bg-to-ui-port-disconnect-channel' });
port.onMessage.addListener((_msg, p) => {
  p.disconnect();
});
