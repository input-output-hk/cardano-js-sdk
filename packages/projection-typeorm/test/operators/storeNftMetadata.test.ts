import { Asset, Cardano } from '@cardano-sdk/core';
import {
  AssetEntity,
  BlockDataEntity,
  BlockEntity,
  NftMetadataEntity,
  NftMetadataType,
  OutputEntity,
  TokensEntity,
  TypeormStabilityWindowBuffer,
  TypeormTipTracker,
  createObservableConnection,
  storeAssets,
  storeBlock,
  storeNftMetadata,
  storeUtxo,
  typeormTransactionCommit,
  willStoreNftMetadata,
  withTypeormTransaction
} from '../../src';
import {
  Bootstrap,
  ChainSyncEventType,
  ChainSyncRollForward,
  Mappers,
  ProjectionEvent,
  requestNext
} from '@cardano-sdk/projection';
import { CIP67Asset, ProjectedNftMetadata } from '@cardano-sdk/projection/dist/cjs/operators/Mappers';
import { ChainSyncDataSet, chainSyncData, generateRandomHexString, logger } from '@cardano-sdk/util-dev';
import { Observable, firstValueFrom, lastValueFrom, toArray } from 'rxjs';
import { QueryRunner, Repository } from 'typeorm';
import { connectionConfig$, initializeDataSource } from '../util';
import {
  createProjectorContext,
  createProjectorTilFirst,
  createRollBackwardEventFor,
  createRollForwardEventBasedOn,
  createStubBlockHeader,
  createStubProjectionSource,
  createStubRollForwardEvent,
  filterAssets
} from './util';
import { dummyLogger } from 'ts-log';
import omit from 'lodash/omit.js';

const patchNftMetadataNameCip25 = (
  metadata: Cardano.TxMetadata,
  assetId: Cardano.AssetId,
  newName: string
): Cardano.TxMetadata => {
  const policyId = Cardano.AssetId.getPolicyId(assetId);
  const assetName = Buffer.from(Cardano.AssetId.getAssetName(assetId), 'hex').toString('utf8');
  const tokenMetadata = ((metadata.get(721n) as Cardano.MetadatumMap).get(policyId) as Cardano.MetadatumMap).get(
    assetName
  ) as Cardano.MetadatumMap;
  return new Map([
    [
      721n,
      new Map([
        [
          policyId,
          new Map([
            [
              assetName,
              new Map(
                [...tokenMetadata.entries()].map(([key, value]) => {
                  if (key === 'name') return [key, newName];
                  return [key, value];
                })
              )
            ]
          ])
        ]
      ])
    ]
  ]);
};

const patchNftMetadataNameCip68InDatum = (datum: Cardano.PlutusData, newName: string): Cardano.PlutusData => {
  if (Cardano.util.isPlutusMap(datum)) {
    return {
      ...datum,
      data: new Map(
        [...datum.data.entries()].map(([key, value]) => {
          if (Cardano.util.isPlutusBoundedBytes(key) && Buffer.from(key).toString('utf8') === 'name') {
            return [key, Buffer.from(newName, 'utf8')];
          }
          return [key, patchNftMetadataNameCip68InDatum(value, newName)];
        })
      )
    };
  } else if (Cardano.util.isPlutusList(datum)) {
    return {
      ...datum,
      items: datum.items.map((item) => patchNftMetadataNameCip68InDatum(item, newName))
    };
  } else if (Cardano.util.isConstrPlutusData(datum)) {
    return {
      ...datum,
      fields: {
        ...datum.fields,
        items: datum.fields.items.map((item) => patchNftMetadataNameCip68InDatum(item, newName))
      }
    };
  }
  return datum;
};

const patchNftMetadataNameCip68InTx = (
  tx: Cardano.OnChainTx,
  userTokenAssetId: Cardano.AssetId,
  newName: string
): Cardano.OnChainTx => {
  const policyId = Cardano.AssetId.getPolicyId(userTokenAssetId);
  const assetName = Cardano.AssetId.getAssetName(userTokenAssetId);
  const decoded = Asset.AssetNameLabel.decode(assetName);
  if (!decoded) throw new Error('Non-cip67 assetId');
  const referenceTokenAssetName = Asset.AssetNameLabel.encode(decoded.content, Asset.AssetNameLabelNum.ReferenceNFT);
  const referenceTokenAssetId = Cardano.AssetId.fromParts(policyId, referenceTokenAssetName);
  for (const [i, output] of tx.body.outputs.entries()) {
    if (output.value.assets?.has(referenceTokenAssetId) && output.datum) {
      return {
        ...tx,
        body: {
          ...tx.body,
          outputs: [
            ...tx.body.outputs.slice(0, i),
            {
              ...output,
              datum: patchNftMetadataNameCip68InDatum(output.datum, newName)
            },
            ...tx.body.outputs.slice(i + 1)
          ]
        }
      };
    }
  }
  return tx;
};

/**
 * Assumes there is an event that mints both reference and user NFTs.
 *
 * @returns [txWithReferenceToken, txWithUserToken]
 */
const findAndSplitCip68Tx = ({
  allEvents
}: ReturnType<typeof chainSyncData>): [Cardano.OnChainTx, Cardano.OnChainTx] => {
  const isCip67AssetWithLabel = (assetId: Cardano.AssetId, label: Asset.AssetNameLabel) => {
    const assetName = Cardano.AssetId.getAssetName(assetId);
    const decoded = Asset.AssetNameLabel.decode(assetName);
    return decoded?.label === label;
  };
  const cip68Tx = allEvents
    .filter((evt): evt is Omit<ChainSyncRollForward, 'requestNext'> => evt.eventType === ChainSyncEventType.RollForward)
    .flatMap(({ block: { body } }) => body)
    .find((tx) =>
      [Asset.AssetNameLabelNum.ReferenceNFT, Asset.AssetNameLabelNum.UserNFT].every((label) =>
        [...(tx.body.mint?.keys() || [])].some((assetId) => isCip67AssetWithLabel(assetId, label))
      )
    )!;
  const keepOnlyCip67Asset = (label: Asset.AssetNameLabel): Cardano.OnChainTx => ({
    ...cip68Tx,
    auxiliaryData: undefined,
    body: {
      ...cip68Tx.body,
      mint: new Map(
        [...(cip68Tx.body.mint?.entries() || [])].filter(([assetId]) => isCip67AssetWithLabel(assetId, label))
      ),
      outputs: cip68Tx.body.outputs.map((output) => ({
        ...output,
        value: {
          ...output.value,
          assets: new Map(
            [...(output.value.assets?.entries() || [])].filter(([assetId]) => isCip67AssetWithLabel(assetId, label))
          )
        }
      }))
    },
    id: Cardano.TransactionId(generateRandomHexString(64))
  });

  return [
    keepOnlyCip67Asset(Asset.AssetNameLabelNum.ReferenceNFT),
    keepOnlyCip67Asset(Asset.AssetNameLabelNum.UserNFT)
  ];
};

describe('storeNftMetadata', () => {
  const withHandleEvents = chainSyncData(ChainSyncDataSet.WithHandle);
  const withInlineDatumEvents = chainSyncData(ChainSyncDataSet.WithInlineDatum);

  let queryRunner: QueryRunner;
  let nftMetadataRepo: Repository<NftMetadataEntity>;
  let assetRepo: Repository<AssetEntity>;
  let buffer: TypeormStabilityWindowBuffer;
  let tipTracker: TypeormTipTracker;
  const entities = [BlockEntity, BlockDataEntity, AssetEntity, TokensEntity, OutputEntity, NftMetadataEntity];

  const storeData = (
    evt$: Observable<ProjectionEvent<Mappers.WithUtxo & Mappers.WithMint & Mappers.WithCIP67 & Mappers.WithNftMetadata>>
  ) =>
    evt$.pipe(
      withTypeormTransaction({ connection$: createObservableConnection({ connectionConfig$, entities, logger }) }),
      storeBlock(),
      storeAssets(),
      storeUtxo(),
      storeNftMetadata(),
      buffer.storeBlockData(),
      typeormTransactionCommit()
    );

  // eslint-disable-next-line unicorn/consistent-function-scoping
  const applyOperators = () => (evt$: Observable<ProjectionEvent<{}>>) =>
    evt$.pipe(
      Mappers.withUtxo(),
      Mappers.withMint(),
      Mappers.withCIP67(),
      Mappers.withNftMetadata({ logger: dummyLogger }),
      storeData,
      tipTracker.trackProjectedTip(),
      requestNext()
    );

  const project$ = (events: typeof withHandleEvents) =>
    Bootstrap.fromCardanoNode({
      blocksBufferLength: 1,
      buffer,
      cardanoNode: events.cardanoNode,
      logger,
      projectedTip$: tipTracker.tip$
    }).pipe(applyOperators());

  const createProjectTilFirst = (events: typeof withHandleEvents) => createProjectorTilFirst(() => project$(events));

  beforeEach(async () => {
    const dataSource = await initializeDataSource({ entities });
    queryRunner = dataSource.createQueryRunner();
    nftMetadataRepo = queryRunner.manager.getRepository(NftMetadataEntity);
    assetRepo = queryRunner.manager.getRepository(AssetEntity);
    ({ buffer, tipTracker } = createProjectorContext(entities));
  });

  afterEach(async () => {
    await queryRunner.release();
  });

  const testBasicNftProjectionFeatures = (
    data: ReturnType<typeof chainSyncData>,
    patchNftMetadataName: (block: Cardano.Block, assetId: Cardano.AssetId, newName: string) => Cardano.Block,
    type: NftMetadataType
  ) => {
    const projectTilFirst = createProjectTilFirst(data);

    it('writes NFT metadata into the database on RollForward', async () => {
      const evtWithNftMetadata = await projectTilFirst((evt) => evt.nftMetadata.length > 0);
      expect(evtWithNftMetadata.nftMetadata.length).toBeGreaterThan(0);
      const projectedNftMetadata = await nftMetadataRepo.find({ relations: { userTokenAsset: true } });
      expect(projectedNftMetadata).toHaveLength(evtWithNftMetadata.nftMetadata.length);
      const { userTokenAssetId: someNftMetadataAssetId, nftMetadata: someNftMetadata } =
        evtWithNftMetadata.nftMetadata[0];
      const storedNftMetadata = projectedNftMetadata.find(
        (storedMetadata) => storedMetadata.userTokenAsset?.id === someNftMetadataAssetId
      );
      expect(omit(storedNftMetadata, ['userTokenAsset', 'userTokenAssetId', 'id'])).toEqual({
        description: someNftMetadata.description || null,
        files: someNftMetadata.files,
        image: someNftMetadata.image,
        mediaType: someNftMetadata.mediaType || null,
        name: someNftMetadata.name,
        otherProperties: someNftMetadata.otherProperties,
        type
      });
    });

    it('deletes NFT metadata from the database on RollBackward', async () => {
      const evtWithNftMetadata = await projectTilFirst((evt) => evt.nftMetadata.length > 0);
      await projectTilFirst(
        (evt) =>
          evt.block.header.hash === evtWithNftMetadata.block.header.hash &&
          evt.eventType === ChainSyncEventType.RollBackward
      );
      expect(await nftMetadataRepo.count()).toBe(0);
    });

    it('updates AssetEntity.NftMetadata', async () => {
      const evtWithNftMetadata = await projectTilFirst((evt) => evt.nftMetadata.length > 0);
      const assetId: Cardano.AssetId = evtWithNftMetadata.nftMetadata[0].userTokenAssetId;
      expect(typeof assetId).toBe('string');
      const asset = await assetRepo.findOne({ relations: { nftMetadata: true }, where: { id: assetId } });
      const { nftMetadata: initialNftMetadata } = evtWithNftMetadata.nftMetadata.find(
        ({ userTokenAssetId }) => userTokenAssetId === assetId
      )!;
      expect(asset?.nftMetadata?.name).toBe(initialNftMetadata.name);

      // Update NFT metadata by minting the asset again
      const newName = '$mary';
      const updateEvt = createRollForwardEventBasedOn(evtWithNftMetadata, (block) =>
        patchNftMetadataName(block, assetId, newName)
      );
      await firstValueFrom(createStubProjectionSource([updateEvt]).pipe(applyOperators()));
      const updatedAsset = await assetRepo.findOne({ relations: { nftMetadata: true }, where: { id: assetId } });
      expect(updatedAsset?.nftMetadata?.name).toBe(newName);

      // Rollback the update, switching back to original nft metadata
      const rollbackEvt = createRollBackwardEventFor(updateEvt, evtWithNftMetadata.block.header);
      await firstValueFrom(createStubProjectionSource([rollbackEvt]).pipe(applyOperators()));
      const rolledBackAsset = await assetRepo.findOne({ relations: { nftMetadata: true }, where: { id: assetId } });
      expect(rolledBackAsset?.nftMetadata?.name).toBe(initialNftMetadata.name);
    });
  };

  describe('cip25', () => {
    testBasicNftProjectionFeatures(
      withHandleEvents,
      (block, assetId, newName) => ({
        ...block,
        body: [
          // This particular block in current data set has only 1 tx,
          {
            ...block.body[0],
            auxiliaryData: {
              ...block.body[0].auxiliaryData,
              blob: patchNftMetadataNameCip25(block.body[0].auxiliaryData!.blob!, assetId, newName)
            }
          }
        ]
      }),
      NftMetadataType.CIP25
    );

    it('does not throw when name has null characters', async () => {
      const events = chainSyncData(ChainSyncDataSet.AssetNameUtf8Problem);
      await expect(
        lastValueFrom(
          project$(
            filterAssets(events, [Cardano.AssetId('00740069006e0079002000640069006e006f0073002000230035003600350032')])
          )
        )
        // throws 'invalid byte sequence for encoding "UTF8": 0x00'
        // when asset name is not sanitized
      ).resolves.not.toThrow();
    });

    it('does not throw when some field in otherProperties has null characters', async () => {
      const events = chainSyncData(ChainSyncDataSet.ExtraDataNullCharactersProblem);
      const assetId = Cardano.AssetId('65bcf672806de8a2335576339e801d41f3275c0c07dd6aadf2ea41d9000000000042414444');

      // throws 'unsupported Unicode escape sequence'
      // when otherProperties is not sanitized
      await lastValueFrom(project$(filterAssets(events, [assetId])));

      const metadata = await nftMetadataRepo.findOneBy({ userTokenAssetId: assetId });
      expect(metadata!.otherProperties!.size).toBeGreaterThan(0);
    });
  });

  describe('cip68', () => {
    testBasicNftProjectionFeatures(
      withInlineDatumEvents,
      (block, assetId, newName) => ({
        ...block,
        body: block.body.map((tx) => patchNftMetadataNameCip68InTx(tx, assetId, newName))
      }),
      NftMetadataType.CIP68
    );

    describe('reference nft and user nft minted in different blocks', () => {
      const [txWithReferenceToken, txWithUserToken] = findAndSplitCip68Tx(withInlineDatumEvents);
      const networkInfo = withInlineDatumEvents.networkInfo;

      describe('reference nft minted first', () => {
        it('associates user nft with NftMetadata, keeps NftMetadata in db when user token is rolled back', async () => {
          // Setup events
          const referenceTokenBlockHeader = createStubBlockHeader(Cardano.BlockNo(1));
          const referenceTokenEvt = createStubRollForwardEvent(
            { blockBody: [txWithReferenceToken], blockHeader: referenceTokenBlockHeader },
            networkInfo
          );
          const userTokenRollForwardEvt = createStubRollForwardEvent(
            { blockBody: [txWithUserToken], blockHeader: createStubBlockHeader(Cardano.BlockNo(2)) },
            networkInfo
          );
          const userTokenRollBackwardEvt = createRollBackwardEventFor(
            userTokenRollForwardEvt,
            referenceTokenBlockHeader
          );

          expect(await nftMetadataRepo.count()).toBe(0);
          expect(await assetRepo.count()).toBe(0);

          // Projecting reference token first should create NftMetadataEntity that is not associated with any AssetEntity.nftMetadata
          await firstValueFrom(createStubProjectionSource([referenceTokenEvt]).pipe(applyOperators()));
          expect(await nftMetadataRepo.count()).toBe(1);
          expect(await assetRepo.count()).toBe(1);

          // Minting user token should associate it with already existing NftMetadata
          await firstValueFrom(createStubProjectionSource([userTokenRollForwardEvt]).pipe(applyOperators()));
          expect(await nftMetadataRepo.count()).toBe(1);
          expect(await assetRepo.count()).toBe(2);
          const [nftMetadata] = await nftMetadataRepo.find({ relations: { userTokenAsset: true } });
          expect(typeof nftMetadata.userTokenAsset?.id).toBe('string');
          const userTokenAsset = await assetRepo.findOne({
            relations: { nftMetadata: true },
            where: { id: nftMetadata.userTokenAsset?.id }
          });
          expect(userTokenAsset?.nftMetadata?.id).toEqual(nftMetadata.id);

          // Rolling back user token mint event should userToken to null
          await firstValueFrom(createStubProjectionSource([userTokenRollBackwardEvt]).pipe(applyOperators()));
          expect(await nftMetadataRepo.count()).toBe(1);
          expect(await assetRepo.count()).toBe(1);
          const nftMetadataAfterRollback = await nftMetadataRepo.findOne({
            relations: { userTokenAsset: true },
            where: { id: nftMetadata?.id }
          });
          expect(nftMetadataAfterRollback).toBeDefined();
          expect(nftMetadataAfterRollback?.userTokenAsset?.id).toBeUndefined();
        });
      });

      describe('user token minted first', () => {
        it('associates user nft with NftMetadata, sets nftMetadata to null when reference token is rolled back', async () => {
          // Setup events
          const userTokenBlockHeader = createStubBlockHeader(Cardano.BlockNo(1));
          const userTokenEvt = createStubRollForwardEvent(
            { blockBody: [txWithUserToken], blockHeader: userTokenBlockHeader },
            networkInfo
          );
          const referenceTokenRollForwardEvt = createStubRollForwardEvent(
            { blockBody: [txWithReferenceToken], blockHeader: createStubBlockHeader(Cardano.BlockNo(2)) },
            networkInfo
          );
          const referenceTokenRollBackwardEvt = createRollBackwardEventFor(
            referenceTokenRollForwardEvt,
            userTokenBlockHeader
          );

          expect(await nftMetadataRepo.count()).toBe(0);
          expect(await assetRepo.count()).toBe(0);

          // Projecting user token first should create an AssetEntity without nftMetadata
          await firstValueFrom(createStubProjectionSource([userTokenEvt]).pipe(applyOperators()));
          const assertUserTokenIsWithoutNftMetadata = async () => {
            expect(await nftMetadataRepo.count()).toBe(0);
            const assets = await assetRepo.find({ relations: { nftMetadata: true } });
            expect(assets).toHaveLength(1);
            expect(assets[0].nftMetadata).toBeNull();
          };
          await assertUserTokenIsWithoutNftMetadata();

          // Minting reference token should associate it with it's NftMetadata
          await firstValueFrom(createStubProjectionSource([referenceTokenRollForwardEvt]).pipe(applyOperators()));
          expect(await nftMetadataRepo.count()).toBe(1);
          expect(await assetRepo.count()).toBe(2);
          const [nftMetadata] = await nftMetadataRepo.find({ relations: { userTokenAsset: true } });
          expect(typeof nftMetadata.userTokenAsset?.id).toBe('string');
          const userTokenAsset = await assetRepo.findOne({
            relations: { nftMetadata: true },
            where: { id: nftMetadata.userTokenAsset?.id }
          });
          expect(userTokenAsset?.nftMetadata?.id).toEqual(nftMetadata.id);

          // Rolling back user token mint event should userToken to null
          await firstValueFrom(createStubProjectionSource([referenceTokenRollBackwardEvt]).pipe(applyOperators()));
          await assertUserTokenIsWithoutNftMetadata();
        });
      });
    });
  });

  it('can store and retrieve files', async () => {
    const events = await lastValueFrom(project$(withInlineDatumEvents).pipe(toArray()));
    expect(events.length).toBeGreaterThan(1);
    expect(await nftMetadataRepo.count()).toBeGreaterThan(0);
    const nftAssets = await nftMetadataRepo.find({ select: ['files'] });
    const file = nftAssets.find((asset) => asset.files && asset.files.length > 0)!.files![0];
    expect(typeof file.mediaType).toBe('string');
    expect(typeof file.src).toBe('string');
    expect(['object', 'undefined'].includes(typeof file.otherProperties)).toBe(true);
    expect(['string', 'undefined'].includes(typeof file.name)).toBe(true);
  });

  it('projects metadata with missing "extra" field', async () => {
    const events = chainSyncData(ChainSyncDataSet.MissingExtraDatumMetadataProblem);
    const userTokenAssetId = Cardano.AssetId(
      'e51fbae37cc032eab73861f52ccfa3291e1f4746b7a471628ae27012000de1406e6d6b724e4654386d6179'
    );
    const referenceNftAssetId = Cardano.AssetId(
      'e51fbae37cc032eab73861f52ccfa3291e1f4746b7a471628ae27012000643b06e6d6b724e4654386d6179'
    );
    await lastValueFrom(project$(filterAssets(events, [referenceNftAssetId, userTokenAssetId])));
    const metadata = await nftMetadataRepo.findOneBy({ userTokenAssetId });
    expect(metadata).toBeTruthy();
  });
});

describe('willStoreNftMetadata', () => {
  it('returns true if there are nftMetadata', () => {
    expect(
      willStoreNftMetadata({
        cip67: {
          byAssetId: {},
          byLabel: {}
        },
        nftMetadata: [{} as ProjectedNftMetadata]
      })
    ).toBeTruthy();
  });

  it('returns true if there are cip67 tokens', () => {
    expect(
      willStoreNftMetadata({
        cip67: {
          byAssetId: { [{} as Cardano.AssetId]: {} as CIP67Asset },
          byLabel: { [Asset.AssetNameLabelNum.UserNFT]: [{} as CIP67Asset] }
        },
        nftMetadata: []
      })
    ).toBeTruthy();
  });

  it('returns false if there are no nftMetadata or cip67', () => {
    expect(
      willStoreNftMetadata({
        cip67: {
          byAssetId: {},
          byLabel: {}
        },
        nftMetadata: []
      })
    ).toBeFalsy();
  });
});
