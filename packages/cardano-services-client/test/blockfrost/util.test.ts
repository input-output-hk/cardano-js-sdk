import {
  BlockfrostError,
  blockfrostMetadataToTxMetadata,
  fetchSequentially,
  isBlockfrostNotFoundError
} from '../../src/blockfrost';
import { Cardano } from '@cardano-sdk/core';

describe('util', () => {
  describe('isBlockfrostNotFoundError', () => {
    it('can identify positives', () => {
      const errorContent = new BlockfrostError(404);
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
    const result = await fetchSequentially({
      paginationOptions: { count: 2 },
      request,
      responseTranslator: (items: Array<typeof batch1[0]>) => items.map(({ a }) => ({ b: a }))
    });
    expect(result).toEqual([{ b: 1 }, { b: 2 }, { b: 3 }, { b: 4 }, { b: 5 }]);
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
