/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable brace-style */
import { BlockDataEntity } from './entity';
import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { FindOptionsSelect, LessThan, QueryRunner, Repository } from 'typeorm';
import { Logger } from 'ts-log';
import { Observable, ReplaySubject, concatMap, from, map } from 'rxjs';
import {
  ProjectionEvent,
  RollBackwardEvent,
  RollForwardEvent,
  StabilityWindowBuffer,
  WithBlock,
  WithNetworkInfo
} from '@cardano-sdk/projection';
import { WithLogger, contextLogger } from '@cardano-sdk/util';
import { WithTypeormContext } from './operators';

const pointEquals = (point1: 'origin' | Cardano.Block | undefined, point2: 'origin' | Cardano.Block | undefined) => {
  if (typeof point1 !== 'object') {
    return point1 === point2;
  }
  if (typeof point2 !== 'object') {
    return false;
  }
  return point1.header.hash === point2.header.hash;
};

const blockDataSelect: FindOptionsSelect<BlockDataEntity> = {
  // Using 'transformers' breaks the types.
  // Types seem to expect model to have fields that match database types:
  // If it's an 'object', it will recursively apply FindOptionsSelect.
  data: true as any
};

export interface TypeormStabilityWindowBufferProps extends WithLogger {
  /**
   * 100 by default
   */
  compactBufferEveryNBlocks?: number;
  /**
   * Useful for testing with cherry-picked blocks
   */
  allowNonSequentialBlockHeights?: boolean;
}

export class TypeormStabilityWindowBuffer implements StabilityWindowBuffer {
  #tail?: Cardano.Block | 'origin';
  #tip?: Cardano.Block | 'origin';
  readonly #tip$: ReplaySubject<Cardano.Block | 'origin'> = new ReplaySubject(1);
  readonly #tail$: ReplaySubject<Cardano.Block | 'origin'> = new ReplaySubject(1);
  readonly tip$: Observable<Cardano.Block | 'origin'>;
  readonly tail$: Observable<Cardano.Block | 'origin'>;
  readonly #logger: Logger;
  readonly #compactEvery: number;
  readonly #allowNonSequentialBlockHeights?: boolean;

  constructor({
    allowNonSequentialBlockHeights,
    compactBufferEveryNBlocks = 100,
    logger
  }: TypeormStabilityWindowBufferProps) {
    this.#compactEvery = compactBufferEveryNBlocks;
    this.#allowNonSequentialBlockHeights = allowNonSequentialBlockHeights;
    this.#logger = contextLogger(logger, 'TypeormStabilityWindowBuffer');
    this.tip$ = this.#tip$.asObservable();
    this.tail$ = this.#tail$.asObservable();
  }

  storeBlockData<T extends ProjectionEvent<WithTypeormContext>>() {
    return (evt$: Observable<T>) =>
      evt$.pipe(
        concatMap((evt) =>
          from(
            evt.eventType === ChainSyncEventType.RollForward ? this.#rollForward(evt) : this.#rollBackward(evt)
          ).pipe(map(() => evt))
        )
      );
  }

  async initialize(queryRunner: QueryRunner): Promise<void> {
    const repository = queryRunner.manager.getRepository(BlockDataEntity);
    const [tip, tail] = await Promise.all([
      // findOne fails without `where:`, so using find().
      // It makes 2 queries so is not very efficient,
      // but it should be fine for `initialize`.
      repository.find({
        order: { blockHeight: 'DESC' },
        select: blockDataSelect,
        take: 1
      }),
      this.#findTail(repository)
    ]);
    this.#setTip(tip[0]?.data || 'origin');
    this.#setTail(tail[0]?.data || 'origin');
  }

  shutdown(): void {
    this.#tip$.complete();
    this.#tail$.complete();
  }

  async #findTail(repository: Repository<BlockDataEntity>) {
    return repository.find({
      order: { blockHeight: 'ASC' },
      select: blockDataSelect,
      take: 1
    });
  }

  async #rollForward(evt: RollForwardEvent<WithNetworkInfo & WithTypeormContext>) {
    const { eventType, transactionCommitted$, queryRunner, block } = evt;
    const {
      header: { blockNo }
    } = block;
    const repository = queryRunner.manager.getRepository(BlockDataEntity);
    if (eventType === ChainSyncEventType.RollForward) {
      this.#logger.debug('Add block data at height', blockNo);
      const blockData = repository.create({
        block: {
          height: blockNo
        },
        data: block
      });
      await Promise.all([repository.insert(blockData), this.#deleteOldBlockData(evt)]);
      transactionCommitted$.subscribe(() => {
        this.#setTip(block);
        if (this.#tail === 'origin') {
          this.#setTail(block);
        }
      });
    }
  }

  async #rollBackward({
    transactionCommitted$,
    queryRunner,
    block: {
      header: { blockNo }
    }
  }: RollBackwardEvent<WithBlock & WithTypeormContext>) {
    const repository = queryRunner.manager.getRepository(BlockDataEntity);
    // No need to delete rolled back block here, as it should cascade when the block entity gets deleted
    const prevTip = await repository.findOne({
      order: {
        blockHeight: 'DESC'
      },
      select: blockDataSelect,
      where: {
        blockHeight: LessThan(blockNo)
      }
    });
    if (!this.#allowNonSequentialBlockHeights && prevTip?.data && blockNo !== prevTip?.data.header.blockNo + 1) {
      throw new Error('Assert: inconsistent PgStabilityWindowBuffer at rollBackward');
    }
    transactionCommitted$.subscribe(() => {
      this.#setTip(prevTip?.data || 'origin');
      if (!prevTip?.data) {
        this.#setTail('origin');
      }
    });
  }

  async #deleteOldBlockData({
    genesisParameters: { securityParameter },
    block: {
      header: { blockNo }
    },
    queryRunner,
    transactionCommitted$
  }: RollForwardEvent<WithNetworkInfo & WithTypeormContext>) {
    if (blockNo < securityParameter || blockNo % this.#compactEvery !== 0) {
      return;
    }
    const repository = queryRunner.manager.getRepository(BlockDataEntity);
    const nextTailBlockHeight = blockNo - securityParameter;
    let [nextTailEntity] = await Promise.all([
      repository.findOne({
        select: {
          data: true as any
        },
        where: {
          blockHeight: nextTailBlockHeight
        }
      }),
      repository.delete({
        blockHeight: LessThan(nextTailBlockHeight)
      })
    ]);
    if (!nextTailEntity) {
      if (this.#allowNonSequentialBlockHeights) {
        [nextTailEntity] = await this.#findTail(repository);
      } else {
        throw new Error('Assert: inconsistent PgStabilityWindowBuffer at #deleteOldBlockData');
      }
    }
    transactionCommitted$.subscribe(() => this.#setTail(nextTailEntity!.data!));
  }

  #setTail(tail: Cardano.Block | 'origin') {
    if (!pointEquals(tail, this.#tail)) {
      this.#tail = tail;
      this.#tail$.next(tail);
    }
  }

  #setTip(tip: Cardano.Block | 'origin') {
    if (!pointEquals(tip, this.#tip)) {
      this.#tip = tip;
      this.#tip$.next(tip);
    }
  }
}
