import { Cardano } from '@cardano-sdk/core';
import { CommunicationType, KeyAgent, TrezorKeyAgent, restoreKeyAgent, util } from '../../src/KeyManagement';
import { ObservableWallet, SingleAddressWallet } from '../../src';
import { createStubStakePoolProvider } from '@cardano-sdk/util-dev';
import { firstValueFrom } from 'rxjs';
import {
  mockAssetProvider,
  mockChainHistoryProvider,
  mockNetworkInfoProvider,
  mockRewardsProvider,
  mockTxSubmitProvider,
  mockUtxoProvider
} from '../mocks';

const createWallet = (keyAgent: KeyAgent) => {
  const txSubmitProvider = mockTxSubmitProvider();
  const stakePoolProvider = createStubStakePoolProvider();
  const networkInfoProvider = mockNetworkInfoProvider();
  const assetProvider = mockAssetProvider();
  const utxoProvider = mockUtxoProvider();
  const rewardsProvider = mockRewardsProvider();
  const asyncKeyAgent = util.createAsyncKeyAgent(keyAgent);
  const chainHistoryProvider = mockChainHistoryProvider();
  return new SingleAddressWallet(
    { name: 'Wallet1' },
    {
      assetProvider,
      chainHistoryProvider,
      keyAgent: asyncKeyAgent,
      networkInfoProvider,
      rewardsProvider,
      stakePoolProvider,
      txSubmitProvider,
      utxoProvider
    }
  );
};

const getAddress = async (wallet: ObservableWallet) => (await firstValueFrom(wallet.addresses$))[0].address;

describe('TrezorKeyAgent+SingleAddressWallet', () => {
  test('creating and restoring TrezorKeyAgent wallet', async () => {
    const freshKeyAgent = await TrezorKeyAgent.createWithDevice({
      networkId: Cardano.NetworkId.testnet,
      protocolMagic: 1_097_911_063,
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
