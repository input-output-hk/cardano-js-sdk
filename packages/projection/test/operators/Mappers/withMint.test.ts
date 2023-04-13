import { Cardano } from '@cardano-sdk/core';
import { Mappers, ProjectionEvent } from '../../../src';
import { computeCompactTxId } from '../../../src/operators/Mappers/util';
import { firstValueFrom, of } from 'rxjs';

describe('withMint', () => {
  it('maps all minted tokens into a flat array, preserving a transaction pointer', async () => {
    const source$ = of({
      block: {
        body: [
          {
            body: {
              mint: new Map([
                [Cardano.AssetId('2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740'), 20n],
                [Cardano.AssetId('659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba8254534c41'), 50n]
              ])
            }
          },
          {
            body: {
              mint: new Map([[Cardano.AssetId('2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740'), 40n]])
            }
          }
        ],
        header: { blockNo: 10 }
      }
    } as ProjectionEvent);
    const { mint } = await firstValueFrom(source$.pipe(Mappers.withMint()));
    expect(mint).toEqual([
      {
        assetId: '2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740',
        compactTxId: computeCompactTxId(10, 0),
        quantity: 20n
      },
      {
        assetId: '659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba8254534c41',
        compactTxId: computeCompactTxId(10, 0),
        quantity: 50n
      },
      {
        assetId: '2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740',
        compactTxId: computeCompactTxId(10, 1),
        quantity: 40n
      }
    ]);
  });
});
