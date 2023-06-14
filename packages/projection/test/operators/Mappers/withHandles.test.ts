import { Asset, Cardano } from '@cardano-sdk/core';
import { Buffer } from 'buffer';
import { Mappers, ProjectionEvent } from '../../../src';
import { firstValueFrom, of } from 'rxjs';
import { mockProviders } from '@cardano-sdk/util-dev';
import { withHandles } from '../../../src/operators/Mappers';

const assetIdFromNameLabelAndPolicyId = (assetName: string, policyId: Cardano.PolicyId): Cardano.AssetId =>
  Cardano.AssetId.fromParts(policyId, Cardano.AssetName(Buffer.from(assetName).toString('hex')));

const handlePolicyId = mockProviders.handlePolicyId;
const assetIdFromHandle = (handle: string) => assetIdFromNameLabelAndPolicyId(handle, handlePolicyId);

describe('withHandles', () => {
  const bobAddress = Cardano.PaymentAddress('addr_test1wzlv9cslk9tcj0wpm9p5t6kajyt37ap5sc9rzkaxa9p67ys2ygypv');
  const maryAddress = Cardano.PaymentAddress(
    'addr_test1qretqkqqvc4dax3482tpjdazrfl8exey274m3mzch3dv8lu476aeq3kd8q8splpsswcfmv4y370e8r76rc8lnnhte49qqyjmtc'
  );
  const bobHandleOne = 'bob.handle.one';
  const bobHandleTwo = 'bob.handle.two';
  const maryHandleOne = 'mary.handle.one';
  const outputs = {
    maryHandleToBob: {
      address: bobAddress,
      value: {
        assets: new Map([[assetIdFromHandle(maryHandleOne), 1n]]),
        coins: 25_485_292n
      }
    },
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

  it('sets "datum" property on the handle if utxo has datum', async () => {
    const datum = Buffer.from('123abc', 'hex');
    const outputsWithDatum: Cardano.TxOut[] = [
      {
        address: Cardano.PaymentAddress(
          'addr_test1qretqkqqvc4dax3482tpjdazrfl8exey274m3mzch3dv8lu476aeq3kd8q8splpsswcfmv4y370e8r76rc8lnnhte49qqyjmtc'
        ),
        datum,
        value: {
          assets: new Map([[assetIdFromHandle('somehandle'), 1n]]),
          coins: 25_485_292n
        }
      }
    ];
    const validTxSource$ = of({
      block: { body: [{ body: { outputs: outputsWithDatum } }] }
    } as ProjectionEvent<Mappers.WithMint>);
    const { handles } = await firstValueFrom(
      validTxSource$.pipe(
        withHandles({
          policyIds: [handlePolicyId]
        })
      )
    );

    expect(handles[0].datum).toEqual(datum);
  });

  it('includes a handle with "null" address, when transaction burns a handle', async () => {
    const validTxSource$ = of({
      block: { body: [{ body: { mint: new Map([[assetIdFromHandle('bob'), -1n]]), outputs: [] as Cardano.TxOut[] } }] }
    } as ProjectionEvent<Mappers.WithMint>);
    const { handles } = await firstValueFrom(
      validTxSource$.pipe(
        withHandles({
          policyIds: [handlePolicyId]
        })
      )
    );
    expect(handles.length).toBe(1);
    expect(handles[0].latestOwnerAddress).toBeNull();
  });

  it('maps and filters assets, from outputs, containing handles matching the given policy ID to an array of objects', async () => {
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
    } as ProjectionEvent<Mappers.WithMint>);

    const { handles } = await firstValueFrom(
      validTxSource$.pipe(
        withHandles({
          policyIds: [handlePolicyId]
        })
      )
    );

    expect(handles).toEqual(
      expect.arrayContaining([
        {
          assetId: assetIdFromHandle(bobHandleOne),
          handle: bobHandleOne,
          latestOwnerAddress: bobAddress,
          policyId: handlePolicyId.toString()
        },
        {
          assetId: assetIdFromHandle(bobHandleTwo),
          handle: bobHandleTwo,
          latestOwnerAddress: bobAddress,
          policyId: handlePolicyId.toString()
        },
        {
          assetId: assetIdFromHandle(maryHandleOne),
          handle: maryHandleOne,
          latestOwnerAddress: maryAddress,
          policyId: handlePolicyId.toString()
        }
      ])
    );
    expect(handles).toHaveLength(3);
  });

  describe('multiple transactions in a block affecting the same handle', () => {
    const blockNo = Cardano.BlockNo(1);

    it('mint->transfer keeps only 1 handle entry with the latest owner address', async () => {
      const evt = {
        block: {
          body: [
            {
              body: {
                mint: new Map([[assetIdFromHandle(maryHandleOne), 1n]]),
                outputs: [outputs.oneHandleMary]
              } as Cardano.TxBody
            } as Cardano.OnChainTx,
            { body: { outputs: [outputs.maryHandleToBob] } as Cardano.TxBody } as Cardano.OnChainTx
          ],
          header: { blockNo } as Cardano.PartialBlockHeader
        } as Cardano.Block
      } as ProjectionEvent<Mappers.WithMint>;
      const { handles } = await firstValueFrom(of(evt).pipe(withHandles({ policyIds: [handlePolicyId] })));
      expect(handles.length).toBe(1);
      expect(handles[0].latestOwnerAddress).toBe(bobAddress);
    });

    it('mint->burn keeps only 1 handle entry with `null` address', async () => {
      const evt = {
        block: {
          body: [
            {
              body: {
                mint: new Map([[assetIdFromHandle(maryHandleOne), 1n]]),
                outputs: [outputs.oneHandleMary]
              } as Cardano.TxBody
            } as Cardano.OnChainTx,
            {
              body: {
                mint: new Map([[assetIdFromHandle(maryHandleOne), -1n]]),
                outputs: [] as Cardano.TxOut[]
              } as Cardano.TxBody
            } as Cardano.OnChainTx
          ],
          header: { blockNo } as Cardano.PartialBlockHeader
        } as Cardano.Block
      } as ProjectionEvent<Mappers.WithMint>;
      const { handles } = await firstValueFrom(of(evt).pipe(withHandles({ policyIds: [handlePolicyId] })));
      expect(handles.length).toBe(1);
      expect(handles[0].latestOwnerAddress).toBe(null);
    });
  });

  describe('assets with invalid asset names', () => {
    const invalidAssetName = Asset.AssetNameLabel.encode(Cardano.AssetName('abc'), Asset.AssetNameLabelNum.UserFT);
    const invalidAssetId = Cardano.AssetId.fromParts(handlePolicyId, invalidAssetName);
    const outputsWithInvalidHandles = {
      invalidAssetName: {
        address: 'addr_test1vptwv4jvaqt635jvthpa29lww3vkzypm8l6vk4lv4tqfhhgajdgwf',
        value: {
          assets: new Map([[invalidAssetId, 1n]]),
          coins: 1n
        }
      },
      oneValidAndOneInvalidAssetName: {
        address: 'addr_test1vptwv4jvaqt635jvthpa29lww3vkzypm8l6vk4lv4tqfhhgajdgwf',
        value: {
          assets: new Map([
            [invalidAssetId, 1n],
            [assetIdFromHandle(bobHandleTwo), 1n]
          ])
        }
      }
    };

    it('it returns no handles when output only contain invalid assetId', async () => {
      const validTxSource$ = of({
        block: {
          body: [
            {
              body: {
                outputs: [outputsWithInvalidHandles.invalidAssetName]
              }
            }
          ]
        }
      } as ProjectionEvent<Mappers.WithMint>);

      const { handles } = await firstValueFrom(
        validTxSource$.pipe(
          withHandles({
            policyIds: [handlePolicyId]
          })
        )
      );

      expect(handles.length).toBe(0);
    });

    it('it returns only valid handles when output contains contains valid and invalid assetId', async () => {
      const validTxSource$ = of({
        block: {
          body: [
            {
              body: {
                outputs: [outputsWithInvalidHandles.oneValidAndOneInvalidAssetName]
              }
            }
          ]
        }
      } as ProjectionEvent<Mappers.WithMint>);

      const { handles } = await firstValueFrom(
        validTxSource$.pipe(
          withHandles({
            policyIds: [handlePolicyId]
          })
        )
      );

      expect(handles.length).toBe(1);
    });

    it('it returns only valid handles when block has multiple transactions with handle outputs ', async () => {
      const validTxSource$ = of({
        block: {
          body: [
            {
              body: {
                outputs: [outputsWithInvalidHandles.oneValidAndOneInvalidAssetName]
              }
            },
            {
              body: {
                outputs: [outputs.oneHandleMary]
              }
            }
          ]
        }
      } as ProjectionEvent<Mappers.WithMint>);

      const { handles } = await firstValueFrom(
        validTxSource$.pipe(
          withHandles({
            policyIds: [handlePolicyId]
          })
        )
      );

      expect(handles.length).toBe(2);
    });
  });
});
