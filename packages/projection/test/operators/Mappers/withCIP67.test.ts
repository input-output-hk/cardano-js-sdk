import { Asset, Cardano } from '@cardano-sdk/core';
import { Mappers, ProjectionEvent } from '../../../src';
import { firstValueFrom, of } from 'rxjs';
import { generateRandomHexString } from '@cardano-sdk/util-dev';

describe('withCIP67', () => {
  const txId1 = generateRandomHexString(64);
  const policyId533 = generateRandomHexString(56);
  const assetName533 = '00215410123';
  const assetId533 = Cardano.AssetId(`${policyId533}${assetName533}`);
  const evt = {
    utxo: {
      consumed: [] as Cardano.TxIn[],
      produced: [
        [
          { index: 0, txId: txId1 },
          {
            address: Cardano.PaymentAddress('addr_test1wrsexavz37208qda7mwwu4k7hcpg26cz0ce86f5e9kul3hqzlh22t'),
            value: {
              assets: new Map([
                [`${generateRandomHexString(56)}011d7690234`, 1n],
                [assetId533, 2n]
              ]),
              coins: 123n
            }
          }
        ],
        [
          { index: 1, txId: txId1 },
          {
            address: Cardano.PaymentAddress('addr_test1wrsexavz37208qda7mwwu4k7hcpg26cz0ce86f5e9kul3hqzlh22t'),
            value: {
              assets: new Map([[`${generateRandomHexString(56)}00017650345`, 1n]]),
              coins: 123n
            }
          }
        ],
        [
          { index: 2, txId: generateRandomHexString(64) },
          {
            address: Cardano.PaymentAddress('addr_test1wrsexavz37208qda7mwwu4k7hcpg26cz0ce86f5e9kul3hqzlh22t'),
            value: {
              assets: new Map([[`${generateRandomHexString(56)}00017650345`, 3n]]),
              coins: 123n
            }
          }
        ]
      ]
    }
  } as ProjectionEvent<Mappers.WithUtxo>;

  describe('collects all cip67-compliant assets', () => {
    it('groups them by label', async () => {
      const { cip67 } = await firstValueFrom(of(evt).pipe(Mappers.withCIP67()));
      expect(Object.keys(cip67.byLabel)).toHaveLength(3);
      expect(cip67.byLabel[Asset.AssetNameLabel(533)]).toEqual([
        {
          assetId: assetId533,
          assetName: assetName533,
          decoded: {
            content: Cardano.AssetName('123'),
            label: 533
          },
          policyId: policyId533,
          utxo: evt.utxo.produced[0]
        } as Mappers.CIP67Asset
      ]);
      expect(cip67.byLabel[Asset.AssetNameLabel(23)]).toHaveLength(2);
    });

    it('groups them by asset id', async () => {
      const { cip67 } = await firstValueFrom(of(evt).pipe(Mappers.withCIP67()));
      expect(Object.keys(cip67.byAssetId)).toHaveLength(4);
      expect(cip67.byAssetId[assetId533]).toEqual({
        assetId: assetId533,
        assetName: assetName533,
        decoded: {
          content: Cardano.AssetName('123'),
          label: 533
        },
        policyId: policyId533,
        utxo: evt.utxo.produced[0]
      } as Mappers.CIP67Asset);
    });
  });
});
