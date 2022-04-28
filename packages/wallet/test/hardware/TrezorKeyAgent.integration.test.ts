import { Cardano } from '@cardano-sdk/core';
import { CommunicationType, KeyAgent, TrezorKeyAgent, restoreKeyAgent } from '../../src/KeyManagement';
import { SingleAddressWallet, Wallet } from '../../src';
import { createStubStakePoolSearchProvider } from '@cardano-sdk/util-dev';
import { firstValueFrom } from 'rxjs';
import { mockAssetProvider, mockNetworkInfoProvider, mockTxSubmitProvider, mockWalletProvider } from '../mocks';

const createWallet = (keyAgent: KeyAgent) => {
  const txSubmitProvider = mockTxSubmitProvider();
  const walletProvider = mockWalletProvider();
  const stakePoolSearchProvider = createStubStakePoolSearchProvider();
  const networkInfoProvider = mockNetworkInfoProvider();
  const assetProvider = mockAssetProvider();
  return new SingleAddressWallet(
    { name: 'Wallet1' },
    {
      assetProvider,
      keyAgent,
      networkInfoProvider,
      stakePoolSearchProvider,
      txSubmitProvider,
      walletProvider
    }
  );
};

const getAddress = async (wallet: Wallet) => (await firstValueFrom(wallet.addresses$))[0].address;

describe('TrezorKeyAgent+SingleAddressWallet', () => {
  test('creating and restoring TrezorKeyAgent wallet', async () => {
    const freshKeyAgent = await TrezorKeyAgent.createWithDevice({
      networkId: Cardano.NetworkId.testnet,
      trezorConfig: {
        communicationType: CommunicationType.Node,
        manifest: {
          appUrl: 'https://your.application.com',
          email: 'email@developer.com'
        }
      }
    });
    const freshWallet = createWallet(freshKeyAgent);
    const restoredKeyAgent = await restoreKeyAgent(freshKeyAgent.serializableData);
    const restoredWallet = createWallet(restoredKeyAgent);
    expect(await getAddress(freshWallet)).toEqual(await getAddress(restoredWallet));
    freshWallet.shutdown();
    restoredWallet.shutdown();
  });
});
