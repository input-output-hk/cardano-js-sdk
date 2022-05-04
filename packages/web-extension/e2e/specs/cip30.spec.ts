describe('cip30', () => {
  const pWalletFound = '#root > div > p:nth-child(4)';
  const btnRefresh = '#root > div > button';
  const pNetworkId = '#root > div > p:nth-child(8)';
  const liFirstUtxo = '#root > div > p:nth-child(9) > li';
  const btnGrantAccess = '#requestAccessGrant';

  before(async () => {
    await browser.url('/');
    await $(btnRefresh).click();
  });

  it('should detect test wallet', async () => {
    await expect($(pWalletFound)).toHaveTextContaining('true');
  });

  describe('dapp allowed', () => {
    before(async () => {
      await browser.switchWindow('Test Wallet UI');
      await $(btnGrantAccess).click();
      await browser.switchWindow('React App');
    });

    it('should display networkId and a list of utxo', async () => {
      await expect($(pNetworkId)).toHaveText('Network Id (0 = testnet; 1 = mainnet): 0');
      await expect($(liFirstUtxo)).toExist();
    });
  });
});
