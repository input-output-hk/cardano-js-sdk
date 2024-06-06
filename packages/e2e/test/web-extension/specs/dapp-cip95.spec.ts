import { selectors } from '../extension/const.js';
import { switchToWalletUi } from './utils.js';

// uses cip95 demo dapp: https://github.com/Ryun1/cip95-cardano-wallet-connector @89b405fbc

describe('dapp/cip95', () => {
  const checkboxEnableCip95 = '#root > div > input[type=checkbox]';
  const pWalletFound = '#root > div > p';
  const btnRefresh = '#root > div > button';
  const pNetworkId = '#root > div > p:nth-child(15)';
  const liFirstUtxo = '#root > div > p:nth-child(16) > li';

  const liSupportedExtensions = '#root > div > p:nth-child(12) > ul > li';
  const liGetExtensions = '#root > div > p:nth-child(21) > ul > li';

  // Selectors below target some of the elements in the CIP-95 dapp. More selectors are needed to configure the
  // different actions that we'll test.

  const dappGetPubDrepKey = '#root > div > p:nth-child(24)';
  const dappDrepId = '#root > div > p:nth-child(26)';
  const dappGetRegisteredPubStakeKeys = '#root > div > p:nth-child(27)';

  // const tabSubmitVoteDelegation = 'div[role="tablist"] > div[data-tab-id="1"]';
  // const tabSubmitDrepRegistration = 'div[role="tablist"] > div[data-tab-id="2"]';
  // const tabSubmitDrepRetirement = 'div[role="tablist"] > div[data-tab-id="3"]';
  // const tabSubmitVote = 'div[role="tablist"] > div[data-tab-id="4"]';
  // const tabSubmitGovAction = 'div[role="tablist"] > div[data-tab-id="5"]';

  const dappChangeAddress = '#root > div > p:nth-child(18)';
  const dappStakeAddress = '#root > div > p:nth-child(19)';
  const dappUsedAddress = '#root > div > p:nth-child(20)';

  const { btnGrantAccess, btnActivateWallet1, spanAddress, spanStakeAddress } = selectors;

  let walletAddr = '';
  let walletStakeAddr = '';

  before(async () => {
    await browser.url('/cip95-cardano-wallet-connector');
    await $(checkboxEnableCip95).click();
    await $(btnRefresh).click();
  });

  it('dapp should detect test wallet', async () => {
    await expect($(pWalletFound)).toHaveTextContaining('true');
  });

  describe('dapp can use cip95 wallet api', () => {
    before(async () => {
      await switchToWalletUi();
      await $(btnGrantAccess).click();
      await $(btnActivateWallet1).click();
      await browser.waitUntil(async () => {
        try {
          walletAddr = await $(spanAddress).getText();
          walletStakeAddr = await $(spanStakeAddress).getText();
          return walletAddr.includes('addr');
        } catch {
          return false;
        }
      });
    });

    it('dapp has access to cip95 WalletApi', async () => {
      await browser.switchWindow('✨Demos dApp✨');
      await expect($(pNetworkId)).toHaveText('Network Id (0 = testnet; 1 = mainnet): 0');
      await browser.waitUntil($(liFirstUtxo).isExisting, { timeout: 60_000 });
    });

    it('dapp gets correct addresses from cip95 wallet api', async () => {
      await expect($(dappChangeAddress)).toHaveTextContaining(walletAddr);
      await expect($(dappStakeAddress)).toHaveTextContaining(walletStakeAddr);
      await expect($(dappUsedAddress)).toHaveTextContaining(walletAddr);
    });

    it('getRegisteredPubStakeKeys gets active public stake keys from cip95 wallet api', async () => {
      const dappStakeKey = await $(dappGetRegisteredPubStakeKeys).getText();
      expect(dappStakeKey.length).toBeGreaterThan(0);
    });

    it('getPubDRepKey gets the DRep key from cip95 wallet api', async () => {
      const dappDrepKey = await $(dappGetPubDrepKey).getText();
      expect(dappDrepKey.length).toBeGreaterThan(0);
      await expect($(dappDrepId)).toHaveTextContaining('drep');
    });

    it('supportedExtensions and getExtensions both return cip95', async () => {
      await expect($(liSupportedExtensions)).toHaveTextContaining('95');
      await expect($(liGetExtensions)).toHaveTextContaining('95');
    });
  });
});
