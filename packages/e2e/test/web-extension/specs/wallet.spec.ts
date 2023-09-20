/* eslint-disable max-statements */
import { getObservableWalletName, selectors } from '../extension/const';
import { switchToWalletUi } from './utils';

const NUM_POOLS = 3;

describe('wallet', () => {
  const {
    btnActivateWallet1,
    btnActivateWallet2,
    btnDelegate,
    deactivateWallet,
    destroyWallet,
    spanAddress,
    spanStakeAddress,
    spanBalance,
    spanSupplyDistribution,
    divAdaPrice,
    btnSignAndBuildTx,
    divSignature,
    activeWalletName,
    spanPoolIds,
    liPools,
    liPercents,
    divBgPortDisconnectStatus,
    divUiPortDisconnectStatus,
    btnSignDataWithDRepId,
    divDataSignature
  } = selectors;

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

  // eslint-disable-next-line unicorn/consistent-function-scoping
  const refreshDappWallets = async () => {
    const btnRefresh = '#root > div > button';
    await $(btnRefresh).click();
  };

  describe('wallet ui opens', () => {
    before(async () => {
      await browser.url('/');
      await refreshDappWallets(); // still needed to trigger opening the extension ui
      await switchToWalletUi();
    });

    it('should handle remoteApi disconnects as Promise.rejects', async () => {
      await expect($(divBgPortDisconnectStatus)).toHaveText('Background port disconnect -> Promise rejects');
      await expect($(divUiPortDisconnectStatus)).toHaveText('UI script port disconnect -> Promise rejects');
    });

    it('should display ADA price, provided by background process', async () => {
      await expect($(divAdaPrice)).toHaveText('2.99');
    });

    describe('web-extension activates wallet and creates key agent', () => {
      before(async () => {
        await $(btnActivateWallet1).click();
      });
      it('web-extension has access to remote ObservableWallet and SupplyDistribution', async () => {
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
    });

    describe('web-extension can build transactions and use wallet manager', () => {
      it('can build and sign a transaction', async () => {
        await buildAndSign();
      });

      it('can delegate to multiple pools', async () => {
        (await $(btnDelegate)).click();

        // There should be 3 pools available
        await browser.waitUntil(async () => {
          try {
            const poolIds = await $(spanPoolIds).getText();
            return poolIds.split(' ').length === NUM_POOLS;
          } catch {
            return false;
          }
        });

        // Delegation transaction was submitted successfully
        const txId = await $('#multiDelegation .delegateTxId').getText();
        expect(txId).toHaveTextContaining('TxId');

        // Wallet reports delegating to 3 pools
        await browser.waitUntil(
          async () => {
            try {
              const delegatedPools = await $$(liPools);
              return delegatedPools.length === NUM_POOLS;
            } catch {
              return false;
            }
          },
          { timeout: 30_000, timeoutMsg: 'Expected wallet.delegation.distribution to report 3 delegations' }
        );

        // Check wallet delegation distribution is applied and displayed correctly
        const delegationPercents = await $$(liPercents).map((el) => el.getText());
        expect(delegationPercents.map((percent) => Math.round(Number.parseFloat(percent)))).toEqual([10, 30, 60]);
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

      it('can sign data with a DRepID', async () => {
        (await $(btnSignDataWithDRepId)).click();
        const signature = await $(divDataSignature).getText();
        expect(signature).toHaveTextContaining(
          JSON.stringify({
            key: 'a5010102581d60a7484b9d9185af363f9412627c42f47c7ae14e95b3a4603f4c34860403272006215820a76722da33bcd685429f4aca04e57fd1366a0b3410770fc0f5c161934b8ba1af',
            signature:
              '84584aa3012704581d60a7484b9d9185af363f9412627c42f47c7ae14e95b3a4603f4c3486046761646472657373581d60a7484b9d9185af363f9412627c42f47c7ae14e95b3a4603f4c348604a166686173686564f443abc1235840ea25fdcd108a591e67987de272b8c822cd2f9cf621ff1938db594cafb1cfdb879de42a81dab5698c41dd968515583a50d12abc4bbee356a2d6ac97e54e3a680f'
          })
        );
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
