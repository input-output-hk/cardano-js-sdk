export const extensionId = 'lgehgfkeagjdklnanflcjoipaphegomm';

export const walletName = 'ccvault';

export const userPromptServiceChannel = `user-prompt-${walletName}`;

export const adaPriceServiceChannel = `ada-price-${walletName}`;

// TODO: delete this
export const getObservableWalletName = (accountIndex: number) => `wallet-${accountIndex}`;

// selectors
export const selectors = {
  activeWalletName: '#observableWalletName',
  btnActivateWallet1: '#activateWallet1',
  btnActivateWallet2: '#activateWallet2',
  btnDelegate: '#multiDelegation .delegate button',
  btnGrantAccess: '#requestAccessGrant',
  btnSignAndBuildTx: '#buildAndSignTx',
  deactivateWallet: '#deactivateWallet',
  destroyWallet: '#destroyWallet',
  divAdaPrice: '#adaPrice',
  divBgPortDisconnectStatus: '#remoteApiPortDisconnect .bgPortDisconnect',
  divSignature: '#signature',
  divUiPortDisconnectStatus: '#remoteApiPortDisconnect .uiPortDisconnect',
  liPercents: '#multiDelegation .distribution li .percent',
  liPools: '#multiDelegation .distribution li',
  spanAddress: '#address',
  spanBalance: '#balance',
  spanPoolIds: '#multiDelegation .delegate .pools',
  spanStakeAddress: '#stakeAddress',
  spanSupplyDistribution: '#supplyDistribution'
};
