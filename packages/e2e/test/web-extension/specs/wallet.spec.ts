import { getObservableWalletName } from '../extension/const';

const switchToWalletUi = async () => {
  await browser.waitUntil(async () => {
    try {
      await browser.switchWindow('Test Wallet UI');
      return true;
    } catch {
      return false;
    }
  });
};

describe('wallet', () => {
  const pWalletFound = '#root > div > p:nth-child(4)';
  const btnRefresh = '#root > div > button';
  const pNetworkId = '#root > div > p:nth-child(8)';
  const liFirstUtxo = '#root > div > p:nth-child(9) > li';
  const btnGrantAccess = '#requestAccessGrant';
  const btnActivateWallet1 = '#activateWallet1';
  const btnActivateWallet2 = '#activateWallet2';
  const deactivateWallet = '#deactivateWallet';
  const destroyWallet = '#destroyWallet';
  const spanAddress = '#address';
  const spanStakeAddress = '#stakeAddress';

  const spanBalance = '#balance';
  const spanSupplyDistribution = '#supplyDistribution';
  const divAdaPrice = '#adaPrice';
  const btnSignAndBuildTx = '#buildAndSignTx';
  const divSignature = '#signature';
  const activeWalletName = '#observableWalletName';

  const dappBtnRun = '#bp3-tab-panel_TabsExample_1 > div > button';
  const dappSubmittedTxConfirmation = '#root > div > p:last-child';
  const dappChangeAddress = '#root > div > p:nth-child(11)';
  const dappStakingAddress = '#root > div > p:nth-child(12)';
  const dappUsedAddress = '#root > div > p:nth-child(13)';

  // The address is filled in by the tests, which are order dependent
  let walletAddr1 = '';
  let walletStakeAddr1 = '';

  const buildAndSign = async () => {
    await $(btnSignAndBuildTx).click();
    await browser.waitUntil(async () => {
      const signature = await $(divSignature).getText();
      return signature.length > 1;
    });
  };

  before(async () => {
    await browser.url('/');
    await $(btnRefresh).click();
  });

  it('dapp should detect test wallet', async () => {
    await expect($(pWalletFound)).toHaveTextContaining('true');
  });

  describe('wallet ui opens', () => {
    before(async () => {
      await switchToWalletUi();
    });

    it('should display ADA price, provided by background process', async () => {
      await expect($(divAdaPrice)).toHaveText('2.99');
    });

    describe('ui grants access and creates key agent', () => {
      before(async () => {
        await $(btnGrantAccess).click();
        await $(btnActivateWallet1).click();
      });
      it('ui has access to remote ObservableWallet and SupplyDistribution', async () => {
        await browser.waitUntil(async () => {
          try {
            BigInt(await $(spanBalance).getText());
            const stats = await (await $(spanSupplyDistribution)).getText();
            return stats.length > 1;
          } catch {
            return false;
          }
        });
        walletAddr1 = await $(spanAddress).getText();
        walletStakeAddr1 = await $(spanStakeAddress).getText();
        expect(walletAddr1).toHaveTextContaining('addr');
        expect(walletStakeAddr1).toHaveTextContaining('stake');
        await expect($(activeWalletName)).toHaveText(getObservableWalletName(0));
      });
      it('dapp has access to cip30 WalletApi', async () => {
        await browser.switchWindow('React App');
        await expect($(pNetworkId)).toHaveText('Network Id (0 = testnet; 1 = mainnet): 0');
        await browser.waitUntil($(liFirstUtxo).isExisting, { timeout: 60_000 });
      });

      it('dapp can build and send a transaction using cip30 WalletApi', async () => {
        await browser.switchWindow('React App');
        await $(dappBtnRun).click();
        await expect($(dappSubmittedTxConfirmation)).toHaveTextContaining('check your wallet');
      });

      it('dapp gets correct addresses from cip30 wallet api', async () => {
        await expect($(dappChangeAddress)).toHaveTextContaining(walletAddr1);
        await expect($(dappStakingAddress)).toHaveTextContaining(walletStakeAddr1);
        await expect($(dappUsedAddress)).toHaveTextContaining(walletAddr1);
      });

      it('can build and sign a transaction', async () => {
        await switchToWalletUi();
        await buildAndSign();
      });
      it('can switch to another wallet', async () => {
        // Automatically deactivates first wallet, but keeps the store available for future activation
        await $(btnActivateWallet2).click();
        await expect($(spanAddress)).not.toHaveTextContaining(walletAddr1);
        await expect($(spanAddress)).toHaveTextContaining('addr');
        await expect($(activeWalletName)).toHaveText(getObservableWalletName(1));
      });

      // TODO: failing due to empty balance at accountIndex=1
      it.skip('can build and sign a transaction using the new wallet', async () => {
        await buildAndSign();
      });

      it('can destroy second wallet before switching back to the first wallet', async () => {
        // Destroy also clears associated store. Store will be rebuilt during future activation of same wallet
        await $(destroyWallet).click();
        await $(btnActivateWallet1).click();
        await expect($(spanAddress)).toHaveTextContaining(walletAddr1);
        await expect($(activeWalletName)).toHaveText(getObservableWalletName(0));
      });

      it('can deactivate the wallet but keep the store', async () => {
        await $(deactivateWallet).click();
        await expect($(spanAddress)).toHaveText('-');
      });
    });
  });
});
