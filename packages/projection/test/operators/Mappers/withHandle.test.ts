import { Asset, Cardano } from '@cardano-sdk/core';
import { Buffer } from 'buffer';
import { ProjectionEvent } from '../../../src';
import { filterHandlesByPolicyId, withHandles } from '../../../src/operators/Mappers';
import { firstValueFrom, of } from 'rxjs';

const assetIdFromNameLabelAndPolicyId = (assetName: string, policyId: Cardano.PolicyId): Cardano.AssetId =>
  Asset.util.assetIdFromPolicyAndName(policyId, Cardano.AssetName(Buffer.from(assetName).toString('hex')));

const handlePolicyId = Cardano.PolicyId('f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a');
const assetIdFromHandle = (handle: string) => assetIdFromNameLabelAndPolicyId(handle, handlePolicyId);

describe('withHandles + filterHandlesByPolicyId', () => {
  it('maps and filters assets, from outputs, containing handles matching the given policy ID to an array of objects', async () => {
    const bobHandleOne = 'bob.handle.one';
    const bobHandleTwo = 'bob.handle.two';
    const maryHandleOne = 'mary.handle.one';
    const bobAddress = Cardano.PaymentAddress('addr_test1wzlv9cslk9tcj0wpm9p5t6kajyt37ap5sc9rzkaxa9p67ys2ygypv');
    const maryAddress = Cardano.PaymentAddress(
      'addr_test1qretqkqqvc4dax3482tpjdazrfl8exey274m3mzch3dv8lu476aeq3kd8q8splpsswcfmv4y370e8r76rc8lnnhte49qqyjmtc'
    );
    const outputs = {
      noHandlesCoinsOnly: {
        address: 'addr_test1vptwv4jvaqt635jvthpa29lww3vkzypm8l6vk4lv4tqfhhgajdgwf',
        value: {
          coins: 74_341_815n
        }
      },
      noHandlesEmptyAssets: {
        address: 'addr_test1vptwv4jvaqt635jvthpa29lww3vkzypm8l6vk4lv4tqfhhgajdgwf',
        value: {
          assets: new Map(),
          coins: 74_341_815n
        }
      },
      noHandlesOtherAsset: {
        address: 'addr_test1vptwv4jvaqt635jvthpa29lww3vkzypm8l6vk4lv4tqfhhgajdgwf',
        value: {
          assets: new Map([
            [
              Cardano.AssetId('8f78a4388b1a3e1a1435257e9356fa0c2cc0d3a5999d63b5886c96435365636f6e6454657374746f6b656e'),
              3n
            ]
          ]),
          coins: 74_341_815n
        }
      },
      oneHandleMary: {
        address: maryAddress,
        value: {
          assets: new Map([[assetIdFromHandle(maryHandleOne), 1n]]),
          coins: 25_485_292n
        }
      },
      twoHandlesBob: {
        address: bobAddress,
        datumHash: '99c170cc1247e7b7971e194c7e400e219360d3991cb588e9833f77ee9edbbd06' as Cardano.DatumHash,
        value: {
          assets: new Map([
            [assetIdFromHandle(bobHandleOne), 1n],
            [assetIdFromHandle(bobHandleTwo), 1n]
          ]),
          coins: 1_724_100n
        }
      }
    };
    const validTxSource$ = of({
      block: {
        body: [
          {
            body: {
              outputs: [outputs.twoHandlesBob, outputs.noHandlesOtherAsset]
            }
          },
          {
            body: {
              outputs: [outputs.oneHandleMary, outputs.noHandlesEmptyAssets, outputs.noHandlesCoinsOnly]
            }
          }
        ]
      }
    } as ProjectionEvent);

    const { handles } = await firstValueFrom(
      validTxSource$.pipe(
        withHandles(),
        filterHandlesByPolicyId({
          policyIds: [handlePolicyId]
        })
      )
    );

    expect(handles).toEqual(
      expect.arrayContaining([
        {
          address: bobAddress,
          assetId: assetIdFromHandle(bobHandleOne),
          handle: bobHandleOne,
          policyId: handlePolicyId.toString()
        },
        {
          address: bobAddress,
          assetId: assetIdFromHandle(bobHandleTwo),
          handle: bobHandleTwo,
          policyId: handlePolicyId.toString()
        },
        {
          address: maryAddress,
          assetId: assetIdFromHandle(maryHandleOne),
          handle: maryHandleOne,
          policyId: handlePolicyId.toString()
        }
      ])
    );
    expect(handles).toHaveLength(3);
  });
});
