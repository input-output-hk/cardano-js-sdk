import { Asset, Cardano, Handle, Serialization } from '@cardano-sdk/core';
import { HandleEntity } from '../../../src';
import { HexBlob } from '@cardano-sdk/util';
import { ProjectorContext, createProjectorContext } from '../util';
import { QueryRunner } from 'typeorm';
import { createMultiTxProjectionSource, entities, mapAndStore, policyId } from './util';
import { firstValueFrom } from 'rxjs';
import { initializeDataSource } from '../../util';

const virtualSubhandleDatum = Serialization.PlutusData.fromCbor(
  HexBlob(
    // https://preview.cexplorer.io/datum/e87d179ddf8ca2365fdb342101cc0f94f525d5e2ae2cb94085f28b84641c97e8
    'd8799faf446e616d654d247669727475616c40686e646c45696d6167655838697066733a2f2f7a623272686b52636a5471546e5a387462704635485a474e4c4e355473324554633558477039576264614b415134335472496d65646961547970654a696d6167652f6a706567426f6700496f675f6e756d6265720046726172697479456261736963466c656e6774680c4a63686172616374657273476c657474657273516e756d657269635f6d6f64696669657273404a7375625f7261726974794562617369634a7375625f6c656e677468074e7375625f63686172616374657273476c657474657273557375625f6e756d657269635f6d6f64696669657273404b68616e646c655f74797065517669727475616c5f73756268616e646c654776657273696f6e0101a94e7374616e646172645f696d6167655838697066733a2f2f7a623272686b52636a5471546e5a387462704635485a474e4c4e355473324554633558477039576264614b41513433547246706f7274616c404864657369676e65724047736f6369616c73404676656e646f72404764656661756c7400536c6173745f7570646174655f616464726573735839007ad324c4fb08709dd997f6b2ba7980d5007103a2aa3f7a7eb8b44bc6f1a8e379127b811583070faf74db00d880d45027fe6171b1b69bd9ca4c76616c6964617465645f6279581c4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e1527265736f6c7665645f616464726573736573a1436164615839007ad324c4fb08709dd997f6b2ba7980d5007103a2aa3f7a7eb8b44bc6f1a8e379127b811583070faf74db00d880d45027fe6171b1b69bd9caff'
  )
).toCore();

const handlDatum = Serialization.PlutusData.fromCbor(
  HexBlob(
    // https://preview.cexplorer.io/datum/ff1a404ece117cc4482d26b072e30b5a6b3cd055a22debda3f90d704957e273a
    'd8799faa446e616d654524686e646c45696d6167655838697066733a2f2f7a623272685a6a4c4a545838615a6d4a7a42424862366b7535446d6e6650674d47375a6d73627162317366736356365970496d65646961547970654a696d6167652f6a706567426f6700496f675f6e756d626572004672617269747946636f6d6d6f6e466c656e677468044a63686172616374657273476c657474657273516e756d657269635f6d6f64696669657273404776657273696f6e0101af4e7374616e646172645f696d6167655838697066733a2f2f7a623272685a6a4c4a545838615a6d4a7a42424862366b7535446d6e6650674d47375a6d7362716231736673635636597046706f7274616c404864657369676e65724047736f6369616c73404676656e646f72404764656661756c7400536c6173745f7570646174655f61646472657373583900f541f0822d4794e6d1ddc3c0d5e932585bfcce2d869b1c2ee05b1dc7c37bace64b57b50a044bbafa593811a6f49c9d8d8c0b187932e2df404c76616c6964617465645f6279581c4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e14a696d6167655f68617368584032646465376163633062376532333931626633326133646537643566313763356365663231633336626432333564636663643738376463663439656661363339537374616e646172645f696d6167655f686173685840326464653761636330623765323339316266333261336465376435663137633563656632316333366264323335646366636437383764636634396566613633394b7376675f76657273696f6e45322e302e314c6167726565645f7465726d7340546d6967726174655f7369675f72657175697265640045747269616c00446e73667700ff'
  )
).toCore();

describe('subhandles', () => {
  let queryRunner: QueryRunner;
  let context: ProjectorContext;

  beforeEach(async () => {
    const dataSource = await initializeDataSource({ entities });
    queryRunner = dataSource.createQueryRunner();
    context = createProjectorContext(entities);
  });

  afterEach(async () => {
    await queryRunner.release();
  });

  describe('store parenthandle information', () => {
    const maryAddress = Cardano.PaymentAddress(
      'addr_test1qz690wvatwqgzt5u85hfzjxa8qqzthqwtp7xq8t3wh6ttc98hqtvlesvrpvln3srklcvhu2r9z22fdhaxvh2m2pg3nuq0n8gf2'
    );

    it('it stores NFT parentHandle information', async () => {
      const subHandle = 'sub@handl';
      const parentHandle = 'handl';
      const handleAssetName = (handleName: Handle) => Cardano.AssetName(Buffer.from(handleName).toString('hex'));
      const subHandleAssetId = Cardano.AssetId.fromParts(
        policyId,
        Asset.AssetNameLabel.encode(handleAssetName(subHandle), Asset.AssetNameLabelNum.UserNFT)
      );
      // eslint-disable-next-line @typescript-eslint/no-shadow
      const handleAssetId = Cardano.AssetId.fromParts(
        policyId,
        Asset.AssetNameLabel.encode(handleAssetName(parentHandle), Asset.AssetNameLabelNum.UserNFT)
      );

      const repository = queryRunner.manager.getRepository(HandleEntity);
      const source$ = createMultiTxProjectionSource([
        {
          body: {
            fee: 111n,
            inputs: [],
            mint: new Map([[handleAssetId, 1n]]),
            outputs: [
              {
                address: maryAddress,
                value: {
                  assets: new Map([[handleAssetId, 1n]]),
                  coins: 123n
                }
              }
            ]
          },
          id: Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000')
        },
        {
          body: {
            fee: 111n,
            inputs: [],
            mint: new Map([[subHandleAssetId, 1n]]),
            outputs: [
              {
                address: maryAddress,
                value: {
                  assets: new Map([[subHandleAssetId, 1n]]),
                  coins: 123n
                }
              }
            ]
          },
          id: Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000')
        }
      ]);

      const mintAndTransferEvt = await firstValueFrom(source$.pipe(mapAndStore(context)));

      expect(mintAndTransferEvt.handles[0].handle).toEqual(parentHandle);
      expect(mintAndTransferEvt.handles[1].handle).toEqual(subHandle);
      expect(
        await repository.findOne({
          relations: { parentHandle: true },
          select: { cardanoAddress: true, handle: true },
          where: { handle: subHandle }
        })
      ).toEqual({
        cardanoAddress: maryAddress,
        handle: subHandle,
        parentHandle: {
          cardanoAddress: maryAddress,
          defaultForPaymentCredential: parentHandle,
          defaultForStakeCredential: parentHandle,
          handle: parentHandle,
          hasDatum: false,
          policyId
        }
      });
    });

    it('it stores virtual parentHandle information', async () => {
      const virtualHandle = 'virtual@handl';
      const parentHandle = 'handl';
      const handleAssetName = (handleName: Handle) => Cardano.AssetName(Buffer.from(handleName).toString('hex'));
      const virtualSubHandleAssetId = Cardano.AssetId.fromParts(
        policyId,
        Asset.AssetNameLabel.encode(handleAssetName(virtualHandle), Asset.AssetNameLabelNum.VirtualHandle)
      );
      // eslint-disable-next-line @typescript-eslint/no-shadow
      const handleAssetId = Cardano.AssetId.fromParts(
        policyId,
        Asset.AssetNameLabel.encode(handleAssetName(parentHandle), Asset.AssetNameLabelNum.UserNFT)
      );

      const bobAddress = Cardano.PaymentAddress('addr_test1wzlv9cslk9tcj0wpm9p5t6kajyt37ap5sc9rzkaxa9p67ys2ygypv');

      const repository = queryRunner.manager.getRepository(HandleEntity);
      const source$ = createMultiTxProjectionSource([
        {
          body: {
            fee: 111n,
            inputs: [],
            mint: new Map([[handleAssetId, 1n]]),
            outputs: [
              {
                address: maryAddress,
                datum: handlDatum,
                value: {
                  assets: new Map([[handleAssetId, 1n]]),
                  coins: 123n
                }
              }
            ]
          },
          id: Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000')
        },
        {
          body: {
            fee: 111n,
            inputs: [],
            mint: new Map([[virtualSubHandleAssetId, 1n]]),
            outputs: [
              {
                address: bobAddress,
                datum: virtualSubhandleDatum,
                value: {
                  assets: new Map([[virtualSubHandleAssetId, 1n]]),
                  coins: 123n
                }
              }
            ]
          },
          id: Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000')
        }
      ]);

      const mintAndTransferEvt = await firstValueFrom(source$.pipe(mapAndStore(context)));

      expect(mintAndTransferEvt.handles[0].handle).toEqual(parentHandle);
      expect(mintAndTransferEvt.handles[1].handle).toEqual(virtualHandle);
      expect(
        await repository.findOne({
          relations: { parentHandle: true },
          select: { cardanoAddress: true, handle: true },
          where: { handle: virtualHandle }
        })
      ).toEqual({
        cardanoAddress: Cardano.PaymentAddress(
          'addr_test1qpadxfxylvy8p8wejlmt9wnesr2squgr524r77n7hz6yh3h34r3hjynmsy2cxpc04a6dkqxcsr29qfl7v9cmrd5mm89qqh563f'
        ),
        handle: virtualHandle,
        parentHandle: {
          cardanoAddress: maryAddress,
          defaultForPaymentCredential: parentHandle,
          defaultForStakeCredential: parentHandle,
          handle: parentHandle,
          hasDatum: true,
          policyId
        }
      });
    });

    it('stores several sub-handles for one parent handle', async () => {
      const subHandleOne = 'one@handl';
      const subHandleTwo = 'two@handl';
      const parentHandle = 'handl';
      const handleAssetName = (handleName: Handle) => Cardano.AssetName(Buffer.from(handleName).toString('hex'));
      const subHandleOneAssetId = Cardano.AssetId.fromParts(
        policyId,
        Asset.AssetNameLabel.encode(handleAssetName(subHandleOne), Asset.AssetNameLabelNum.UserNFT)
      );
      const subHandleTwoAssetId = Cardano.AssetId.fromParts(
        policyId,
        Asset.AssetNameLabel.encode(handleAssetName(subHandleTwo), Asset.AssetNameLabelNum.UserNFT)
      );
      // eslint-disable-next-line @typescript-eslint/no-shadow
      const handleAssetId = Cardano.AssetId.fromParts(
        policyId,
        Asset.AssetNameLabel.encode(handleAssetName(parentHandle), Asset.AssetNameLabelNum.UserNFT)
      );

      const repository = queryRunner.manager.getRepository(HandleEntity);
      const source$ = createMultiTxProjectionSource([
        {
          body: {
            fee: 111n,
            inputs: [],
            mint: new Map([[handleAssetId, 1n]]),
            outputs: [
              {
                address: maryAddress,
                datum: virtualSubhandleDatum,
                value: {
                  assets: new Map([[handleAssetId, 1n]]),
                  coins: 123n
                }
              }
            ]
          },
          id: Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000')
        },
        {
          body: {
            fee: 111n,
            inputs: [],
            mint: new Map([[subHandleOneAssetId, 1n]]),
            outputs: [
              {
                address: maryAddress,
                datum: virtualSubhandleDatum,
                value: {
                  assets: new Map([[subHandleOneAssetId, 1n]]),
                  coins: 123n
                }
              }
            ]
          },
          id: Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000')
        },
        {
          body: {
            fee: 111n,
            inputs: [],
            mint: new Map([[subHandleTwoAssetId, 1n]]),
            outputs: [
              {
                address: maryAddress,
                datum: virtualSubhandleDatum,
                value: {
                  assets: new Map([[subHandleTwoAssetId, 1n]]),
                  coins: 123n
                }
              }
            ]
          },
          id: Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000')
        }
      ]);

      const mintAndTransferEvt = await firstValueFrom(source$.pipe(mapAndStore(context)));

      expect(mintAndTransferEvt.handles[0].handle).toEqual(parentHandle);
      expect(mintAndTransferEvt.handles[1].handle).toEqual(subHandleOne);
      expect(mintAndTransferEvt.handles[2].handle).toEqual(subHandleTwo);
      expect(
        await repository.findOne({
          relations: { parentHandle: true },
          select: { cardanoAddress: true, handle: true },
          where: { handle: subHandleOne }
        })
      ).toEqual({
        cardanoAddress: maryAddress,
        handle: subHandleOne,
        parentHandle: {
          cardanoAddress: maryAddress,
          defaultForPaymentCredential: parentHandle,
          defaultForStakeCredential: parentHandle,
          handle: parentHandle,
          hasDatum: true,
          policyId
        }
      });

      expect(
        await repository.findOne({
          relations: { parentHandle: true },
          select: { cardanoAddress: true, handle: true },
          where: { handle: subHandleTwo }
        })
      ).toEqual({
        cardanoAddress: maryAddress,
        handle: subHandleTwo,
        parentHandle: {
          cardanoAddress: maryAddress,
          defaultForPaymentCredential: parentHandle,
          defaultForStakeCredential: parentHandle,
          handle: parentHandle,
          hasDatum: true,
          policyId
        }
      });
    });
  });
});
