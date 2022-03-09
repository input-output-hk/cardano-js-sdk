import { Cardano, testnetTimeSettings } from '@cardano-sdk/core';
import { KeyManagement, SingleAddressWallet, SingleAddressWalletProps, TransactionFailure } from '../../src';
import { createStubStakePoolSearchProvider, createStubTimeSettingsProvider } from '@cardano-sdk/util-dev';
import { firstValueFrom } from 'rxjs';
import { mockAssetProvider, mockTxSubmitProvider, mockWalletProvider } from '../mocks';

const walletProps: SingleAddressWalletProps = { name: 'some-wallet' };
const networkId = Cardano.NetworkId.mainnet;
const mnemonicWords = KeyManagement.util.generateMnemonicWords();
const getPassword = async () => Buffer.from('your_password');

describe('integration/withdrawal', () => {
  let keyAgent: KeyManagement.KeyAgent;
  let wallet: SingleAddressWallet;

  beforeAll(async () => {
    keyAgent = await KeyManagement.InMemoryKeyAgent.fromBip39MnemonicWords({
      getPassword,
      mnemonicWords,
      networkId
    });
    const txSubmitProvider = mockTxSubmitProvider();
    const walletProvider = mockWalletProvider();
    const stakePoolSearchProvider = createStubStakePoolSearchProvider();
    const timeSettingsProvider = createStubTimeSettingsProvider(testnetTimeSettings);
    const assetProvider = mockAssetProvider();
    wallet = new SingleAddressWallet(walletProps, {
      assetProvider,
      keyAgent,
      stakePoolSearchProvider,
      timeSettingsProvider,
      txSubmitProvider,
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

    const rewardAccount = (await firstValueFrom(wallet.addresses$))[0].rewardAccount;
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
