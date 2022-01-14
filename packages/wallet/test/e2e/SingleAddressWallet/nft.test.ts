import { Cardano } from '@cardano-sdk/core';
import { KeyManagement, SingleAddressWallet, Wallet } from '../../../src';
import { assetProvider, keyAgentReady, stakePoolSearchProvider, timeSettingsProvider, walletProvider } from '../config';
import { combineLatest, filter, firstValueFrom, map } from 'rxjs';

describe('SingleAddressWallet/delegation', () => {
  let wallet: Wallet;

  beforeAll(async () => {
    wallet = new SingleAddressWallet(
      {
        address: {
          accountIndex: 0,
          address: Cardano.Address(
            // eslint-disable-next-line max-len
            'addr_test1qqlgm2dh3vpv07cjfcyuu6vhaqhf8998qcx6s8ucpkly6f8l0dw5r75vk42mv3ykq8vyjeaanvpytg79xqzymqy5acmqtjmugu'
          ),
          index: 0,
          networkId: Cardano.NetworkId.testnet,
          rewardAccount: Cardano.RewardAccount('stake_test1urlhkh2pl2xt24dkgjtqrkzfv77ekqj950znqpzdsz2wuds0xlsk6'),
          type: KeyManagement.AddressType.External
        },
        name: 'Test Wallet'
      },
      {
        assetProvider,
        keyAgent: await keyAgentReady,
        stakePoolSearchProvider,
        timeSettingsProvider,
        walletProvider
      }
    );
  });

  afterAll(() => wallet.shutdown());

  it('parses simple NFT metadata', async () => {
    const nfts = await firstValueFrom(
      combineLatest([wallet.assets$, wallet.balance.total$]).pipe(
        filter(([assets, balance]) => assets.size === balance.assets?.size), // when all assets loaded
        map(([assets]) => [...assets.values()].filter((asset) => !!asset.nftMetadata))
      )
    );
    expect(nfts.find(({ nftMetadata }) => nftMetadata?.name === 'Test NFT #470')?.nftMetadata).toEqual({
      image: 'ipfs://XXXXYYYYZZZZ',
      name: 'Test NFT #470',
      version: '1.0'
    });
  });

  it.todo('parses NFT metadata "files"');
  it.todo('parses NFT metadata <other_properties> into nftMetadata.otherProperties');
});
