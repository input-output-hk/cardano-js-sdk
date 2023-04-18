import {
  BlockDataEntity,
  BlockEntity,
  TypeormStabilityWindowBuffer,
  storeBlock,
  typeormTransactionCommit,
  withTypeormTransaction
} from '../src';
import { Bootstrap, ProjectionEvent, requestNext } from '@cardano-sdk/projection';
import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { ChainSyncDataSet, chainSyncData, logger } from '@cardano-sdk/util-dev';
import { DataSource, QueryRunner } from 'typeorm';
import {
  Observable,
  combineLatest,
  defer,
  filter,
  firstValueFrom,
  lastValueFrom,
  of,
  take,
  takeWhile,
  toArray
} from 'rxjs';
import { initializeDataSource } from './util';

const { cardanoNode, networkInfo } = chainSyncData(ChainSyncDataSet.WithStakeKeyDeregistration);

describe('TypeormStabilityWindowBuffer', () => {
  const securityParameter = 50;
  const compactBufferEveryNBlocks = 100;

  let dataSource: DataSource;
  let queryRunner: QueryRunner;
  let buffer: TypeormStabilityWindowBuffer;
  let project$: Observable<Omit<ProjectionEvent, 'requestNext'>>;

  const getBufferSize = () => queryRunner.manager.count(BlockDataEntity);
  const getNumBlocks = () => queryRunner.manager.count(BlockEntity);
  // eslint-disable-next-line unicorn/consistent-function-scoping
  const getHeader = (tipOrTail: Cardano.Block | 'origin') => (tipOrTail as Cardano.Block).header;

  beforeEach(async () => {
    dataSource = await initializeDataSource({ entities: [BlockEntity, BlockDataEntity] });
    queryRunner = dataSource.createQueryRunner();
    buffer = new TypeormStabilityWindowBuffer({
      allowNonSequentialBlockHeights: false,
      compactBufferEveryNBlocks,
      logger
    });
    await buffer.initialize(queryRunner);
    project$ = defer(() =>
      Bootstrap.fromCardanoNode({
        buffer,
        cardanoNode: {
          ...cardanoNode,
          genesisParameters$: of({
            ...networkInfo.genesisParameters,
            securityParameter
          })
        },
        logger
      }).pipe(
        withTypeormTransaction({ dataSource$: of(dataSource), logger }),
        storeBlock(),
        buffer.storeBlockData(),
        typeormTransactionCommit(),
        requestNext()
      )
    );
  });

  afterEach(async () => {
    buffer.shutdown();
    await queryRunner.release();
    await dataSource.destroy();
  });

  it("calling initialize() again does not reemit tip and tail if they haven't changed", async () => {
    const tips = firstValueFrom(buffer.tip$.pipe(toArray()));
    const tails = firstValueFrom(buffer.tail$.pipe(toArray()));
    await buffer.initialize(queryRunner);
    buffer.shutdown();
    expect(await tips).toHaveLength(1);
    expect(await tails).toHaveLength(1);
  });

  // eslint-disable-next-line unicorn/consistent-function-scoping
  describe('when there are no blocks in the buffer', () => {
    it('emits "origin" for both tip and tail', async () => {
      const [tip, tail] = await firstValueFrom(combineLatest([buffer.tip$, buffer.tail$]));
      expect(tip).toEqual('origin');
      expect(tail).toEqual('origin');
    });
  });

  describe('with 1 block in the buffer', () => {
    it('emits that block as both tip$ and tail$', async () => {
      await firstValueFrom(project$);
      const lastTipAndTail = firstValueFrom(combineLatest([buffer.tip$, buffer.tail$]));
      const [tip, tail] = await lastTipAndTail;
      expect(typeof tip).toEqual('object');
      expect(tail).toEqual(tip);
    });
  });

  describe('with 3 blocks in the buffer', () => {
    it('emits tip$ for every new block, tail$ only for origin and the 1st block', async () => {
      const tipsReady = firstValueFrom(buffer.tip$.pipe(toArray()));
      const tailsReady = firstValueFrom(buffer.tail$.pipe(toArray()));
      await lastValueFrom(project$.pipe(take(3)));
      expect(await getBufferSize()).toEqual(3);
      buffer.shutdown();
      const tips = await tipsReady;
      expect(tips.length).toEqual(4);
      expect(tips[0]).toEqual('origin');
      expect(getHeader(tips[1]).hash).not.toEqual(getHeader(tips[2]).hash);
      expect(getHeader(tips[2]).hash).not.toEqual(getHeader(tips[3]).hash);
      const tails = await tailsReady;
      expect(tails.length).toEqual(2);
      expect(tails[0]).toEqual('origin');
      expect(getHeader(tails[1]).hash).toEqual(getHeader(tips[1]).hash);
    });
  });

  it('rollback pops the tip$', async () => {
    const tipsReady = firstValueFrom(buffer.tip$.pipe(toArray()));
    await firstValueFrom(project$.pipe(filter(({ eventType }) => eventType === ChainSyncEventType.RollBackward)));
    buffer.shutdown();
    const tips = await tipsReady;
    expect(getHeader(tips[tips.length - 1]).blockNo).toBeLessThan(getHeader(tips[tips.length - 2]).blockNo);
  });

  it('clears old block_data every 100 blocks and emits new tail$', async () => {
    await lastValueFrom(
      project$.pipe(
        // stop one block before the expected clear
        takeWhile(
          ({
            block: {
              header: { blockNo }
            }
          }) => (blockNo + 1) % compactBufferEveryNBlocks !== 0
        )
      )
    );
    const preClearTail = firstValueFrom(buffer.tail$);
    const preClearBufferSize = await getBufferSize();
    const preClearNumBlocks = await getNumBlocks();
    // next event should trigger the clear
    await firstValueFrom(project$);
    const postClearTail = firstValueFrom(buffer.tail$);
    expect(await getBufferSize()).toBeLessThan(preClearBufferSize);
    expect(await getNumBlocks()).toEqual(preClearNumBlocks + 1);
    const preClearTailHeight = getHeader(await preClearTail).blockNo;
    const postClearTailHeight = getHeader(await postClearTail).blockNo;
    expect(postClearTailHeight).toBeGreaterThan(preClearTailHeight);
  });
});
