import { Cardano, createSlotTimeCalc, testnetTimeSettings } from '@cardano-sdk/core';
import { KeyManagement, SingleAddressWallet, SingleAddressWalletProps } from '../../src';
import { createStubStakePoolSearchProvider, createStubTimeSettingsProvider } from '@cardano-sdk/util-dev';
import { firstValueFrom } from 'rxjs';
import { mockAssetProvider, mockTxSubmitProvider, mockWalletProvider } from '../mocks';

const walletProps: SingleAddressWalletProps = { name: 'some-wallet' };
const networkId = Cardano.NetworkId.mainnet;
const mnemonicWords = KeyManagement.util.generateMnemonicWords();
const getPassword = async () => Buffer.from('your_password');

describe('integration/transactionTime', () => {
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

  it('provides utils necessary for computing transaction time', async () => {
    const transactions = await firstValueFrom(wallet.transactions.history.incoming$);
    const timeSettings = await firstValueFrom(wallet.timeSettings$);
    const slotTimeCalc = createSlotTimeCalc(timeSettings);
    const transactionTime = slotTimeCalc(transactions[0].blockHeader.slot);
    expect(typeof transactionTime.getTime()).toBe('number');
  });
});
