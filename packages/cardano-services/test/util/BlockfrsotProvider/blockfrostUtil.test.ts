import { Cardano, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import {
  blockfrostMetadataToTxMetadata,
  blockfrostToProviderError,
  fetchSequentially,
  isBlockfrostNotFoundError
} from '../../../src/util';

describe('util', () => {
  describe('blockfrostToProviderError', () => {
    it('forbidden', () => {
      const errorContent = {
        error: 'Forbidden',
        message: 'Invalid project token.',
        status_code: 403
      };
      const result = blockfrostToProviderError(errorContent);

      expect(result).toEqual(new ProviderError(ProviderFailure.Forbidden, errorContent, errorContent.message));
    });

    it('not found', () => {
      const errorContent = {
        error: 'Not Found',
        message: 'The requested component has not been found.',
        status_code: 404
      };
      const result = blockfrostToProviderError(errorContent);

      expect(result).toEqual(new ProviderError(ProviderFailure.NotFound, errorContent, errorContent.message));
    });

    it('bad request', () => {
      const errorContent = {
        error: 'Bad Request',
        message: 'Backend did not understand your request.',
        status_code: 400
      };
      const result = blockfrostToProviderError(errorContent);

      expect(result).toEqual(new ProviderError(ProviderFailure.BadRequest, errorContent, errorContent.message));
    });

    it('can handle unknown', () => {
      const errorContent = {
        myFormat: 'is uknown'
      };
      expect(blockfrostToProviderError(errorContent).reason).toBe(ProviderFailure.Unknown);
    });
  });

  describe('isBlockfrostNotFoundError', () => {
    it('can identify positives', () => {
      const errorContent = {
        error: 'Not Found',
        message: 'The requested component has not been found.',
        status_code: 404,
        url: 'some-url'
      };
      expect(isBlockfrostNotFoundError(errorContent)).toBe(true);
    });

    it('can identify negatives', () => {
      const errorContent = {
        error: 'Bad Request',
        message: 'Backend did not understand your request.',
        status_code: 400
      };
      expect(isBlockfrostNotFoundError(errorContent)).toBe(false);
    });

    it('can handle unknown', () => {
      const errorContent = {
        myFormat: 'is uknown'
      };
      expect(isBlockfrostNotFoundError(errorContent)).toBe(false);
    });
  });

  test('fetchSequentially', async () => {
    const batch1 = [{ a: 1 }, { a: 2 }];
    const batch2 = [{ a: 3 }, { a: 4 }];
    const batch3 = [{ a: 5 }];
    const request = jest
      .fn<Promise<typeof batch1>, [string]>()
      .mockResolvedValueOnce(batch1)
      .mockResolvedValueOnce(batch2)
      .mockResolvedValueOnce(batch3);
    const arg = 'arg';
    const result = await fetchSequentially({
      arg,
      paginationOptions: { count: 2 },
      request,
      responseTranslator: (items: Array<typeof batch1[0]>, arg0) => items.map(({ a }) => ({ arg: arg0, b: a }))
    });
    expect(result).toEqual([
      { arg, b: 1 },
      { arg, b: 2 },
      { arg, b: 3 },
      { arg, b: 4 },
      { arg, b: 5 }
    ]);
    expect(request).toBeCalledTimes(3);
  });

  describe('blockfrostMetadataToTxMetadata', () => {
    it('converts a blockfrost metadata array into a TxMetadata map', () => {
      const metadata = [
        {
          json_metadata: { test: 'value' },
          label: '1'
        },
        {
          json_metadata: {
            b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a7: {
              '6e7574636f696e': {
                image: ['ipfs://image'],
                name: 'test nft',
                version: '1.0'
              }
            }
          },
          label: '721'
        }
      ];
      expect(blockfrostMetadataToTxMetadata(metadata)).toEqual<Cardano.TxMetadata>(
        new Map([
          [1n, new Map([['test', 'value']])],
          [
            721n,
            new Map<Cardano.Metadatum, Cardano.Metadatum>([
              [
                'b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a7',
                new Map([
                  [
                    '6e7574636f696e',
                    new Map<Cardano.Metadatum, Cardano.Metadatum>([
                      ['image', ['ipfs://image']],
                      ['name', 'test nft'],
                      ['version', '1.0']
                    ])
                  ]
                ])
              ]
            ])
          ]
        ])
      );
    });
    it('returns an empty map if metadata array provided is empty', () => {
      expect(blockfrostMetadataToTxMetadata([])).toEqual(new Map());
    });
  });
});
