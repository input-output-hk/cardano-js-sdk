import {
  AddressEntity,
  AssetEntity,
  BlockDataEntity,
  BlockEntity,
  HandleEntity,
  HandleMetadataEntity,
  NftMetadataEntity,
  OutputEntity,
  StakeKeyRegistrationEntity,
  TokensEntity,
  TypeormStabilityWindowBuffer,
  createObservableConnection,
  storeAddresses,
  storeAssets,
  storeBlock,
  storeHandleMetadata,
  storeHandles,
  storeUtxo,
  typeormTransactionCommit,
  withTypeormTransaction
} from '../../../src';
import { BaseProjectionEvent, Bootstrap, Mappers, ProjectionEvent, requestNext } from '@cardano-sdk/projection';
import { Cardano, ChainSyncEventType, Handle } from '@cardano-sdk/core';
import { ChainSyncDataSet, chainSyncData, logger, mockProviders } from '@cardano-sdk/util-dev';
import { Observable, firstValueFrom } from 'rxjs';
import {
  ProjectorContext,
  createProjectorTilFirst,
  createRollForwardEventBasedOn,
  createStubProjectionSource,
  createStubTx
} from '../util';
import { Repository } from 'typeorm';
import { connectionConfig$ } from '../../util';

export const stubEvents = chainSyncData(ChainSyncDataSet.WithHandle);
export const policyId = Cardano.PolicyId('f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a');
export const policyIds = [policyId];

const blockHeader = {
  blockNo: Cardano.BlockNo(317_881),
  hash: Cardano.BlockId('0000000000000000000000000000000000000000000000000000000000000000'),
  slot: Cardano.Slot(13_633_737)
};
export const createMultiTxProjectionSource = (txs: Pick<Cardano.OnChainTx, 'id' | 'body'>[]) =>
  createStubProjectionSource([
    {
      block: {
        body: txs.map((tx) => ({
          ...tx,
          inputSource: Cardano.InputSource.inputs,
          witness: { signatures: new Map() }
        })),
        header: blockHeader,
        totalOutput: 123n,
        txCount: txs.length
      },
      crossEpochBoundary: false,
      epochNo: Cardano.EpochNo(31),
      eraSummaries: [],
      eventType: ChainSyncEventType.RollForward,
      genesisParameters: mockProviders.genesisParameters,
      tip: blockHeader
    }
  ]);

export const entities = [
  BlockEntity,
  BlockDataEntity,
  AddressEntity,
  AssetEntity,
  TokensEntity,
  OutputEntity,
  HandleEntity,
  HandleMetadataEntity,
  StakeKeyRegistrationEntity,
  NftMetadataEntity
];

const storeData =
  (buffer: TypeormStabilityWindowBuffer) =>
  (
    evt$: Observable<
      ProjectionEvent<
        Mappers.WithUtxo & Mappers.WithMint & Mappers.WithHandles & Mappers.WithAddresses & Mappers.WithHandleMetadata
      >
    >
  ) =>
    evt$.pipe(
      withTypeormTransaction({
        connection$: createObservableConnection({ connectionConfig$, entities, logger })
      }),
      storeBlock(),
      storeAssets(),
      storeUtxo(),
      storeHandles(),
      storeAddresses(),
      storeHandleMetadata(),
      buffer.storeBlockData(),
      typeormTransactionCommit()
    );

const applyMappers = (evt$: Observable<ProjectionEvent<{}>>) =>
  evt$.pipe(
    Mappers.withUtxo(),
    Mappers.withMint(),
    Mappers.withAddresses(),
    Mappers.filterProducedUtxoByAssetPolicyId({ policyIds }),
    Mappers.filterMintByPolicyIds({ policyIds }),
    Mappers.withCIP67(),
    Mappers.withNftMetadata({ logger }),
    Mappers.withHandleMetadata({ policyIds }, logger),
    Mappers.withHandles({ policyIds }, logger)
  );

export const mapAndStore =
  ({ buffer }: ProjectorContext) =>
  (evt$: Observable<ProjectionEvent<{}>>) =>
    evt$.pipe(applyMappers, storeData(buffer));

export const project$ =
  ({ buffer, tipTracker }: ProjectorContext) =>
  () =>
    Bootstrap.fromCardanoNode({
      blocksBufferLength: 10,
      buffer,
      cardanoNode: stubEvents.cardanoNode,
      logger,
      projectedTip$: tipTracker.tip$
    }).pipe(mapAndStore({ buffer, tipTracker }), tipTracker.trackProjectedTip(), requestNext());

export const projectTilFirst = (context: ProjectorContext) => createProjectorTilFirst(project$(context));

export type HandleProjectionEvent = BaseProjectionEvent & Mappers.WithHandles & Mappers.WithUtxo;
export const burnHandle = async (
  mintEvent: HandleProjectionEvent,
  handle: Mappers.HandleOwnership,
  context: ProjectorContext
) => {
  const createBurnBlock = (block: Cardano.Block): Cardano.Block => ({
    ...block,
    body: [
      createStubTx({
        inputs: mintEvent.utxo.produced.map(([txIn]) => txIn),
        mint: new Map([[handle.assetId, -1n]])
      })
    ]
  });
  const burn$ = createStubProjectionSource([createRollForwardEventBasedOn(mintEvent, createBurnBlock)]).pipe(
    mapAndStore(context)
  );
  await firstValueFrom(burn$);
};

export const queryHandle = (handle: Handle, repository: Repository<HandleEntity>) =>
  repository.findOne({
    select: { cardanoAddress: true },
    where: { handle }
  });
