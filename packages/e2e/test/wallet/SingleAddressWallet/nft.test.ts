/* eslint-disable sonarjs/no-duplicate-string */
import { Cardano } from '@cardano-sdk/core';
import { KeyManagement, ObservableWallet, SingleAddressWallet } from '@cardano-sdk/wallet';
import {
  assetProvider,
  chainHistoryProvider,
  keyAgent,
  networkInfoProvider,
  rewardsProvider,
  stakePoolProvider,
  txSubmitProvider,
  utxoProvider,
  walletProvider
} from '../../config';
import { combineLatest, filter, firstValueFrom, map, of } from 'rxjs';

describe('SingleAddressWallet.assets/nft', () => {
  let wallet: ObservableWallet;

  beforeAll(async () => {
    const _keyAgent = await keyAgent;
    _keyAgent.knownAddresses$ = of([
      {
        accountIndex: 0,
        address: Cardano.Address(
          // eslint-disable-next-line max-len
          'addr_test1qpapna8hhj2hx2q2s9mdp7995a3hgundyvvvj0v0yq68lt8e6dgndgyep9stycsnejcnu8vm7a6dtqqhmf362z7fy5ksg46rum'
        ),
        index: 0,
        networkId: Cardano.NetworkId.testnet,
        rewardAccount: Cardano.RewardAccount('stake_test1uruax5fk5zvsjc9jvgfuevf7rkdlwax4sqta5ca9p0yj2tg4cf29e'),
        type: KeyManagement.AddressType.External
      }
    ]);
    wallet = new SingleAddressWallet(
      {
        name: 'Test Wallet'
      },
      {
        assetProvider: await assetProvider,
        chainHistoryProvider: await chainHistoryProvider,
        keyAgent: _keyAgent,
        networkInfoProvider: await networkInfoProvider,
        rewardsProvider: await rewardsProvider,
        stakePoolProvider: await stakePoolProvider,
        txSubmitProvider: await txSubmitProvider,
        utxoProvider: await utxoProvider,
        walletProvider: await walletProvider
      }
    );
  });

  afterAll(() => {
    wallet.shutdown();
  });

  it('supports multiple CIP-25 NFT metadata in one tx', async () => {
    const nfts = await firstValueFrom(
      combineLatest([wallet.assets$, wallet.balance.total$]).pipe(
        filter(([assets, balance]) => assets.size === balance.assets?.size),
        map(([assets]) => [...assets.values()].filter((asset) => !!asset.nftMetadata))
      )
    );
    expect(nfts.find((nft) => nft.nftMetadata!.name === 'One')).toEqual({
      assetId: 'd1ac67dcebc491ce17635d3d9c8775eb739325ce522f6eac733489aa4e4654303031',
      fingerprint: 'asset15wsawsn72dw07m33fqp42suze636mv2k4agxvs',
      history: undefined,
      mintOrBurnCount: 1,
      name: '4e4654303031',
      nftMetadata: {
        description: undefined,
        files: undefined,
        image: ['ipfs://some_hash1'],
        mediaType: undefined,
        name: 'One',
        version: '1.0'
      },
      otherProperties: undefined,
      policyId: 'd1ac67dcebc491ce17635d3d9c8775eb739325ce522f6eac733489aa',
      quantity: 1n,
      tokenMetadata: { desc: undefined, icon: 'ipfs://some_hash1', name: 'One' }
    });
    expect(nfts.find((nft) => nft.nftMetadata!.name === 'Two')).toBeDefined();
  });

  it('parses CIP-25 NFT metadata with files', async () => {
    const nfts = await firstValueFrom(
      combineLatest([wallet.assets$, wallet.balance.total$]).pipe(
        filter(([assets, balance]) => assets.size === balance.assets?.size),
        map(([assets]) => [...assets.values()].filter((asset) => !!asset.nftMetadata))
      )
    );
    expect(nfts.find((nft) => nft.nftMetadata!.name === 'NFT with files')).toEqual({
      assetId: 'e80c05f27dec74e8c04f27bdf711dff8ae03167dda9b7760b7d92cef4e46542d66696c6573',
      fingerprint: 'asset16w7fcptllh5qfgux8hmp3wymne7xh5y65vxueh',
      history: undefined,
      mintOrBurnCount: 1,
      name: '4e46542d66696c6573',
      nftMetadata: {
        description: ['NFT with different types of files'],
        files: [
          {
            mediaType: 'video/mp4',
            name: 'some name',
            src: ['file://some_video_file']
          },
          {
            mediaType: 'audio/mpeg',
            name: 'some name',
            src: ['file://some_audio_file', 'file://another_audio_file']
          }
        ],
        image: ['ipfs://somehash'],
        mediaType: 'image/png',
        name: 'NFT with files',
        otherProperties: new Map([['id', '1']]),
        version: '1.0'
      },
      otherProperties: undefined,
      policyId: 'e80c05f27dec74e8c04f27bdf711dff8ae03167dda9b7760b7d92cef',
      quantity: 1n,
      tokenMetadata: {
        desc: 'NFT with different types of files',
        description: 'NFT with different types of files',
        files: [
          {
            mediaType: 'video/mp4',
            name: 'some name',
            src: 'file://some_video_file'
          },
          {
            mediaType: 'audio/mpeg',
            name: 'some name',
            src: ['file://some_audio_file', 'file://another_audio_file']
          }
        ],
        icon: 'ipfs://somehash',
        id: '1',
        mediaType: 'image/png',
        name: 'NFT with files'
      }
    });
  });
});
