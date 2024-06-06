import { Asset, Cardano } from '@cardano-sdk/core';
import { Buffer } from 'buffer';
import {
  NFTSubHandleOutput,
  assetIdFromHandle,
  bobAddress,
  bobHandleOne,
  bobHandleTwo,
  handleDatum,
  handleOutputs,
  handlePolicyId,
  invalidHandle,
  maryAddress,
  maryHandleOne,
  referenceNftOutput,
  subhandleAssetName,
  userNftOutput,
  virtualHandleAssetName,
  virtualSubHandleOutput
} from './handleUtil.js';
import { firstValueFrom, of } from 'rxjs';
import { logger, mockProviders } from '@cardano-sdk/util-dev';
import { withCIP67, withHandles, withMint, withUtxo } from '../../../src/operators/Mappers/index.js';
import type { CIP67Assets } from '../../../src/operators/Mappers/index.js';
import type { Mappers, ProjectionEvent } from '../../../src/index.js';

type In = Mappers.WithMint & Mappers.WithCIP67 & Mappers.WithNftMetadata;

const project = (tx: Cardano.OnChainTx) =>
  firstValueFrom(
    of({
      block: {
        body: [tx],
        header: mockProviders.ledgerTip
      }
    } as ProjectionEvent).pipe(
      withUtxo(),
      withMint(),
      withCIP67(),
      withHandles({ policyIds: [handlePolicyId] }, logger)
    )
  );

describe('withHandles', () => {
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
      block: { body: [{ body: { outputs: outputsWithDatum } }] },
      cip67: { byAssetId: {}, byLabel: {} }
    } as ProjectionEvent<In>);
    const { handles } = await firstValueFrom(validTxSource$.pipe(withHandles({ policyIds: [handlePolicyId] }, logger)));

    expect(handles[0].datum).toEqual(datum);
  });

  it('includes a handle with "null" address, when transaction burns a handle', async () => {
    const validTxSource$ = of({
      block: { body: [{ body: { mint: new Map([[assetIdFromHandle('bob'), -1n]]), outputs: [] as Cardano.TxOut[] } }] },
      cip67: { byAssetId: {}, byLabel: {} }
    } as ProjectionEvent<In>);
    const { handles } = await firstValueFrom(validTxSource$.pipe(withHandles({ policyIds: [handlePolicyId] }, logger)));
    expect(handles.length).toBe(1);
    expect(handles[0].latestOwnerAddress).toBeNull();
  });

  it('maps and filters assets, from outputs, containing handles matching the given policy ID to an array of objects', async () => {
    const validTxSource$ = of({
      block: {
        body: [
          {
            body: {
              outputs: [handleOutputs.twoHandlesBob, handleOutputs.noHandlesOtherAsset]
            }
          },
          {
            body: {
              outputs: [
                handleOutputs.oneHandleMary,
                handleOutputs.noHandlesEmptyAssets,
                handleOutputs.noHandlesCoinsOnly
              ]
            }
          }
        ]
      },
      cip67: { byAssetId: {}, byLabel: {} }
    } as ProjectionEvent<In>);

    const { handles } = await firstValueFrom(validTxSource$.pipe(withHandles({ policyIds: [handlePolicyId] }, logger)));

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
                outputs: [handleOutputs.oneHandleMary]
              } as Cardano.TxBody
            } as Cardano.OnChainTx,
            { body: { outputs: [handleOutputs.maryHandleToBob] } as Cardano.TxBody } as Cardano.OnChainTx
          ],
          header: { blockNo } as Cardano.PartialBlockHeader
        } as Cardano.Block,
        cip67: { byAssetId: {}, byLabel: {} }
      } as ProjectionEvent<In>;
      const { handles } = await firstValueFrom(of(evt).pipe(withHandles({ policyIds: [handlePolicyId] }, logger)));
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
                outputs: [handleOutputs.oneHandleMary]
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
        } as Cardano.Block,
        cip67: { byAssetId: {}, byLabel: {} }
      } as ProjectionEvent<In>;
      const { handles } = await firstValueFrom(of(evt).pipe(withHandles({ policyIds: [handlePolicyId] }, logger)));
      expect(handles.length).toBe(1);
      expect(handles[0].latestOwnerAddress).toBe(null);
    });
  });

  describe('assets with invalid asset names', () => {
    const invalidAssetName = Cardano.AssetName(Buffer.from(invalidHandle, 'utf8').toString('hex'));
    const invalidAssetId = Cardano.AssetId.fromParts(handlePolicyId, invalidAssetName);
    const decodedInvalidAssetName = Cardano.AssetName(Buffer.from(`${invalidHandle}other`, 'utf8').toString('hex'));
    const invalidAssetCip67AssetName = Asset.AssetNameLabel.encode(
      decodedInvalidAssetName,
      Asset.AssetNameLabelNum.UserNFT
    );
    const invalidAssetCip67ReferenceNftAssetName = Asset.AssetNameLabel.encode(
      decodedInvalidAssetName,
      Asset.AssetNameLabelNum.ReferenceNFT
    );
    const invalidCip67AssetId = Cardano.AssetId.fromParts(handlePolicyId, invalidAssetCip67AssetName);
    const invalidCip67ReferenceNftAssetId = Cardano.AssetId.fromParts(
      handlePolicyId,
      invalidAssetCip67ReferenceNftAssetName
    );

    const outputsWithInvalidHandles = {
      invalidAssetName: {
        address: 'addr_test1vptwv4jvaqt635jvthpa29lww3vkzypm8l6vk4lv4tqfhhgajdgwf',
        value: {
          assets: new Map([[invalidAssetId, 1n]]),
          coins: 1n
        }
      },
      oneValidTwoInvalidAssetName: {
        address: Cardano.PaymentAddress('addr_test1vptwv4jvaqt635jvthpa29lww3vkzypm8l6vk4lv4tqfhhgajdgwf'),
        datum: handleDatum,
        value: {
          assets: new Map([
            [invalidAssetId, 1n],
            [assetIdFromHandle(bobHandleTwo), 1n],
            [invalidCip67AssetId, 1n],
            [invalidCip67ReferenceNftAssetId, 1n]
          ]),
          coins: 123n
        }
      }
    };

    const txId = Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000');
    const utxo: [Cardano.TxIn, Cardano.TxOut] = [
      { index: 0, txId },
      outputsWithInvalidHandles.oneValidTwoInvalidAssetName
    ];
    const userNftCip67Asset = {
      assetId: invalidCip67ReferenceNftAssetId,
      assetName: invalidAssetCip67ReferenceNftAssetName,
      decoded: {
        content: decodedInvalidAssetName,
        label: Asset.AssetNameLabelNum.ReferenceNFT
      },
      policyId: handlePolicyId,
      utxo
    };
    const referenceNftCip67Asset = {
      assetId: invalidCip67AssetId,
      assetName: invalidAssetCip67AssetName,
      decoded: {
        content: decodedInvalidAssetName,
        label: Asset.AssetNameLabelNum.UserNFT
      },
      policyId: handlePolicyId,
      utxo
    };

    const cip67: CIP67Assets = {
      byAssetId: {
        [invalidAssetCip67ReferenceNftAssetName]: userNftCip67Asset,
        [invalidCip67AssetId]: referenceNftCip67Asset
      },
      byLabel: {
        [Asset.AssetNameLabelNum.UserNFT]: [userNftCip67Asset],
        [Asset.AssetNameLabelNum.ReferenceNFT]: [referenceNftCip67Asset]
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
        },
        cip67: { byAssetId: {}, byLabel: {} }
      } as ProjectionEvent<In>);

      const { handles } = await firstValueFrom(
        validTxSource$.pipe(withHandles({ policyIds: [handlePolicyId] }, logger))
      );

      expect(handles.length).toBe(0);
    });

    it('it returns only valid handles when output contains contains valid and invalid assetId', async () => {
      const validTxSource$ = of({
        block: {
          body: [
            {
              body: {
                outputs: [outputsWithInvalidHandles.oneValidTwoInvalidAssetName]
              }
            }
          ]
        },
        cip67
      } as ProjectionEvent<In>);

      const { handles } = await firstValueFrom(
        validTxSource$.pipe(withHandles({ policyIds: [handlePolicyId] }, logger))
      );

      expect(handles.length).toBe(1);
    });

    it('it returns only valid handles when block has multiple transactions with handle outputs ', async () => {
      const validTxSource$ = of({
        block: {
          body: [
            {
              body: {
                outputs: [outputsWithInvalidHandles.oneValidTwoInvalidAssetName]
              }
            },
            {
              body: {
                outputs: [handleOutputs.oneHandleMary]
              }
            }
          ]
        },
        cip67
      } as ProjectionEvent<In>);

      const { handles } = await firstValueFrom(
        validTxSource$.pipe(withHandles({ policyIds: [handlePolicyId] }, logger))
      );

      expect(handles.length).toBe(2);
    });
  });

  describe('cip68', () => {
    it('does not change ownership when only reference token is present', async () => {
      const { handles } = await project({
        body: { outputs: [referenceNftOutput] },
        inputSource: Cardano.InputSource.inputs
      } as Cardano.OnChainTx);

      expect(handles).toHaveLength(0);
    });

    it('changes latestOwnerAddress when only user token is not present', async () => {
      const { handles } = await project({
        body: { outputs: [userNftOutput] },
        inputSource: Cardano.InputSource.inputs
      } as Cardano.OnChainTx);

      expect(handles).toHaveLength(1);
      expect(handles[0].handle).toBe(maryHandleOne);
      expect(handles[0].latestOwnerAddress).toBe(maryAddress);
    });

    it('changes latestOwnerAddress when both reference and user tokens are present', async () => {
      const { handles } = await project({
        body: { outputs: [userNftOutput, referenceNftOutput] },
        inputSource: Cardano.InputSource.inputs
      } as Cardano.OnChainTx);

      expect(handles).toHaveLength(1);
      expect(handles[0].handle).toBe(maryHandleOne);
      expect(handles[0].latestOwnerAddress).toBe(maryAddress);
    });
  });

  describe('subhandles', () => {
    it('adds parentHandle data for virtual subhandles', async () => {
      const { handles } = await project({
        body: { outputs: [virtualSubHandleOutput] },
        inputSource: Cardano.InputSource.inputs
      } as Cardano.OnChainTx);

      expect(handles).toHaveLength(1);

      expect(handles[0].latestOwnerAddress).toBe(
        'addr_test1qpadxfxylvy8p8wejlmt9wnesr2squgr524r77n7hz6yh3h34r3hjynmsy2cxpc04a6dkqxcsr29qfl7v9cmrd5mm89qqh563f'
      );
      expect(handles[0].parentHandle).toBe('handl');
      expect(handles[0].handle).toBe('virtual@handl');
    });

    it('adds parentHandle data for NFT subhandles', async () => {
      const { handles } = await project({
        body: { outputs: [NFTSubHandleOutput] },
        inputSource: Cardano.InputSource.inputs
      } as Cardano.OnChainTx);

      expect(handles).toHaveLength(1);

      expect(handles[0].parentHandle).toBe('handl');
      expect(handles[0].handle).toBe('sub@handl');
    });

    it('includes a handle with "null" address, when transaction burns a subhandle', async () => {
      const { handles } = await project({
        body: {
          mint: new Map([[Cardano.AssetId.fromParts(handlePolicyId, subhandleAssetName), -1n]]),
          outputs: [] as Cardano.TxOut[]
        },
        inputSource: Cardano.InputSource.inputs
      } as Cardano.OnChainTx);

      expect(handles.length).toBe(1);
      expect(handles[0].latestOwnerAddress).toBeNull();
      expect(handles[0].handle).toBe('sub@handl');
    });

    it('includes a handle with "null" address, when transaction burns a virtualSubhandle', async () => {
      const { handles } = await project({
        body: {
          mint: new Map([[Cardano.AssetId.fromParts(handlePolicyId, virtualHandleAssetName), -1n]]),
          outputs: [] as Cardano.TxOut[]
        },
        inputSource: Cardano.InputSource.inputs
      } as Cardano.OnChainTx);

      expect(handles.length).toBe(1);
      expect(handles[0].latestOwnerAddress).toBeNull();
      expect(handles[0].handle).toBe('virtual@handl');
    });
  });
});
