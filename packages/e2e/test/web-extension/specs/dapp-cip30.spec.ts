import { selectors } from '../extension/const.js';
import { switchToWalletUi } from './utils.js';

describe('dapp/cip30', () => {
  const pWalletFound = '#root > div > p:nth-child(4)';
  const btnRefresh = '#root > div > button';
  const pNetworkId = '#root > div > p:nth-child(8)';
  const liFirstUtxo = '#root > div > p:nth-child(9) > li';

  const dappBtnRun = '#bp3-tab-panel_TabsExample_1 > div > button';
  const dappSubmittedTxConfirmation = '#root > div > p:last-child';
  const dappChangeAddress = '#root > div > p:nth-child(11)';
  const dappStakeAddress = '#root > div > p:nth-child(12)';
  const dappUsedAddress = '#root > div > p:nth-child(13)';

  const { btnGrantAccess, btnActivateWallet1, spanAddress, spanStakeAddress } = selectors;

  let walletAddr = '';
  let walletStakeAddr = '';

  before(async () => {
    await browser.url('/');
    await $(btnRefresh).click();
  });

  it('dapp should detect test wallet', async () => {
    await expect($(pWalletFound)).toHaveTextContaining('true');
  });

  describe('dapp can use cip30 wallet api', () => {
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

    it('dapp has access to cip30 WalletApi', async () => {
      await browser.switchWindow('React App');
      await expect($(pNetworkId)).toHaveText('Network Id (0 = testnet; 1 = mainnet): 0');
      await browser.waitUntil($(liFirstUtxo).isExisting, { timeout: 60_000 });
    });

    it('dapp gets correct addresses from cip30 wallet api', async () => {
      await expect($(dappChangeAddress)).toHaveTextContaining(walletAddr);
      await expect($(dappStakeAddress)).toHaveTextContaining(walletStakeAddr);
      await expect($(dappUsedAddress)).toHaveTextContaining(walletAddr);
    });

    it('dapp can build and send a transaction using cip30 WalletApi', async () => {
      await $(dappBtnRun).click();
      await expect($(dappSubmittedTxConfirmation)).toHaveTextContaining('check your wallet');
    });
  });
});
