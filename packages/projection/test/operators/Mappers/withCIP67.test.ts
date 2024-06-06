import { Asset, Cardano } from '@cardano-sdk/core';
import { Mappers } from '../../../src/index.js';
import { computeCompactTxId } from '../../../src/operators/Mappers/util.js';
import { firstValueFrom, of } from 'rxjs';
import { generateRandomHexString } from '@cardano-sdk/util-dev';
import { subhandleAssetName, virtualHandleAssetName } from './handleUtil.js';
import type { ProjectionEvent } from '../../../src/index.js';

describe('withCIP67', () => {
  const txId1 = generateRandomHexString(64);
  const policyId533 = generateRandomHexString(56) as Cardano.PolicyId;
  const assetName533 = '00215410123';
  const assetId533 = Cardano.AssetId(`${policyId533}${assetName533}`);
  const subhandleAssetId = Cardano.AssetId.fromParts(policyId533 as Cardano.PolicyId, subhandleAssetName);
  const virtualHandleAssetId = Cardano.AssetId.fromParts(policyId533 as Cardano.PolicyId, virtualHandleAssetName);

  const evt = {
    mint: [
      {
        assetId: subhandleAssetId,
        assetName: subhandleAssetName,
        compactTxId: computeCompactTxId(10, 0),
        policyId: policyId533,
        quantity: 1n
      },
      {
        assetId: virtualHandleAssetId,
        assetName: virtualHandleAssetId,
        compactTxId: computeCompactTxId(10, 0),
        policyId: policyId533,
        quantity: -1n
      }
    ],
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
        ],
        [
          { index: 3, txId: generateRandomHexString(64) },
          {
            address: Cardano.PaymentAddress('addr_test1wrsexavz37208qda7mwwu4k7hcpg26cz0ce86f5e9kul3hqzlh22t'),
            value: {
              assets: new Map([[subhandleAssetId, 1n]]),
              coins: 1n
            }
          }
        ]
      ]
    }
  } as ProjectionEvent<Mappers.WithUtxo & Mappers.WithMint>;

  describe('collects all cip67-compliant assets', () => {
    it('groups them by label', async () => {
      const { cip67 } = await firstValueFrom(of(evt).pipe(Mappers.withCIP67()));
      expect(Object.keys(cip67.byLabel)).toHaveLength(5);
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
      expect(Object.keys(cip67.byAssetId)).toHaveLength(6);
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

    it('includes minted asset in byAssetId', async () => {
      const { cip67 } = await firstValueFrom(of(evt).pipe(Mappers.withCIP67()));

      expect(Object.keys(cip67.byAssetId)).toHaveLength(6);
    });

    it('includes minted asset in byAssetLabel', async () => {
      const { cip67 } = await firstValueFrom(of(evt).pipe(Mappers.withCIP67()));

      expect(Object.keys(cip67.byLabel)).toHaveLength(5);
    });

    it('includes minted asset and maintain utxo with correct order', async () => {
      const { cip67 } = await firstValueFrom(of(evt).pipe(Mappers.withCIP67()));

      const expectedAsset: Mappers.CIP67Asset | undefined = cip67.byAssetId?.[subhandleAssetId];

      expect(expectedAsset).toBeDefined();

      if (expectedAsset) {
        expect(expectedAsset.assetId).toEqual(subhandleAssetId);
        expect(expectedAsset.assetName).toEqual(subhandleAssetName);
        expect(expectedAsset.utxo).toBeDefined();
      }
    });

    it('includes burned asset in byAssetId', async () => {
      const { cip67 } = await firstValueFrom(of(evt).pipe(Mappers.withCIP67()));

      expect(cip67.byAssetId[virtualHandleAssetId]).toEqual({
        assetId: virtualHandleAssetId,
        assetName: virtualHandleAssetId,
        compactTxId: 1_000_000,
        decoded: Asset.AssetNameLabel.decode(virtualHandleAssetName),
        policyId: policyId533,
        quantity: -1n
      });
    });

    it('includes burned asset in byLabel', async () => {
      const { cip67 } = await firstValueFrom(of(evt).pipe(Mappers.withCIP67()));

      expect(cip67.byLabel[Asset.AssetNameLabelNum.VirtualHandle]).toEqual([
        {
          assetId: virtualHandleAssetId,
          assetName: virtualHandleAssetId,
          compactTxId: 1_000_000,
          decoded: Asset.AssetNameLabel.decode(virtualHandleAssetName),
          policyId: policyId533,
          quantity: -1n
        }
      ]);
    });
  });
});
