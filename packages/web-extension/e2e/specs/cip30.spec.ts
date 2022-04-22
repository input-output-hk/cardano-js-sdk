describe('cip30', () => {
  const pWalletFound = '#root > div > p:nth-child(4)';

  before(async () => {
    await browser.url('/');
  });

  it('should detect test wallet', async () => {
    await expect($(pWalletFound)).toHaveTextContaining('true');
  });

  it.skip('should open a new tab for wallet ui', async () => {
    await browser.switchWindow('Wallet');
  });
});
