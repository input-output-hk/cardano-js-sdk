import { Cardano, testnetTimeSettings } from '@cardano-sdk/core';
import { CommunicationType, KeyAgent, LedgerKeyAgent, restoreKeyAgent } from '../../src/KeyManagement';
import { SingleAddressWallet, Wallet } from '../../src';
import { createStubStakePoolSearchProvider, createStubTimeSettingsProvider } from '@cardano-sdk/util-dev';
import { firstValueFrom } from 'rxjs';
import { mockAssetProvider, mockTxSubmitProvider, mockWalletProvider } from '../mocks';

const createWallet = (keyAgent: KeyAgent) => {
  const txSubmitProvider = mockTxSubmitProvider();
  const walletProvider = mockWalletProvider();
  const stakePoolSearchProvider = createStubStakePoolSearchProvider();
  const timeSettingsProvider = createStubTimeSettingsProvider(testnetTimeSettings);
  const assetProvider = mockAssetProvider();
  return new SingleAddressWallet(
    { name: 'Wallet1' },
    {
      assetProvider,
      keyAgent,
      stakePoolSearchProvider,
      timeSettingsProvider,
      txSubmitProvider,
      walletProvider
    }
  );
};

const getAddress = async (wallet: Wallet) => (await firstValueFrom(wallet.addresses$))[0].address;

describe('LedgerKeyAgent+SingleAddressWallet', () => {
  test('creating and restoring LedgerKeyAgent wallet', async () => {
    const freshKeyAgent = await LedgerKeyAgent.createWithDevice({
      communicationType: CommunicationType.Node,
      networkId: Cardano.NetworkId.testnet
    });
    const freshWallet = createWallet(freshKeyAgent);
    const restoredKeyAgent = await restoreKeyAgent(freshKeyAgent.serializableData);
    const restoredWallet = createWallet(restoredKeyAgent);
    expect(await getAddress(freshWallet)).toEqual(await getAddress(restoredWallet));
    // TODO: finalizeTx with both wallets, assert that signature equals
    freshWallet.shutdown();
    restoredWallet.shutdown();
  });
});
