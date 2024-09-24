import {
  AssetEntity,
  BlockDataEntity,
  BlockEntity,
  HandleMetadataEntity,
  NftMetadataEntity,
  OutputEntity,
  TokensEntity,
  TypeormStabilityWindowBuffer,
  TypeormTipTracker,
  createObservableConnection,
  storeAssets,
  storeBlock,
  storeHandleMetadata,
  storeUtxo,
  typeormTransactionCommit,
  willStoreHandleMetadata,
  withTypeormTransaction
} from '../../src';
import { Bootstrap, Mappers, ObservableCardanoNode, ProjectionEvent, requestNext } from '@cardano-sdk/projection';
import { Cardano } from '@cardano-sdk/core';
import { ChainSyncDataSet, chainSyncData, logger } from '@cardano-sdk/util-dev';
import { HandleMetadata } from '@cardano-sdk/projection/dist/cjs/operators/Mappers';
import { Observable, firstValueFrom } from 'rxjs';
import { QueryRunner, Repository } from 'typeorm';
import { connectionConfig$, initializeDataSource } from '../util';
import {
  createProjectorContext,
  createProjectorTilFirst,
  createRollBackwardEventFor,
  createStubProjectionSource
} from './util';

describe('storeHandleMetadata', () => {
  const eventsWithCip68Handle = chainSyncData(ChainSyncDataSet.WithInlineDatum);
  const eventsWithCip25Handle = chainSyncData(ChainSyncDataSet.WithHandle);
  const policyId = Cardano.PolicyId('f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a');
  const policyIds = [policyId];

  let queryRunner: QueryRunner;
  let buffer: TypeormStabilityWindowBuffer;
  let tipTracker: TypeormTipTracker;
  const entities = [
    BlockEntity,
    BlockDataEntity,
    AssetEntity,
    NftMetadataEntity,
    TokensEntity,
    OutputEntity,
    HandleMetadataEntity
  ];

  const storeData = (
    evt$: Observable<ProjectionEvent<Mappers.WithUtxo & Mappers.WithMint & Mappers.WithHandleMetadata>>
  ) =>
    evt$.pipe(
      withTypeormTransaction({ connection$: createObservableConnection({ connectionConfig$, entities, logger }) }),
      storeBlock(),
      storeAssets(),
      storeUtxo(),
      storeHandleMetadata(),
      buffer.storeBlockData(),
      typeormTransactionCommit()
    );

  // eslint-disable-next-line unicorn/consistent-function-scoping
  const applyOperators = () => (evt$: Observable<ProjectionEvent<{}>>) =>
    evt$.pipe(
      Mappers.withUtxo(),
      Mappers.withMint(),
      Mappers.withCIP67(),
      Mappers.withNftMetadata({ logger }),
      Mappers.withHandleMetadata({ policyIds }, logger),
      storeData,
      tipTracker.trackProjectedTip(),
      requestNext()
    );

  const project$ = (cardanoNode: ObservableCardanoNode) => () =>
    Bootstrap.fromCardanoNode({
      blocksBufferLength: 1,
      buffer,
      cardanoNode,
      logger,
      projectedTip$: tipTracker.tip$
    }).pipe(applyOperators());

  const projectTilFirst = (cardanoNode: ObservableCardanoNode) => createProjectorTilFirst(project$(cardanoNode));
  let repository: Repository<HandleMetadataEntity>;

  beforeEach(async () => {
    const dataSource = await initializeDataSource({ entities });
    queryRunner = dataSource.createQueryRunner();
    ({ buffer, tipTracker } = createProjectorContext(entities));
    repository = queryRunner.manager.getRepository(HandleMetadataEntity);
  });

  afterEach(async () => {
    await queryRunner.release();
  });

  const testRollForwardAndBackward = async (
    cardanoNode: ObservableCardanoNode,
    projectUntil: (evt: Mappers.WithHandleMetadata) => boolean,
    assertMetadataProps: (projected: Mappers.HandleMetadata, stored: HandleMetadataEntity) => void
  ) => {
    const mintEvent = await projectTilFirst(cardanoNode)(projectUntil);
    expect(mintEvent.handleMetadata.length).toBeGreaterThan(0);
    const numHandlesAfterMintEvent = await repository.count();
    expect(numHandlesAfterMintEvent).toBeGreaterThanOrEqual(mintEvent.handleMetadata.length);

    const projectedMetadata = mintEvent.handleMetadata[0];
    const storedMetadata = await repository.findOne({
      relations: { output: true },
      where: { handle: projectedMetadata.handle }
    });
    assertMetadataProps(projectedMetadata, storedMetadata!);

    await firstValueFrom(createStubProjectionSource([createRollBackwardEventFor(mintEvent)]).pipe(applyOperators()));
    expect(await repository.count()).toBe(numHandlesAfterMintEvent - mintEvent.handleMetadata.length);
  };

  it('inserts cip25 metadata on RollForward, deletes on RollBackward', async () => {
    await testRollForwardAndBackward(
      eventsWithCip25Handle.cardanoNode,
      // cip25 metadata does not have txOut
      (evt) => evt.handleMetadata.length > 0 && !evt.handleMetadata[0].txOut,
      (projected, stored) => {
        expect(stored.og).toBe(projected.og);
        expect(stored.output?.id).toBeUndefined();
      }
    );
  });

  it('inserts cip68 metadata on RollForward, deletes on RollBackward', async () => {
    await testRollForwardAndBackward(
      eventsWithCip68Handle.cardanoNode,
      // cip68 metadata has txOut
      (evt) => evt.handleMetadata.length > 0 && !!evt.handleMetadata[0].txOut,
      (projected, stored) => {
        expect(stored.og).toBe(projected.og);
        expect(stored.backgroundImage).toBe(projected.backgroundImage || null);
        expect(stored.profilePicImage).toBe(projected.profilePicImage || null);
        expect(typeof stored.output?.id).toBe('number');
      }
    );
  });
});

describe('willStoreHandleMetadata', () => {
  it('returns true if handleMetadata are bigger than 1', () => {
    expect(
      willStoreHandleMetadata({
        handleMetadata: [{} as HandleMetadata]
      })
    ).toBeTruthy();
  });

  it('returns false if there are no handleMetadata', () => {
    expect(
      willStoreHandleMetadata({
        handleMetadata: []
      })
    ).toBeFalsy();
  });
});
