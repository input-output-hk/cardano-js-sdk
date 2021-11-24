import { Cardano } from '@cardano-sdk/core';
import { KeyManagement, SingleAddressWallet, SingleAddressWalletProps, TransactionFailure } from '../../src';
import { createStubStakePoolSearchProvider } from '@cardano-sdk/util-dev';
import { firstValueFrom } from 'rxjs';
import { mockAssetProvider, mockWalletProvider } from '../mocks';

const walletProps: SingleAddressWalletProps = { name: 'some-wallet' };
const networkId = Cardano.NetworkId.mainnet;
const mnemonicWords = KeyManagement.util.generateMnemonicWords();
const password = 'your_password';

describe('integration/withdrawal', () => {
  let keyManager: KeyManagement.KeyManager;
  let wallet: SingleAddressWallet;

  beforeAll(async () => {
    keyManager = KeyManagement.createInMemoryKeyManager({ mnemonicWords, networkId, password });
    const walletProvider = mockWalletProvider();
    const stakePoolSearchProvider = createStubStakePoolSearchProvider();
    const assetProvider = mockAssetProvider();
    wallet = new SingleAddressWallet(walletProps, {
      assetProvider,
      keyManager,
      stakePoolSearchProvider,
      walletProvider
    });
  });

  it('has balance', async () => {
    await firstValueFrom(wallet.balance.total$);
    expect(typeof wallet.balance.total$.value?.coins).toBe('bigint');
    expect(typeof wallet.balance.available$.value?.rewards).toBe('bigint');
  });

  it('can submit transaction', async () => {
    await firstValueFrom(wallet.balance.available$);
    const availableRewards = wallet.balance.available$.value!.rewards;

    const rewardAccount = wallet.addresses$.value[0].rewardAccount;
    const txInternals = await wallet.initializeTx({
      certificates: [{ __typename: Cardano.CertificateType.StakeKeyDeregistration, rewardAccount }],
      outputs: new Set(), // In a real transaction you would probably want to have some outputs
      withdrawals: [{ quantity: availableRewards, stakeAddress: rewardAccount }]
    });
    expect(typeof txInternals.body.fee).toBe('bigint');
    const tx = await wallet.finalizeTx(txInternals);

    const confirmedSubscription = wallet.transactions.outgoing.confirmed$.subscribe((confirmedTx) => {
      if (confirmedTx === tx) {
        // Transaction successful
      }
    });

    const failedSubscription = wallet.transactions.outgoing.failed$.subscribe(({ tx: failedTx, reason }) => {
      if (failedTx === tx) {
        // Transaction failed because of reason, which is most likely:
        expect(reason === TransactionFailure.Timeout || reason === TransactionFailure.FailedToSubmit).toBe(true);
      }
    });

    try {
      await wallet.submitTx(tx);
    } catch {
      // Failed to submit transaction
    }

    // Cleanup
    confirmedSubscription.unsubscribe();
    failedSubscription.unsubscribe();
    wallet.shutdown();
  });
});
