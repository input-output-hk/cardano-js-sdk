export const switchToWalletUi = async () => {
  await browser.waitUntil(async () => {
    try {
      await browser.switchWindow('Test Wallet UI');
      return true;
    } catch {
      return false;
    }
  });
};
