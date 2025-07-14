/* eslint-disable sonarjs/no-duplicate-string */
import { Asset, Cardano } from '@cardano-sdk/core';
import type { Responses } from '@blockfrost/blockfrost-js';

import { BlockfrostAssetProvider } from '../../src';
import { BlockfrostClient } from '../../src/blockfrost/BlockfrostClient';
import { logger } from '@cardano-sdk/util-dev';
import { mockResponses } from '../util';

describe('BlockfrostAssetProvider', () => {
  let request: jest.Mock;
  let provider: BlockfrostAssetProvider;

  beforeEach(() => {
    request = jest.fn();
    const client = { request } as unknown as BlockfrostClient;
    provider = new BlockfrostAssetProvider(client, logger);
  });

  describe('getAsset', () => {
    const mockedAssetId = Cardano.AssetId('b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a76e7574636f696e');
    const mockedAssetResponse = {
      asset: mockedAssetId,
      asset_name: Cardano.AssetId.getAssetName(mockedAssetId),
      fingerprint: 'asset1pkpwyknlvul7az0xx8czhl60pyel45rpje4z8w',
      initial_mint_tx_hash: '6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99cad',
      metadata: {
        decimals: 6,
        description: 'The Nut Coin',
        logo: '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',
        name: 'nutcoin',
        ticker: 'nutc',
        url: 'https://www.stakenuts.com/'
      },
      mint_or_burn_count: 1,
      onchain_metadata: {
        image: 'ipfs://QmfKyJ4tuvHowwKQCbCHj4L5T3fSj8cjs7Aau8V7BWv226',
        name: 'My NFT token'
      },
      policy_id: Cardano.AssetId.getPolicyId(mockedAssetId),
      quantity: '12000'
    } as Responses['asset'];

    test('combines onchain and offchain metadata', async () => {
      mockResponses(request, [[`assets/${mockedAssetResponse.asset}`, mockedAssetResponse]]);

      const response = await provider.getAsset({
        assetId: mockedAssetId,
        extraData: { nftMetadata: true, tokenMetadata: true }
      });

      expect(response).toMatchObject<Asset.AssetInfo>({
        assetId: mockedAssetId,
        fingerprint: Cardano.AssetFingerprint('asset1pkpwyknlvul7az0xx8czhl60pyel45rpje4z8w'),
        name: Cardano.AssetName('6e7574636f696e'),
        nftMetadata: {
          description: 'The Nut Coin',
          image: Asset.Uri('ipfs://QmfKyJ4tuvHowwKQCbCHj4L5T3fSj8cjs7Aau8V7BWv226'),
          name: 'My NFT token',
          version: '1.0'
        },
        policyId: Cardano.PolicyId('b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a7'),
        quantity: 12_000n,
        supply: 12_000n,
        tokenMetadata: {
          assetId: mockedAssetId,
          decimals: 6,
          desc: 'The Nut Coin',
          icon: mockedAssetResponse.onchain_metadata?.image as string,
          name: mockedAssetResponse.onchain_metadata?.name as string,
          ticker: 'nutc',
          url: 'https://www.stakenuts.com/'
        }
      });
    });

    test('has nft metadata', async () => {
      mockResponses(request, [
        [
          `assets/${mockedAssetResponse.asset}`,
          {
            ...mockedAssetResponse,
            metadata: undefined,
            onchain_metadata: {
              image: ['ipfs://image'],
              name: 'test nft',
              version: '1.0'
            }
          }
        ]
      ]);

      const response = await provider.getAsset({
        assetId: mockedAssetId,
        extraData: { nftMetadata: true, tokenMetadata: true }
      });
      expect(response).toMatchObject<Asset.AssetInfo>({
        assetId: mockedAssetId,
        fingerprint: Cardano.AssetFingerprint('asset1pkpwyknlvul7az0xx8czhl60pyel45rpje4z8w'),
        name: Cardano.AssetName('6e7574636f696e'),
        nftMetadata: {
          image: Asset.Uri('ipfs://image'),
          name: 'test nft',
          version: '1.0'
        },
        policyId: Cardano.PolicyId('b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a7'),
        quantity: 12_000n,
        supply: 12_000n
      });
    });

    test('no extra data', async () => {
      mockResponses(request, [[`assets/${mockedAssetResponse.asset}`, mockedAssetResponse]]);

      const response = await provider.getAsset({
        assetId: mockedAssetId,
        extraData: { nftMetadata: false, tokenMetadata: false }
      });

      expect(response).toMatchObject<Asset.AssetInfo>({
        assetId: mockedAssetId,
        fingerprint: Cardano.AssetFingerprint('asset1pkpwyknlvul7az0xx8czhl60pyel45rpje4z8w'),
        name: Cardano.AssetName('6e7574636f696e'),
        nftMetadata: null,
        policyId: Cardano.PolicyId('b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a7'),
        quantity: 12_000n,
        supply: 12_000n,
        tokenMetadata: null
      });
    });

    test('description and image as array', async () => {
      mockResponses(request, [
        [
          'assets/8153f8be9f05b2f32b481bbf7af877f592160b39e87f5f55c8ab035f4e46543031',
          {
            asset: '8153f8be9f05b2f32b481bbf7af877f592160b39e87f5f55c8ab035f4e46543031',
            asset_name: '4e46543031',
            fingerprint: 'asset1h2z87pq2tr4ksxl5nkzd2ltrrtd6vvmf5nnn46',
            onchain_metadata: {
              description: ['long ', 'description'],
              image: ['ipfs://', 'QmRhTTbUrPYEw3mJGGhQqQST9k86v1DPBiTTWJGKDJsVFw'],
              name: 'test nft',
              version: '1.0'
            },
            policy_id: '8153f8be9f05b2f32b481bbf7af877f592160b39e87f5f55c8ab035f',
            quantity: 1
          }
        ]
      ]);

      const response = await provider.getAsset({
        assetId: Cardano.AssetId('8153f8be9f05b2f32b481bbf7af877f592160b39e87f5f55c8ab035f4e46543031'),
        extraData: { nftMetadata: true, tokenMetadata: false }
      });
      expect(response).toMatchObject<Asset.AssetInfo>({
        assetId: Cardano.AssetId('8153f8be9f05b2f32b481bbf7af877f592160b39e87f5f55c8ab035f4e46543031'),
        fingerprint: Cardano.AssetFingerprint('asset1h2z87pq2tr4ksxl5nkzd2ltrrtd6vvmf5nnn46'),
        name: Cardano.AssetName('4e46543031'),
        nftMetadata: {
          description: 'long description',
          image: Asset.Uri('ipfs://QmRhTTbUrPYEw3mJGGhQqQST9k86v1DPBiTTWJGKDJsVFw'),
          name: 'test nft',
          version: '1.0'
        },
        policyId: Cardano.PolicyId('8153f8be9f05b2f32b481bbf7af877f592160b39e87f5f55c8ab035f'),
        quantity: 1n,
        supply: 1n,
        tokenMetadata: null
      });
    });

    test('file src as array', async () => {
      mockResponses(request, [
        [
          `assets/${mockedAssetId}`,
          {
            ...mockedAssetResponse,
            onchain_metadata: {
              ...mockedAssetResponse.onchain_metadata,
              files: [{ image: 'should be in other properties', mediaType: 'image/png', src: ['http://', 'some.png'] }]
            }
          }
        ]
      ]);

      const response = await provider.getAsset({
        assetId: mockedAssetId,
        extraData: { nftMetadata: true }
      });

      expect(response.nftMetadata!.files![0].src).toBe('http://some.png');
      expect(response.nftMetadata!.files![0].otherProperties?.get('image')).toBe('should be in other properties');
    });

    test('version', async () => {
      mockResponses(request, [
        [
          `assets/${mockedAssetId}`,
          {
            ...mockedAssetResponse,
            onchain_metadata: {
              ...mockedAssetResponse.onchain_metadata,
              version: '2.0'
            }
          }
        ]
      ]);

      const response = await provider.getAsset({
        assetId: mockedAssetId,
        extraData: { nftMetadata: true }
      });

      expect(response.nftMetadata!.version).toBe('2.0');
    });

    describe('onchain_metadata undefined values', () => {
      const mockedAssetIdOnChainMetadata = Cardano.AssetId(
        'ecbe846aa1a535579d67f9480fa6173b64d7e239df0460eba36e3ad00014df1053617475726e'
      );

      const baseResponse = {
        asset: mockedAssetIdOnChainMetadata,
        asset_name: '0014df1053617475726e',
        fingerprint: 'asset1lnu3hw2pjw8xfprg7722mh0yu2vfzvk8ta60h0',
        initial_mint_tx_hash: 'dcdd8ed32a71523a8393caab9d657964e50648fe0277de77add22b839e6fdb88',
        metadata: null,
        mint_or_burn_count: 1,
        onchain_metadata: {
          decimals: 6,
          description:
            'Saturn is the governance token for the Saturn Swap protocol, a fast and simple decentralized exchange on the Cardano blockchain. https://saturnswap.io/',
          logo: 'ipfs://Qmc2RWQxCmAaXn7YGZsXCcs2J5uwW8qQwYzmjh1gUiZBWA',
          mediaType: '49696d6167652f706e67',
          name: 'Saturn',
          ticker: 'SATURN',
          url: 'ipfs://Qmc2RWQxCmAaXn7YGZsXCcs2J5'
        },
        onchain_metadata_extra: 'd8799fff',
        onchain_metadata_standard: 'CIP68v1',
        policy_id: 'ecbe846aa1a535579d67f9480fa6173b64d7e239df0460eba36e3ad0',
        quantity: '100000000000000'
      } as Responses['asset'];

      test('handles undefined onchain_metadata.decimals', async () => {
        const responseWithUndefinedDecimals = {
          ...baseResponse,
          onchain_metadata: {
            ...baseResponse.onchain_metadata,
            decimals: undefined
          }
        };

        mockResponses(request, [[`assets/${mockedAssetIdOnChainMetadata}`, responseWithUndefinedDecimals]]);

        const response = await provider.getAsset({
          assetId: mockedAssetIdOnChainMetadata,
          extraData: { tokenMetadata: true }
        });

        expect(response.tokenMetadata!.decimals).toBeUndefined();
        expect(response.tokenMetadata!.ticker).toBe('SATURN');
        expect(response.tokenMetadata!.url).toBe('ipfs://Qmc2RWQxCmAaXn7YGZsXCcs2J5');
      });

      test('handles undefined onchain_metadata.ticker', async () => {
        const responseWithUndefinedTicker = {
          ...baseResponse,
          onchain_metadata: {
            ...baseResponse.onchain_metadata,
            ticker: undefined
          }
        };

        mockResponses(request, [[`assets/${mockedAssetIdOnChainMetadata}`, responseWithUndefinedTicker]]);

        const response = await provider.getAsset({
          assetId: mockedAssetIdOnChainMetadata,
          extraData: { tokenMetadata: true }
        });

        expect(response.tokenMetadata!.decimals).toBe(6);
        expect(response.tokenMetadata!.ticker).toBeUndefined();
        expect(response.tokenMetadata!.url).toBe('ipfs://Qmc2RWQxCmAaXn7YGZsXCcs2J5');
      });

      test('handles undefined onchain_metadata.url', async () => {
        const responseWithUndefinedUrl = {
          ...baseResponse,
          onchain_metadata: {
            ...baseResponse.onchain_metadata,
            url: undefined
          }
        };

        mockResponses(request, [[`assets/${mockedAssetIdOnChainMetadata}`, responseWithUndefinedUrl]]);

        const response = await provider.getAsset({
          assetId: mockedAssetIdOnChainMetadata,
          extraData: { tokenMetadata: true }
        });

        expect(response.tokenMetadata!.decimals).toBe(6);
        expect(response.tokenMetadata!.ticker).toBe('SATURN');
        expect(response.tokenMetadata!.url).toBeUndefined();
      });
    });
  });
});
