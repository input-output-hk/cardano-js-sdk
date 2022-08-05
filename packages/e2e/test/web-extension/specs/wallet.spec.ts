describe('wallet', () => {
  const pWalletFound = '#root > div > p:nth-child(4)';
  const btnRefresh = '#root > div > button';
  const pNetworkId = '#root > div > p:nth-child(8)';
  const liFirstUtxo = '#root > div > p:nth-child(9) > li';
  const btnGrantAccess = '#requestAccessGrant';
  const btnCreateKeyAgent = '#createKeyAgent';
  const spanAddress = '#address';
  const spanBalance = '#balance';
  const spanSupplyDistribution = '#supplyDistribution';
  const divAdaPrice = '#adaPrice';
  const btnSignAndBuildTx = '#buildAndSignTx';
  const divSignature = '#signature';

  before(async () => {
    await browser.url('/');
    await $(btnRefresh).click();
  });

  it('dapp should detect test wallet', async () => {
    await expect($(pWalletFound)).toHaveTextContaining('true');
  });

  describe('wallet ui opens', () => {
    before(async () => {
      await browser.switchWindow('Test Wallet UI');
    });

    it('should display ADA price, provided by background process', async () => {
      await expect($(divAdaPrice)).toHaveText('2.99');
    });

    describe('ui grants access and creates key agent', () => {
      before(async () => {
        await $(btnGrantAccess).click();
        await $(btnCreateKeyAgent).click();
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
        await expect($(spanAddress)).toHaveTextContaining('addr');
      });
      it('can build and sign a transaction', async () => {
        await $(btnSignAndBuildTx).click();
        await browser.waitUntil(async () => {
          const signature = await $(divSignature).getText();
          return signature.length > 1;
        });
      });
      it('dapp has access to cip30 WalletApi', async () => {
        await browser.switchWindow('React App');
        await expect($(pNetworkId)).toHaveText('Network Id (0 = testnet; 1 = mainnet): 0');
        await browser.waitUntil($(liFirstUtxo).isExisting, { timeout: 60_000 });
      });
    });
  });
});
