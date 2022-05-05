import { Cardano, InvalidStringError, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { blockfrostMetadataToTxMetadata, fetchSequentially, formatBlockfrostError } from '../src/util';

describe('util', () => {
  describe('formatBlockfrostError', () => {
    it('converts InvalidStringError to ProviderError', () => {
      const originalError = new InvalidStringError('');
      expect(() => formatBlockfrostError(originalError)).toThrowError(
        new ProviderError(ProviderFailure.InvalidResponse, originalError)
      );
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
