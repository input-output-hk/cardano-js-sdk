import { AssetProvider, Cardano, InvalidStringError, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { AssetQuery, Sdk } from '../../src/sdk';
import { createGraphQLAssetProvider } from '../../src/AssetProvider';

describe('CardanoGraphQLAssetProvider', () => {
  const assetId = Cardano.AssetId('b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a76e7574636f696e');
  let provider: AssetProvider;
  const sdk = {
    Asset: jest.fn()
  };
  beforeEach(() => {
    provider = createGraphQLAssetProvider('http://someurl.com', undefined, () => sdk as unknown as Sdk);
  });
  afterEach(() => {
    sdk.Asset.mockReset();
  });

  describe('getAsset', () => {
    // eslint-disable-next-line max-statements
    it('makes a graphql query and coerces result to core types', async () => {
      const assetQueryResponse: AssetQuery = {
        queryAsset: [
          {
            assetName: '6e7574636f696e',
            fingerprint: 'asset1pkpwyknlvul7az0xx8czhl60pyel45rpje4z8w',
            history: [
              {
                quantity: 100,
                transaction: { hash: '6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99cad' }
              }
            ],
            nftMetadata: {
              descriptions: ['The Nut Coin'],
              files: [{ mediaType: 'image/jpeg', name: 'file', src: ['https://file.location'] }],
              images: ['https://image.location'],
              mediaType: 'image/jpeg',
              name: 'nutcoin',
              version: '1.0'
            },
            policy: { id: 'b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a7' },
            tokenMetadata: {
              decimals: 6,
              desc: 'desc',
              icon: 'https://icon.location',
              name: 'nutcoin',
              ref: 'https://ref.location',
              sizedIcons: [{ icon: 'https://icon.location', size: 64 }],
              ticker: 'nutc',
              url: 'https://url.location',
              version: '1.0'
            },
            totalQuantity: 1000
          }
        ]
      };
      sdk.Asset.mockResolvedValue(assetQueryResponse);
      const response = await provider.getAsset(assetId);

      expect(sdk.Asset).toBeCalledWith({ assetId });
      expect(typeof response).toBe('object');
      expect(typeof response.assetId).toBe('string');
      expect(typeof response.fingerprint).toBe('string');
      expect(typeof response.history![0].quantity).toBe('bigint');
      expect(typeof response.history![0].transactionId).toBe('string');
      expect(typeof response.name).toBe('string');
      expect(typeof response.quantity).toBe('bigint');
      expect(typeof response.tokenMetadata).toBe('object');
      expect(typeof response.tokenMetadata?.decimals).toBe('number');
      expect(typeof response.tokenMetadata?.desc).toBe('string');
      expect(typeof response.tokenMetadata?.icon).toBe('string');
      expect(typeof response.tokenMetadata?.name).toBe('string');
      expect(typeof response.tokenMetadata?.ref).toBe('string');
      expect(typeof response.tokenMetadata?.sizedIcons![0].icon).toBe('string');
      expect(typeof response.tokenMetadata?.sizedIcons![0].size).toBe('number');
      expect(typeof response.tokenMetadata?.ticker).toBe('string');
      expect(typeof response.tokenMetadata?.url).toBe('string');
      expect(typeof response.tokenMetadata?.version).toBe('string');
      expect(typeof response.nftMetadata?.description![0]).toBe('string');
      expect(typeof response.nftMetadata?.files![0].mediaType).toBe('string');
      expect(typeof response.nftMetadata?.files![0].name).toBe('string');
      expect(typeof response.nftMetadata?.files![0].src[0]).toBe('string');
      expect(typeof response.nftMetadata?.image![0]).toBe('string');
      expect(typeof response.nftMetadata?.mediaType).toBe('string');
      expect(typeof response.nftMetadata?.name).toBe('string');
      expect(typeof response.nftMetadata?.version).toBe('string');
    });

    it('wraps errors to ProviderError', async () => {
      sdk.Asset.mockRejectedValueOnce(new Error('some error'));
      await expect(provider.getAsset(assetId)).rejects.toThrowError(ProviderError);

      const invalidStringError = new InvalidStringError('some error');
      sdk.Asset.mockRejectedValueOnce(invalidStringError);
      await expect(provider.getAsset(assetId)).rejects.toThrowError(
        new ProviderError(ProviderFailure.InvalidResponse, invalidStringError)
      );
    });
  });
});
