import {
  BlockDataEntity,
  BlockEntity,
  TypeormStabilityWindowBuffer,
  WithTypeormContext,
  createObservableConnection,
  willStoreBlockData
} from '../src';
import { Cardano } from '@cardano-sdk/core';
import { ChainSyncEventType, ProjectionEvent } from '@cardano-sdk/projection';
import { DataSource, NoConnectionForRepositoryError, QueryRunner, Repository } from 'typeorm';
import { connectionConfig$, createBlockEntity, createBlockHeader, initializeDataSource } from './util';
import { createStubObservable, logger } from '@cardano-sdk/util-dev';
import { firstValueFrom, of, throwError } from 'rxjs';

const createBlock = (height: number): Cardano.Block =>
  ({
    header: createBlockHeader(height)
  } as Cardano.Block);

const createBlockDataEntity = (block: Cardano.Block, blockEntity: BlockEntity): BlockDataEntity => ({
  block: blockEntity,
  blockHeight: blockEntity.height,
  data: block
});

const createCustomEvent = (secParameter: number, blockNo: number, tipBlockNo: number) => ({
  block: { header: { blockNo } } as Cardano.Block,
  genesisParameters: { securityParameter: secParameter } as Cardano.CompactGenesis,
  tip: { blockNo: tipBlockNo } as Cardano.Tip
});

describe('TypeormStabilityWindowBuffer', () => {
  const entities = [BlockEntity, BlockDataEntity];
  const securityParameter = 50;
  const compactBufferEveryNBlocks = 100;

  let dataSource: DataSource;
  let queryRunner: QueryRunner;
  let blockDataRepo: Repository<BlockDataEntity>;
  let blockRepo: Repository<BlockEntity>;
  let buffer: TypeormStabilityWindowBuffer;

  const insertBlock = async (header: Cardano.PartialBlockHeader) => {
    const blockEntity = createBlockEntity(header);
    await blockRepo.insert(blockEntity);
    return blockEntity;
  };

  const insertBlockAndData = async (block: Cardano.Block) => {
    const blockEntity = await insertBlock(block.header);
    const blockDataEntity = createBlockDataEntity(block, blockEntity);
    await blockDataRepo.insert(blockDataEntity);
    return { blockDataEntity, blockEntity };
  };

  const queryBlockData = (height: number) => blockDataRepo.findOne({ where: { blockHeight: height } });

  const getBlockFromBuffer = (id: Cardano.BlockId) => firstValueFrom(buffer.getBlock(id));
  const storeBlockDataToBuffer = (evt: ProjectionEvent<WithTypeormContext>) =>
    firstValueFrom(of(evt).pipe(buffer.storeBlockData()));

  beforeEach(async () => {
    dataSource = await initializeDataSource({ entities });
    queryRunner = dataSource.createQueryRunner();
    blockDataRepo = queryRunner.manager.getRepository(BlockDataEntity);
    blockRepo = queryRunner.manager.getRepository(BlockEntity);
  });

  afterEach(async () => {
    await queryRunner.release();
    await dataSource.destroy();
  });

  describe('with successful connection', () => {
    beforeEach(() => {
      const connection$ = createObservableConnection({
        connectionConfig$,
        entities,
        logger
      });
      buffer = new TypeormStabilityWindowBuffer({
        compactBufferEveryNBlocks,
        connection$,
        logger,
        reconnectionConfig: { initialInterval: 1 }
      });
    });

    describe('getBlock', () => {
      describe('when block data is found', () => {
        it('emits the block', async () => {
          const block = createBlock(1);
          await insertBlockAndData(block);
          await expect(getBlockFromBuffer(block.header.hash)).resolves.toEqual(block);
        });
      });

      describe('when block data is not found', () => {
        it('emits the null', async () => {
          const { hash } = createBlockHeader(1);
          await expect(getBlockFromBuffer(hash)).resolves.toBeNull();
        });
      });
    });

    describe('storeBlockData', () => {
      const tip = createBlockHeader(securityParameter * 20);
      const createEvent = (height: number) =>
        ({
          block: createBlock(height),
          eventType: ChainSyncEventType.RollForward,
          genesisParameters: { securityParameter },
          queryRunner,
          tip
        } as ProjectionEvent<WithTypeormContext>);

      describe('when block is within stability window', () => {
        it('inserts block data', async () => {
          const event = createEvent(tip.blockNo - securityParameter);
          await insertBlock(event.block.header);
          await storeBlockDataToBuffer(event);
          await expect(queryBlockData(event.block.header.blockNo)).resolves.toBeTruthy();
        });

        describe('when block height is a multiple of compactBufferEveryNBlocks parameter', () => {
          it('deletes block data that is outside of stability window', async () => {
            await insertBlockAndData(createBlock(tip.blockNo - securityParameter - 1));
            await insertBlockAndData(createBlock(tip.blockNo - securityParameter));
            await insertBlockAndData(createBlock(tip.blockNo - securityParameter + 1));

            expect(tip.blockNo % compactBufferEveryNBlocks).toBe(0);
            const event = createEvent(tip.blockNo);

            await insertBlock(event.block.header);
            await storeBlockDataToBuffer(event);

            await expect(queryBlockData(tip.blockNo - securityParameter - 1)).resolves.not.toBeTruthy();
            await expect(queryBlockData(tip.blockNo - securityParameter)).resolves.toBeTruthy();
            await expect(queryBlockData(tip.blockNo - securityParameter + 1)).resolves.toBeTruthy();
          });
        });
      });

      describe('when block is outside stability window', () => {
        it('does not insert block data', async () => {
          const event = createEvent(tip.blockNo - securityParameter - 1);
          await insertBlock(event.block.header);
          await storeBlockDataToBuffer(event);
          await expect(queryBlockData(event.block.header.blockNo)).resolves.not.toBeTruthy();
        });
      });
    });
  });

  describe('with failing connection', () => {
    describe('getBlock', () => {
      it('reconnects and eventually emits the block', async () => {
        const connection$ = createStubObservable(
          throwError(() => new NoConnectionForRepositoryError('conn')),
          createObservableConnection({
            connectionConfig$,
            entities,
            logger
          })
        );
        buffer = new TypeormStabilityWindowBuffer({
          compactBufferEveryNBlocks,
          connection$,
          logger,
          reconnectionConfig: { initialInterval: 1 }
        });

        const block = createBlock(1);
        await insertBlockAndData(block);
        await expect(getBlockFromBuffer(block.header.hash)).resolves.toEqual(block);
      });
    });
  });

  describe('willStoreBlockData', () => {
    it('returns false when block is outside stability window', () => {
      expect(willStoreBlockData(createCustomEvent(10, 1, 500))).toBe(false);
    });

    it('returns true when block is within stability window', () => {
      expect(willStoreBlockData(createCustomEvent(10, 490, 500))).toBe(true);
    });
  });
});
